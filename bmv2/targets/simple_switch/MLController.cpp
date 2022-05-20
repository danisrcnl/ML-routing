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
#define CBufferSize 100

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
    cout << LOG << "init called" << endl;
    firstRun = true;
    isIngress = true;
  }

  void simulate_computation () {
    cout << LOG << "simulate_computation called" << endl;
    sleep(1);
  }

  void print() {
    cout << LOG << "print called" << endl;
    c.show();
  }

  void pushAddr(const Data& address, Data& pos, const Data& valid_bool) {
    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;
    cout << LOG << "push called for address " << showAddr(address.get<uint32_t>()) << endl;
    int ret = c.push(address.get<uint32_t>());
    pos = static_cast<Data>(ret);
  }

  void popAddr(const Data& pos, const Data& valid_bool) {
    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;
    cout << LOG << "pop called for element at pos = " << pos.get<int>() << endl;
    c.pop(pos.get<int>());
  }

  void getOutputPort(const Data& mac, const Data& pos, const Data& valid_bool, Data& outPort) {
    if (firstRun && isIngress) {
      sleep(10);
      firstRun = false;
    }
    if (MLController::hosts.empty())
      MLController::hosts = parseMac();
    cout << LOG << "Looking up mac address " << showMac(mac.get<uint64_t>()) << endl;

    if (MLController::hosts.find(mac.get<uint64_t>()) == MLController::hosts.end()) {
      cout << LOG << "Mac " << showMac(mac.get<uint64_t>()) << " not found" << endl;
      return;
    }

    string host = MLController::hosts[mac.get<uint64_t>()];

    cout << LOG << "Mac address " << showMac(mac.get<uint64_t>()) << " is associated to host " << host << endl;

    if (MLController::pyS.find(host) == MLController::pyS.end())
      MLController::pyS[host] = new PyModule(host);
    PyModule* py = MLController::pyS[host];
    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;
    cout << LOG << "sending socket request to get output port" << endl;
    uint32_t lastRw = rewards.pop();
    int port = py->getPort(c.get(pos.get<int>()), lastRw, c);
    outPort = static_cast<Data>(port);
  }

  void sendReward(const Data& valid_bool, const Data& qtime) {
    // qtime will be bit<32> deq_timedelta in p4
    if (valid_bool.get<int>() == 0) // set by p4 app if ipv4 parsing happened
      return;
    cout << LOG << "storing reward in rws queue" << endl;
    rewards.push(qtime.get<uint32_t>());
  }

  void setAsIngress () {
    isIngress = true;
  }

  void setAsEgress () {
    isIngress = false;
  }

  virtual ~MLController () {}

private:
  bool isIngress;
  ConcurrentCBuffer c;
  static unordered_map <string, PyModule*> pyS;
  static unordered_map <uint64_t, string> hosts;
  bool firstRun;
  RewardsQ rewards;

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
};

unordered_map <string, PyModule*> MLController::pyS;
unordered_map <uint64_t, string> MLController::hosts;

BM_REGISTER_EXTERN(MLController);
BM_REGISTER_EXTERN_METHOD(MLController, simulate_computation);
BM_REGISTER_EXTERN_METHOD(MLController, print);
BM_REGISTER_EXTERN_METHOD(MLController, pushAddr, const Data&, Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, popAddr, const Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, getOutputPort, const Data&, const Data&, const Data&, Data&);
BM_REGISTER_EXTERN_METHOD(MLController, sendReward, const Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, setAsIngress);
BM_REGISTER_EXTERN_METHOD(MLController, setAsEgress);

int import_ml_controller() {
  return 0;
}
