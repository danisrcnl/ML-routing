#ifndef CBUFFER_H
#define CBUFFER_H

#include <bm/bm_sim/extern.h>
#include <unistd.h>
#include <iostream>
#include <array>
#include <mutex>
#include <cinttypes>
#include <thread>
#include <chrono>
#include <arpa/inet.h>
#include "address.h"

#define PORT "1500"
#define IP "0.0.0.0"
#define LOG_ccb "[ccbuffer.h] "
#define CBufferSize 100
using namespace std;

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

  bool isValid(int pos) {
    return futureDestinations[pos].isValid();
  }

  int getHead() { return head; }

  int currElems() { return validElements; }
};

#endif
