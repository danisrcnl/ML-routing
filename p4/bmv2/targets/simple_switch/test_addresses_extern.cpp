#include <bm/bm_sim/extern.h>
#include <iostream>
#include <array>
#include <mutex>
#include <cinttypes>
#include <arpa/inet.h>

#define PORT "1500"
#define IP "0.0.0.0"
#define LOG "[test_addresses_extern.cpp] "
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
    if (address == 0) return -1;
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

class TestAddressesExtern : public ExternType {
 public:

  BM_EXTERN_ATTRIBUTES {
  }

  void init() override {
    cout << LOG << "init called" << endl;
  }

  void print() {
    cout << LOG << "print called" << endl;
    c.show();
  }

  void pushAddr(const Data& address, Data& pos, Data& valid_bool) {
    cout << LOG << "push called for address " << showAddr(address.get<uint32_t>()) << endl;
    int ret = c.push(address.get<uint32_t>());
    int val = 1;
    if (ret == -1) {
      val = 0;
      ret = 0;
      return;
    }
    valid_bool = static_cast<Data>(val);
    pos = static_cast<Data>(ret);
  }

  void popAddr(const Data& pos, const Data& valid_bool) {
    if (valid_bool.get<int>() == 0)
      return;
    cout << LOG << "pop called for element at pos = " << pos.get<int>() << endl;
    c.pop(pos.get<int>());
  }

  virtual ~TestAddressesExtern () {}

private:
  ConcurrentCBuffer c;

  char* showAddr(uint32_t ip) {
    struct in_addr ip_addr;
    ip_addr.s_addr = ip;
    return inet_ntoa(ip_addr);
  }
};

BM_REGISTER_EXTERN(TestAddressesExtern);
BM_REGISTER_EXTERN_METHOD(TestAddressesExtern, print);
BM_REGISTER_EXTERN_METHOD(TestAddressesExtern, pushAddr, const Data&, Data&, Data&);
BM_REGISTER_EXTERN_METHOD(TestAddressesExtern, popAddr, const Data&, const Data&);

int import_test_addresses_extern() {
  return 0;
}
