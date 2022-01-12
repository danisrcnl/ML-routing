#include <bm/bm_sim/extern.h>
#include <iostream>
#include <array>
#include <mutex>
#include <cinttypes>

#define PORT "1500"
#define IP "0.0.0.0"
#define LOG "[test_addresses_extern.cpp] "
#define CBufferSize 100

using namespace std;

class ConcurrentCBuffer {
private:
  array<uint32_t, CBufferSize> futureDestinations;
  mutex futureDestinations_mutex;
  int head;
  int validElements;
  int nextPos;

public:
  ConcurrentCBuffer () {
    futureDestinations.fill(0);
    head = 0;
    validElements = 0;
    nextPos = 0;
  };
  ~ConcurrentCBuffer () {};

  uint32_t get(int pos) {
    lock_guard<mutex> lk(futureDestinations_mutex);
    return futureDestinations[pos];
  }

  int push(uint32_t address) {
    lock_guard<mutex> lk(futureDestinations_mutex);
    int pos = nextPos % CBufferSize;
    if (pos == head && validElements != 0) {
      int i = (head + 1) % CBufferSize;
      while(futureDestinations[i] == 0)
        i = (i + 1) % CBufferSize;
      head = i;
      validElements--;
    }
    futureDestinations[pos] = address;
    nextPos = (pos + 1) % CBufferSize;
    validElements++;
    return pos;
  }

  void pop(int pos) {
    lock_guard<mutex> lk(futureDestinations_mutex);
    if (pos == head) {
      int i = (head + 1) % CBufferSize;
      while(futureDestinations[i] == 0)
        i = (i + 1) % CBufferSize;
      head = i;
    }
    futureDestinations[pos] = 0;
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
      if (futureDestinations[i] != 0)
        printf("%" PRIu32 "\n", futureDestinations[i]);
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

  void pushAddr(const Data& address, Data& pos) {
    cout << LOG << "push called for address ";
    printf("%" PRIu32 "\n", address.get<uint32_t>());
    int ret = c.push(address.get<uint32_t>());
    pos = static_cast<Data>(ret);
  }

  void popAddr(const Data& pos) {
    cout << LOG << "pop called for element at pos = " << pos.get<int>() << endl;
    c.pop(pos.get<int>());
  }

  virtual ~TestAddressesExtern () {}

private:
  ConcurrentCBuffer c;
};

BM_REGISTER_EXTERN(TestAddressesExtern);
BM_REGISTER_EXTERN_METHOD(TestAddressesExtern, print);
BM_REGISTER_EXTERN_METHOD(TestAddressesExtern, pushAddr, const Data&, Data&);
BM_REGISTER_EXTERN_METHOD(TestAddressesExtern, popAddr, const Data&);

int import_test_addresses_extern() {
  return 0;
}
