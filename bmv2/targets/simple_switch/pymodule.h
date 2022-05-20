#ifndef PYMODULE_H
#define PYMODULE_H

#include <bm/bm_sim/extern.h>
#include <unistd.h>
#include <iostream>
#include <array>
#include <mutex>
#include <cinttypes>
#include <thread>
#include <chrono>
#include <arpa/inet.h>
#include "ccbuffer.h"
#include <nlohmann/json.hpp>
#include <fstream>

#define IP "0.0.0.0"
#define LOG_py "[pymodule.h] "
#define CBufferSize 100
using namespace std;
using json = nlohmann::json;


class PyModule {
private:
  int n, totw = 0;
  struct sockaddr_in serv_addr;
  char buffer[400];
  char sbuffer[400];
  int sockfd;
  bool connected;
  bool created;
  int port = 1400;

  int getOffset (string name) {
    cout << LOG_py << "evaluating the offset..." << endl;
    int offset = 0;
    if (name[0] == 'l')
        offset += 10;
    offset = offset + name[1] - 48;
    cout << LOG_py << "offset set equal to " << offset << " [chosen port is " << port + offset << "]" << endl;

    return offset;
  }

  bool createConnection () {

    if (!created) {

      sockfd = socket(AF_INET, SOCK_STREAM, 0);

      if (sockfd < 0)
        throw std::runtime_error("couldn't create socket");
      else if (sockfd > 0) {
        cout << LOG_py << "socket created, sockfd = " << sockfd << endl;
        created = true;
      }

      serv_addr.sin_family = AF_INET;
      serv_addr.sin_port = htons(port);
      inet_pton(AF_INET, IP, &(serv_addr.sin_addr.s_addr));

    }

    cout << LOG_py << "attempting to connect to server" << endl;

    int conn_success = connect(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
    if (conn_success >= 0) {
      connected = true;
      cout << LOG_py << "succesfully connected to python module, with sockfd = " << sockfd << endl;
    }

    return connected;
  }

  void closeConnection () {
    close(sockfd);
  }

  void setPort (string name) {
    if (port != 1400)
      return;
    port += getOffset(name);
    cout << LOG_py << "Port has been set equal to " << port << endl;
  }
/*
  PyModule() {
    connected = false;
  }

  static PyModule* instance;
*/
public:

  //static PyModule* getInstance();

  PyModule (string host) {
    cout << LOG_py << "PyModule created" << endl;
    connected = false;
    created = false;
    setPort(host);
  }

  PyModule (const PyModule& source) {
    this->n = source.n;
    this->totw = source.totw;
    this->serv_addr = source.serv_addr;
    for (int i = 0; i < 400; i++) {
      this->buffer[i] = source.buffer[i];
      this->sbuffer[i] = source.sbuffer[i];
    }
    this->sockfd = source.sockfd;
    this->connected = source.connected;
    this->port = source.port;
  }

  PyModule (PyModule&& source) {
    this->n = source.n;
    this->totw = source.totw;
    this->serv_addr = source.serv_addr;
    for (int i = 0; i < 400; i++) {
      this->buffer[i] = source.buffer[i];
      this->sbuffer[i] = source.sbuffer[i];
    }
    this->sockfd = source.sockfd;
    this->connected = source.connected;
    this->port = source.port;
  }

  ~PyModule() {
    closeConnection();
  }

  int getPort (uint32_t address, uint32_t qTime, ConcurrentCBuffer& c) {
    if (!connected) {
      cout << LOG_py << "Not connected yet, creating connection" << endl;
      connected = createConnection();
    }
    if (!connected) {
      cout << LOG_py << "No py module listening, standard response given" << endl;
      return 0;
    }
    fd_set fds;
    struct timeval tv;
    char* ptr = sbuffer;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    FD_ZERO(&fds);
    FD_SET(sockfd, &fds);
    select(sockfd+1, &fds, NULL, NULL, &tv);
    memset(sbuffer, 0, sizeof(sbuffer));
    int written = sprintf(ptr, "%s ", "GETP");
    ptr += written;
    totw += written;
    written = sprintf(ptr, "%d ", c.currElems());
    ptr += written;
    totw += written;
    written = sprintf(ptr, "%d ", address);
    ptr += written;
    totw += written;
    written = sprintf(ptr, "%d ", qTime);
    ptr += written;
    totw += written;
    int idx = c.getHead();
    for (int i = 0; i < CBufferSize; i++){
      int pos = (idx + i) % CBufferSize;
      if (c.isValid(pos)) {
        written = sprintf(ptr, "%lu ", static_cast<long unsigned int>(c.get(pos)));
        ptr += written;
        totw += written;
      }
    }
    send(sockfd, sbuffer, sizeof(sbuffer), 0);
    int r = 0;
    while ((recv(sockfd, buffer, sizeof(buffer), 0)) <= 0);
    int* response = (int *) buffer;
    printf("%d\n", *response);
    r = *response;
    return r;
  }
};
/*

PyModule* PyModule::instance = 0;

PyModule* PyModule::getInstance () {
  if (instance == 0)
    instance = new PyModule();
  return instance;
}
*/
#endif
