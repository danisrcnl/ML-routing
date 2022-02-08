# Custom modules
Some modules have been added to the original simple_switch environment and they are listed below.

## ccbuffer.h
Class which implements a circular buffer whose methods are protected from concurrent accesses by means of a mutex that is acquired at the beginning of any read/write operation.

Its size is set to 100 elements of Address type (defined in address.h). The elements are provided with a validity bit needed to keep unchanged the index where each element is stored at. We need a way of uniquely (as long as the buffer is well dimensioned) identify each insertion in the buffer from P4 to C++ class. This is done returning back to the p4 application the index the current address has been stored at and that index will be used to call the pop operation at the end of the computation.

This class will be demanded of storing the future destinations at the time each packet is processed. Every time a new packet comes into the MyIngress block of simple_switch router, a push of its address is called and the buffer (virtual) size increases.
Once it reaches the MyEgress block, it's popped.

## address.h
Data structure in charge of storing an unsigned 32-bit integer, i.e. the ipv4 address, along with a validity bit which states whether the object is in the circular buffer or not. It just exposes getters, setters and constructors.

## pymodule.h
It basically implements an interface to the python application which is meant to be running inside the device to perform the ML operations. Taking advantage of sockets, it lets the MLController communicate with a python server, accepting connections on a given port (address is localhost).

It basically exposes two methods:
- getPort: it takes a socket file descriptor, current destination and a concurrent circular buffer as parameters and, after having established the connection with the python server, it sends back the output port for that packet basing on those parameters (current destination, future destinations plus action history for that destination which is handled directly by the python endpoint).

- sendReward: it is meant for sending back the queuing time for a packet whose port has been determined by means of getPort method. That value will be the reward for the RL algorithm running.

## MLController.cpp
Extern which exposes to P4 the methods useful to push and pop address into the circular buffer (including ccbuffer.h) and to communicate with the python module (including pymodule.h) to get at runtime the output port for each of the incoming packets and send back statistics.
