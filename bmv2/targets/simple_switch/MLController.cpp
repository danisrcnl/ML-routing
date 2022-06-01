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
#define LOG "[MLController.cpp] "

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

  void pushAddr(const Data& mac, const Data& address, Data& pos, const Data& valid_bool) {

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

    int ret = c->push(address.get<uint32_t>());
    pos = static_cast<Data>(ret);
  }

  void popAddr(const Data& mac, const Data& pos, const Data& valid_bool) {

    checkHost(mac);
    checkCCBuffer();

    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;
    if (debug) cout << LOG << "pop called for element at pos = " << pos.get<int>() << endl;
    c->pop(pos.get<int>());
  }

  void getOutputPort(const Data& mac, const Data& pos, const Data& valid_bool, Data& outPort, Data& doForward) {
    if (debug) cout << LOG << "Into getOutputPort" << endl;
    if (MLController::hosts.empty())
      MLController::hosts = parseMac();

    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;

    checkHost(mac);
    checkPy();
    if (debug) cout << LOG << "sending socket request to get output port" << endl;
    uint32_t lastRw = rewards.pop();
    int port = py->getPort(c->get(pos.get<int>()), lastRw, *c);
    if (port == -1)
      doForward = static_cast<Data>(0);
    doForward = static_cast<Data>(1);
    outPort = static_cast<Data>(port);
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

  void sendReward(const Data& valid_bool, const Data& qtime) {
    // qtime will be bit<32> deq_timedelta in p4
    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;
    if (debug) cout << LOG << "storing reward in rws queue" << endl;
    rewards.push(qtime.get<uint32_t>());
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
  bool firstRun;
  RewardsQ rewards;
  static unordered_map <string, int> packet_counter;
  bool debug;
  std::mutex log_f_mutex;

  char* showAddr(uint32_t ip) {
    struct in_addr ip_addr;
    ip_addr.s_addr = htonl(ip);
    return inet_ntoa(ip_addr);
  }

  string showMac (uint64_t mac) {
    stringstream ss;
    ss << hex << mac;
    string macString = ss.str();
    return macString;
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
      string filename = "fw_drop_log_" + host + ".txt";
      ofs.open(filename, std::ofstream::out | std::ofstream::trunc);
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

BM_REGISTER_EXTERN(MLController);
BM_REGISTER_EXTERN_METHOD(MLController, simulate_computation);
BM_REGISTER_EXTERN_METHOD(MLController, print);
BM_REGISTER_EXTERN_METHOD(MLController, pushAddr, const Data&, const Data&, Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, popAddr, const Data&, const Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, getOutputPort, const Data&, const Data&, const Data&, Data&, Data&);
BM_REGISTER_EXTERN_METHOD(MLController, sendReward, const Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, setAsIngress);
BM_REGISTER_EXTERN_METHOD(MLController, setAsEgress);
BM_REGISTER_EXTERN_METHOD(MLController, getNeighborMac, Data&, const Data&, Data&);
BM_REGISTER_EXTERN_METHOD(MLController, logFw, const Data&, const Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, logDrop_f, const Data&, const Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, logFw_f, const Data&, const Data&, const Data&, const Data&, const Data&, const Data&);

int import_ml_controller() {
  return 0;
}
