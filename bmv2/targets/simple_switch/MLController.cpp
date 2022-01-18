#include <bm/bm_sim/extern.h>
#include <unistd.h>
#include <iostream>
#include <array>
#include <mutex>
#include <cinttypes>
#include <thread>
#include <chrono>
#include <arpa/inet.h>

#define PORT "1500"
#define IP "0.0.0.0"
#define LOG "[MLController.cpp] "
#define CBufferSize 100

using namespace std;

class Address {
private:
  uint32_t addr;
  bool valid;
public:
  Address() {
    this->addr = 0;
    this->valid = false;
  }
  Address(uint32_t addr) {
    this->addr = addr;
    this->valid = false;
  }
  Address(const Address& a) {
    this->addr = a.addr;
    this->valid = a.valid;
  }
  Address(Address&& a) {
    this->addr = a.addr;
    this->valid = a.valid;
  }
  ~Address() {}
  const Address& operator=(const Address& a) {
    this->addr = a.addr;
    this->valid = a.valid;
    return *this;
  }
  void enable() {
    this->valid = true;
  }
  void disable() {
    this->valid = false;
  }
  bool isValid() {
    return this->valid;
  }
  uint32_t getAddress() {
    return this->addr;
  }
};

class ConcurrentCBuffer {
private:
  array<Address, CBufferSize> futureDestinations;
  mutex futureDestinations_mutex;
  int head;
  int validElements;
  int nextPos;

public:
  ConcurrentCBuffer () {
    futureDestinations.fill(Address());
    head = 0;
    validElements = 0;
    nextPos = 0;
  };
  ~ConcurrentCBuffer () {};

  uint32_t get(int pos) {
    lock_guard<mutex> lk(futureDestinations_mutex);
    return futureDestinations[pos].getAddress();
  }

  int push(uint32_t address) {
    lock_guard<mutex> lk(futureDestinations_mutex);
    int pos = nextPos % CBufferSize;
    if (pos == head && validElements != 0) {
      int i = (head + 1) % CBufferSize;
      while(!futureDestinations[i].isValid())
        i = (i + 1) % CBufferSize;
      head = i;
      validElements--;
    }
    futureDestinations[pos] = Address(address);
    futureDestinations[pos].enable();
    nextPos = (pos + 1) % CBufferSize;
    validElements++;
    return pos;
  }

  void pop(int pos) {
    lock_guard<mutex> lk(futureDestinations_mutex);
    if (pos == head) {
      int i = (head + 1) % CBufferSize;
      while(!futureDestinations[i].isValid())
        i = (i + 1) % CBufferSize;
      head = i;
    }
    futureDestinations[pos].disable();
    validElements--;
  }

  void show() {
    lock_guard<mutex> lk(futureDestinations_mutex);
    cout << "Cbuffer" << endl << "_________________" << endl;
    cout << "size = " << validElements << endl;
    cout << "head = " << head << endl;
    int counter = 0;
    int i = head;
    while (counter < CBufferSize) {
      if (futureDestinations[i].isValid())
        printf("%" PRIu32 "\n", futureDestinations[i].getAddress());
      i = (i + 1) % CBufferSize;
      counter++;
    }
    cout << "*********" << endl;
  }
};

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

  virtual ~MLController () {}

private:
  ConcurrentCBuffer c;

  char* showAddr(uint32_t ip) {
    struct in_addr ip_addr;
    ip_addr.s_addr = htonl(ip);
    return inet_ntoa(ip_addr);
  }
};

BM_REGISTER_EXTERN(MLController);
BM_REGISTER_EXTERN_METHOD(MLController, simulate_computation);
BM_REGISTER_EXTERN_METHOD(MLController, print);
BM_REGISTER_EXTERN_METHOD(MLController, pushAddr, const Data&, Data&, const Data&);
BM_REGISTER_EXTERN_METHOD(MLController, popAddr, const Data&, const Data&);

int import_ml_controller() {
  return 0;
}
