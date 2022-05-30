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
#include <fstream>
#include <arpa/inet.h>
#include "address.h"

#define PORT "1500"
#define IP "0.0.0.0"
#define LOG_ccb "[ccbuffer.h] "
#define CBufferSize 30
using namespace std;

class ConcurrentCBuffer {
private:
  array<Address, CBufferSize> futureDestinations;
  mutex futureDestinations_mutex;
  int head;
  mutex head_mutex;
  int validElements;
  mutex validElements_mutex;
  int nextPos;
  bool debug = true;

public:
  ConcurrentCBuffer () {
    futureDestinations.fill(Address());
    head = 0;
    validElements = 0;
    nextPos = 0;
    ofstream ofs;
    ofs.open("ccbufferlog.txt", std::ofstream::out | std::ofstream::trunc);
    ofs.close();
  };
  ~ConcurrentCBuffer () {};

  uint32_t get(int pos) {
    if (debug) cout << LOG_ccb << "get is waiting for futureDestinations_mutex" << endl;
    lock_guard<mutex> lk(futureDestinations_mutex);
    if (debug) cout << LOG_ccb << "futureDestinations_mutex acquired from get" << endl;
    return futureDestinations[pos].getAddress();
  }

  int push(uint32_t address) {
    if (debug) cout << LOG_ccb << "push is waiting for futureDestinations_mutex" << endl;
    lock_guard<mutex> lk(futureDestinations_mutex);
    if (debug) cout << LOG_ccb << "futureDestinations_mutex acquired from push" << endl;
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
    if (debug) cout << LOG_ccb << "Inserted element at pos " << pos << endl;
    nextPos = (pos + 1) % CBufferSize;
    if (debug) cout << LOG_ccb << "Next post is " << nextPos << endl;
    validElements++;
    return pos;
  }

  void pop(int pos) {
    if (debug) cout << LOG_ccb << "pop is waiting for futureDestinations_mutex" << endl;
    lock_guard<mutex> lk(futureDestinations_mutex);
    if (debug) cout << LOG_ccb << "futureDestinations_mutex acquired from pop" << endl;
    if (!futureDestinations[pos].isValid())
      return;
    int lasthead = head;
    if (pos == head) {
      int i = (head + 1) % CBufferSize;
      while(!futureDestinations[i].isValid())
        i = (i + 1) % CBufferSize;
      head = i;
      if (head == lasthead) // only if there was only that element in the q, then next one is going to be head
        head = nextPos;
    }
    futureDestinations[pos].disable();
    validElements--;
  }

  void show() {
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

  void show_full(string op, int pos) {
    ofstream ofs;
    ofs.open("ccbufferlog.txt", std::ios_base::app | std::ios_base::in);
    ofs << endl;
    if (op == "pop")
      ofs << "CCBuffer after pop called at pos " << std::to_string(pos) << endl;
    if (op == "push")
      ofs << "CCBuffer after push at pos " << std::to_string(pos) << endl;
    ofs << "Size is now " << validElements << endl;
    for (int i = 0; i < CBufferSize; i++) {
      string info = "";
      if (i == head)
        info += " <-- head";
      if (i == nextPos)
        info += " <-- nextPos";
      ofs << i << ") " << futureDestinations[i].getAddress() << " [" << futureDestinations[i].isValid() << "]" << info << endl;
    }
    ofs.close();
  }

  bool isValid(int pos) {
    return futureDestinations[pos].isValid();
  }

  int getHead() {
    if (debug) cout << LOG_ccb << "Waiting for head_mutex" << endl;
    lock_guard<mutex> lk(head_mutex);
    if (debug) cout << LOG_ccb << "head_mutex acquired" << endl;
    return head;
  }

  int currElems() {
    if (debug) cout << LOG_ccb << "Waiting for validElements_mutex" << endl;
    lock_guard<mutex> lk(validElements_mutex);
    if (debug) cout << LOG_ccb << "validElements_mutex acquired" << endl;
    return validElements;
  }
};

#endif
