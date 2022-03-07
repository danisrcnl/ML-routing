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

#define PORT "1500"
#define IP "0.0.0.0"
#define LOG_py "[pymodule.h] "
#define CBufferSize 100
using namespace std;

class PyModule {
private:
  int n, totw = 0;
  struct sockaddr_in serv_addr;
  char buffer[400];
  char sbuffer[400];
  int sockfd;

  void createConnection() {
    sockfd = socket(AF_INET, SOCK_STREAM, 0);

    if (sockfd < 0)
        throw std::runtime_error("couldn't create socket");
    else if (sockfd > 0)
        cout << LOG_py << "socket created, sockfd = " << sockfd << endl;

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(atoi(PORT));
    inet_pton(AF_INET, IP, &(serv_addr.sin_addr.s_addr));

    cout << LOG_py << "attempting to connect to server" << endl;

    int conn_success = connect(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
    if (conn_success < 0)
        throw std::runtime_error("couldn't find python module listening");
    else
        cout << LOG_py << "succesfully connected to python module, with sockfd = " << sockfd << endl;
  }

  void closeConnection () {
    close(sockfd);
  }

public:

  PyModule() {
    createConnection();
  }

  ~PyModule() {
    closeConnection();
  }

  int getPort(uint32_t address, uint32_t qTime, ConcurrentCBuffer& c) {
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

#endif
