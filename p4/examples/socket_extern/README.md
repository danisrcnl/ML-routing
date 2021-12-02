# Socket extern example

## Overview

There are basically 3 core modules you should be aware of:

- **socket_extern.cpp**: implemented in networking/p4/bmv2/targests/simple_switch, is the class responsible of creating a socket with the running python server and exchange data with it.
It's implemented as an extern, thus its methods can be called by the p4 program itself.

- **server.py**: basically a socket-based server which is meant for receiving a value (in this example a 32-bit number) from socket_extern.cpp and doubling it. The doubled value is sent back to the C++ application, which stores the updated value into its *data* private attribute.

- **socket_extern.p4**: is the p4 application which declares the extern interface for socket_extern. Inside its MyIngress control block, it creates an instance of this extern and uses it to send a simple value (1) to the python server, then stores the (hopefully) updated value held by the C++ class inside myvar (a 32-bit variable declared in MyIngress scope), which should be 2. Finally, it prints out the updated value on its log file to check everything worked fine.

## Usage

Be sure you've installed all the modules provided into the root folder of the repository. First of all start the python server (be sure to start it with **Python3**, better if using a virtual environment. If you don't know how to, networking/rl/README.md contains a paragraph which explains the procedure)

```bash
python server.py
```

Then start the p4 application

```bash
sudo p4run
```

Now mininet should start on your shell and you should be able to interact with its CLI. Enter into the only switch we instantiated

```bash
mininet > xterm h1
```

A shell should open for the selected node (h1) and, from there, you can launch the python script that sends a packet to the switch

```bash
python send_packet.py
```

The send_packet script is thought for **Python2**.

## Considerations

Look at log/s1.log file that should generate into this folder and you should be able to find some log lines printed by the C++ extern. You should notice that:

- after calling sendData(myvar), the custom C++ extern module prints 1, i.e. the value stored by myvar at the beginning of socket_test action block of p4 application
```txt
[socket_extern.cpp] socket_extern.sendData received: [1]
```

- the socket was correctly created and value has been sent to the server. In the same method the value received by the server has been stored in its private data attribute
```txt
[socket_extern.cpp] Into createConnection()
[socket_extern.cpp] SOCKET OPENED
[socket_extern.cpp] attempting to connect to server
[socket_extern.cpp] connection successful
[socket_extern.cpp] into sendValue()
```

- when printData(myvar) has been called it should print the value stored into myvar. Since we called getData(myvar), we expect that myvar value should have been updated with the double of the initial value. If everything went good, the log should print this line
```txt
[socket_extern.cpp] socket_extern.printData gave: [2]
```
