#ifndef ADDRESS_H
#define ADDRESS_H

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

#endif
