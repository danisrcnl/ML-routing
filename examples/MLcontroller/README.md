# MLController example (with toy python module)

## Overview

There are basically 3 core modules you should be aware of:

- **MLController.cpp**: implemented in networking/p4/bmv2/targests/simple_switch, is the class responsible of implementing the communication between the P4 application and the Python application. It includes some smaller modules of the same directory (ccbuffer.h, address.h, rewardsQ.h, pymodule.h). It's implemented as an extern, thus its methods can be called by the P4 program itself.

- **fakeController.py**: basically a socket-based server which is meant for receiving data which will be useful to compute the correct output port for the incoming packet. Now, it just sends back always the same value, which is 1.

- **socket_extern.p4**: is the p4 application which declares the extern interface for MLController. Inside its MyIngress control block, it creates an instance of this extern and uses it to register the address of the current destination (as long as it's an IPv4 packet) into the list of future destinations. Additionally, it stores into pos variable (belonging to metadata) the index of current packet into the list, so that future operations can be related to the correct instance. Then, it calls getOutputPort method of MLController to choose the port the packet should be routed to.
In MyEgress block pop operation is done on the list, as the packet is going to leave the device. Immediately after, the reward (that's going to be queuing time, here it's always 1) is stored so that at the next packet, it will be communicate to the python module listening on the socket.

## Usage

Be sure you've installed all the modules provided into the root folder of the repository. First of all start the python server (be sure to start it with **Python3**, better if using a virtual environment. If you don't know how to, networking/rl/README.md contains a paragraph which explains the procedure)

```bash
python fakeController.py
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
python packet_sender.py
```

The send_packet script is thought for **Python2**.
