#include <bm/bm_sim/extern.h>
#include <unistd.h>
#include <iostream>
#include <array>
#include <unordered_map>
#include <mutex>
#include <cinttypes>
#include <thread>
#include <chrono>
#include <arpa/inet.h>
#include "pymodule.h"
#include "parseMac.h"
#include "rewardsQ.h"
#include <stdio.h>
#include <limits.h>

#define PORT "1500"
#define IP "0.0.0.0"
#define RWS_SIZE 100000
#define LOG "[MLController.cpp] "
#define UPDATE_FREQUENCY 500

using namespace std;

template <typename... Args>
using ActionPrimitive = bm::ActionPrimitive<Args...>;

using bm::Data;
using bm::Header;
using bm::PHV;
using bm::ExternType;

class MLController : public ExternType {
 public:

  BM_EXTERN_ATTRIBUTES {
  }

  void init() override {
    if (debug) cout << LOG << "Building instance of MLController..." << endl;
    debug = true;
    firstRun = true;
    isIngress = true;
    py = nullptr;
    c = nullptr;
    host = "nullhost";
  }

  void simulate_computation () {
    if (debug) cout << LOG << "simulate_computation called" << endl;
    sleep(1);
  }

  void print() {
    if (debug) cout << LOG << "print called" << endl;
    c->show();
  }

  void pushAddr(const Data& mac, const Data& address, Data& pos, const Data& valid_bool, Data& update_entry) {

    if (firstRun) {
      if (debug) cout << LOG << "First run, going sleep 10 seconds to wait for topology.db" << endl;
      sleep(10);
      firstRun = false;
    }

    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;
    if (debug) cout << LOG << "push called for address " << showAddr(address.get<uint32_t>()) << endl;
    if (MLController::hosts.empty())
      MLController::hosts = parseMac();

    checkHost(mac);
    checkCCBuffer();

    int update_entry_int = 0;

    uint32_t address_int = address.get<uint32_t>();
    if (counters.find(address_int) == counters.end()) {
      counters[address_int] = 0;
      update_entry_int = 1;
    }
    if (++counters[address_int] == UPDATE_FREQUENCY) {
      counters[address_int] = 0;
      update_entry_int = 1;
    }

    int ret = c->push(address_int);
    pos = static_cast<Data>(ret);
    update_entry = static_cast<Data>(update_entry_int);
  }

  void popAddr(const Data& mac, const Data& pos, const Data& valid_bool) {

    checkHost(mac);
    checkCCBuffer();

    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;
    if (debug) cout << LOG << "pop called for element at pos = " << pos.get<int>() << endl;
    c->pop(pos.get<int>());
  }

  void getOutputPort(const Data& mac, const Data& pos, const Data& valid_bool, Data& outPort, Data& doForward, Data& id) {
    if (debug) cout << LOG << "Into getOutputPort" << endl;
    if (MLController::hosts.empty())
      MLController::hosts = parseMac();

    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;

    checkHost(mac);
    checkPy();

    if (debug) cout << LOG << "sending socket request to get output port" << endl;
    //uint32_t lastRw = rewards.pop();

    id = static_cast<Data>(MLController::nextId);
    uint32_t lastRw;
    if (MLController::nextId != 0) {
      lastRw = MLController::rws[MLController::nextRw];
      MLController::nextRw = (MLController::nextRw + 1) % RWS_SIZE;
    }
    else
      lastRw = 0;

    int port = py->getPort(c->get(pos.get<int>()), lastRw, *c);
    if (port == -1)
      doForward = static_cast<Data>(0);
    //routing_table[c->get(pos.get<int>())] = port;
    doForward = static_cast<Data>(1);
    outPort = static_cast<Data>(port);
    MLController::nextId = (MLController::nextId + 1) % RWS_SIZE;
    //update_routes(showAddr(c->get(pos.get<int>())), port);
  }

  // receives mac of router to identify it, uses that field to write the mac of the chosen neighbor
  void getNeighborMac (Data& mac, const Data& port, Data& doForward) {
    uint32_t port_int = port.get<uint32_t>();
    uint64_t mac_int = mac.get<uint64_t>();
    if (debug) cout << LOG << "Getting neighbor for mac " << showMac(mac_int) << " on port " << port_int << endl;

    if (checkDestination(mac_int) < 0) {
      doForward = static_cast<Data>(0);
      return;
    }
    doForward = static_cast<Data>(1);

    uint64_t rv = getNeighbor(host, port_int);
    if (debug) cout << LOG << "Neighbor of " << host << " on port " << port_int << " has mac " << showMac(rv) << endl;
    mac = static_cast<Data>(rv);
    doForward = static_cast<Data>(1);
  }

  void sendReward(const Data& valid_bool, const Data& qtime, const Data& id) {
    // qtime will be bit<32> deq_timedelta in p4
    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;
    if (debug) cout << LOG << "storing reward in rws" << endl;
    //rewards.push(qtime.get<uint32_t>());

    uint32_t id_int = id.get<uint32_t>();
    MLController::rws[id_int] = qtime.get<uint32_t>();

  }

  void setAsIngress () {
    isIngress = true;
  }

  void setAsEgress () {
    isIngress = false;
  }

  void logFw (const Data& macsrc, const Data& macdst, const Data& port) {
    cout << "Sending out packet on port " << port.get<int>() << endl;
    cout << "=========================" << endl;
    cout << "MAC src: " << showMac(macsrc.get<uint64_t>()) << endl;
    cout << "MAC dst: " << showMac(macdst.get<uint64_t>()) << endl;
    cout << "=========================" << endl;
  }

  void logDrop_f (const Data& macsrc, const Data& macdst, const Data& in_port) {
    if (host == "nullhost") return;
    lock_guard<std::mutex> lk(log_f_mutex);
    ofstream ofs;
    string filename = "fw_drop_log_" + host + ".txt";
    ofs.open(filename, std::ios_base::app | std::ios_base::in);
    uint64_t macsrc_int = macsrc.get<uint64_t>();
    uint64_t macdst_int = macdst.get<uint64_t>();
    int in_port_int = in_port.get<int>();
    ofs << "src: " + MLController::hosts[macsrc_int] + ", dst: " + MLController::hosts[macdst_int] + ", port: " + std::to_string(in_port_int) + " [dropped]"<< endl;
    ofs.close();
  }

  void logFw_f (const Data& macsrc, const Data& macdst, const Data& ipdst, const Data& in_port, const Data& out_port, const Data& destination) {
    lock_guard<std::mutex> lk(log_f_mutex);
    ofstream ofs;
    string filename = "fw_drop_log_" + host + ".txt";
    ofs.open(filename, std::ios_base::app | std::ios_base::in);
    uint64_t macsrc_int = macsrc.get<uint64_t>();
    uint64_t macdst_int = macdst.get<uint64_t>();
    uint64_t destination_int = destination.get<uint64_t>();
    uint32_t ipdst_int = ipdst.get<uint32_t>();
    int in_port_int = in_port.get<int>();
    int out_port_int = out_port.get<int>();
    ofs << "(" + string(showAddr(ipdst_int)) + ") src: " + MLController::hosts[macsrc_int] + ", dst: " +
      MLController::hosts[macdst_int] + ", port: " +
      std::to_string(in_port_int) + " [forwarded to " + MLController::hosts[destination_int] +
      ", port " + std::to_string(out_port_int) + "] (count = " +
      std::to_string(++MLController::packet_counter[host]) + ")" << endl;
    ofs.close();
  }

  virtual ~MLController () {}

private:
  bool isIngress;
  ConcurrentCBuffer* c;
  PyModule* py;
  string host;
  static unordered_map <string, ConcurrentCBuffer*> ccbuffers;
  static unordered_map <string, PyModule*> pyS;
  static unordered_map <uint64_t, string> hosts;
  static unordered_map <uint32_t, uint32_t> rws;
  unordered_map <uint32_t, int> routing_table;
  unordered_map <uint32_t, int> counters;
  static uint32_t nextId;
  static uint32_t nextRw;
  bool firstRun;
  RewardsQ rewards;
  static unordered_map <string, int> packet_counter;
  bool debug;
  std::mutex log_f_mutex;
  std::mutex routes_mutex;

  string make_route (char* dst) {
    string ip(dst);
    int count_dots = 0, i = 0, last_dot = 0;
    while (count_dots < 3) {
      if (ip[i] == '.') {
        count_dots++;
        last_dot = i;
      }
      i++;
    }
    ip.resize(last_dot + 1);
    string tba = "0/24";
    ip.insert(last_dot + 1, tba);
    return ip;
  }

  void update_routes (char* dst, int port) {
    lock_guard<std::mutex> lk(routes_mutex);
    string ip = make_route(dst);
    ifstream ifs;
    ofstream ofs;
    ifs.open(host + "_commands.txt");
    ofs.open(host + "_commands-tmp.txt");
    string str_tmp;
    string mac_next_hop = showMac(getNeighbor(host, port));
    string new_route = "table_add ipv4_lpm ipv4_forward " + ip + " => " + mac_next_hop + " " + std::to_string(port);
    bool found = false;
    while (std::getline(ifs, str_tmp)) {
      if (str_tmp.find(ip) != string::npos) {
        str_tmp = new_route;
        found = true;
      }
      ofs << str_tmp << endl;
    }
    if (!found)
      ofs << new_route << endl;
    ifs.close();
    ofs.close();
    remove((host + "_commands.txt").c_str());
    rename((host + "_commands-tmp.txt").c_str(), (host + "_commands.txt").c_str());
    int thrift_port_int = 9089;
    if (host[0] == 's')
      thrift_port_int += 4;
    int offset = host[1] - '0';
    thrift_port_int += offset;
    string thrift_port = std::to_string(thrift_port_int);
    int ret = system(("simple_switch_CLI --thrift-port " + thrift_port + " < " + host + "_commands.txt").c_str());
    if (ret < 0)
      throw std::runtime_error("system failed");
  }

  char* showAddr(uint32_t ip) {
    struct in_addr ip_addr;
    ip_addr.s_addr = htonl(ip);
    return inet_ntoa(ip_addr);
  }

  string showMac (uint64_t mac) {
    stringstream ss;
    ss << hex << mac;
    string macString = ss.str();
    int diff = 12 - macString.length();
    for (int i = 0; i < diff; i++)
        macString.insert(0, 1, '0');
    string out_str;
    int j = 0;
    for (int i = 0; i < (int)(macString.length()); i++) {
        out_str.insert(j, 1, macString[i]);
        if ((i + 1) % 2 == 0 && i != (int)(macString.length() - 1))
            out_str.insert(++j, 1, ':');
        j++;
    }
    return out_str;
}

  void checkHost (const Data& mac) {
    if (host == "nullhost") {
      if (MLController::hosts.find(mac.get<uint64_t>()) == MLController::hosts.end()) {
        if (debug) cout << LOG << "Mac " << showMac(mac.get<uint64_t>()) << " not found" << endl;
        return;
      }
      host = MLController::hosts[mac.get<uint64_t>()];
      if (debug) cout << LOG << "Mac address " << showMac(mac.get<uint64_t>()) << " is associated to node " << host << endl;
      ofstream ofs;
      string filename = host + "_commands.txt";
      ofs.open(filename, std::ofstream::out | std::ofstream::trunc);
      ofs << "table_set_default ipv4_lpm drop" << endl;
      ofs.close();
    }
    else
      if (debug) cout << LOG << "This switch is already bound to node " << host << endl;
  }

  int checkDestination (uint64_t mac_int) {
    if (MLController::hosts.find(mac_int) == MLController::hosts.end()) {
      if (debug) cout << LOG << "Address not associated to a node, not forwarding" << endl;
      return -1;
    }
    return 0;
  }

  void checkPy () {
    if (host == "nullhost")
      return;
    if (py == nullptr) {
      if (MLController::pyS.find(host) == MLController::pyS.end())
        MLController::pyS[host] = new PyModule(host);
      py = MLController::pyS[host];
    }
  }

  void checkCCBuffer () {
    if (c == nullptr) {
      if (MLController::ccbuffers.find(host) == MLController::ccbuffers.end())
        MLController::ccbuffers[host] = new ConcurrentCBuffer();
      c = MLController::ccbuffers[host];
    }
  }
};

unordered_map <string, PyModule*> MLController::pyS;
unordered_map <uint64_t, string> MLController::hosts;
unordered_map <string, int> MLController::packet_counter;
unordered_map <string, ConcurrentCBuffer*> MLController::ccbuffers;
unordered_map <uint32_t, uint32_t> MLController::rws;
uint32_t MLController::nextId = 0;
uint32_t MLController::nextRw = 0;

BM_REGISTER_EXTERN(MLController);
BM_REGISTER_EXTERN_METHOD(MLController, simulate_computation);
BM_REGISTER_EXTERN_METHOD(MLController, print);
BM_REGISTER_EXTERN_METHOD(MLController, pushAddr, const Data&, const Data&, Data&, const Data&, Data&);
BM_REGISTER_EXTERN_METHOD(MLController, popAddr, const Data&, const Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, getOutputPort, const Data&, const Data&, const Data&, Data&, Data&, Data&);
BM_REGISTER_EXTERN_METHOD(MLController, sendReward, const Data&, const Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, setAsIngress);
BM_REGISTER_EXTERN_METHOD(MLController, setAsEgress);
BM_REGISTER_EXTERN_METHOD(MLController, getNeighborMac, Data&, const Data&, Data&);
BM_REGISTER_EXTERN_METHOD(MLController, logFw, const Data&, const Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, logDrop_f, const Data&, const Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, logFw_f, const Data&, const Data&, const Data&, const Data&, const Data&, const Data&);

int import_ml_controller() {
  return 0;
}
