#include <bm/bm_sim/extern.h>
#include <chrono>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cstring>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include <malloc.h>
#include <stdexcept>
#include <netdb.h>

#define PORT "1500"
#define IP "0.0.0.0"

using namespace std;


template <typename... Args>
using ActionPrimitive = bm::ActionPrimitive<Args...>;

using bm::Data;
using bm::Header;
using bm::PHV;
using bm::ExternType;

class SocketExtern : public ExternType {
 public:
    BM_EXTERN_ATTRIBUTES {
    }

  // Init variables
    void init() override {
        std::cout << "socket_extern init called" << std::endl;
    }

    Data sendData(const Data& data) {
        createConnection();
        objectData *pointer = (objectData*) malloc(sizeof(objectData));
        Data d = static_cast<Data>(sendValue(pointer, data.get<int>()));
        free(pointer);
        closeConnection();
        return d;
    }

    // Default constructor/destructor
    virtual ~SocketExtern () {}

private:
    typedef struct objectData_struct {
        unsigned int value;
    } objectData;

    int sockfd, n;
    struct sockaddr_in serv_addr;
    char* buffer = (char*) malloc(sizeof(char)*256);
    char* sbuffer = (char*) malloc(sizeof(char)*256);

    void createConnection() {

        cout << "Into createConnection()" << endl;

        /* Create a socket point */
        sockfd = socket(AF_INET, SOCK_STREAM, 0);

        if (sockfd < 0) {
            throw std::runtime_error("error opening socket");
        } else if (sockfd > 0) {
            cout << "SOCKET OPENED" << endl;
        }

        serv_addr.sin_family = AF_INET;
        serv_addr.sin_port = htons(atoi(PORT));
        inet_pton(AF_INET, IP, &(serv_addr.sin_addr.s_addr));

        cout << "attempting to connect to server" << endl;

        int conn_success = connect(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

        if (conn_success < 0) {
            throw std::runtime_error("couldn't connect");
        } else {
            cout << "connection successful" << endl;
        }

    }

    void closeConnection() {
        close(sockfd);
    }

    int sendValue(objectData* a, int number) {

        cout << "into sendValue()" << endl;

        fd_set fds;
        struct timeval tv;
        tv.tv_sec = 0;
        tv.tv_usec = 0;


        FD_ZERO(&fds);
        FD_SET(sockfd, &fds);
        select(sockfd+1, &fds, NULL, NULL, &tv);

        memset(sbuffer, 0, strlen(sbuffer));
        sprintf(sbuffer, "%d", number);
        send(sockfd, sbuffer, sizeof(sbuffer), 0);

        while ((recv(sockfd, buffer, sizeof(buffer), 0)) <= 0);
        a = reinterpret_cast<objectData*>(buffer);
        cout << a->value << endl;

        return a->value;
    }
};

BM_REGISTER_EXTERN(SocketExtern);
BM_REGISTER_EXTERN_METHOD(SocketExtern, sendData, const Data &);

// End Declaration

int import_socket_extern() {
  return 0;
}
