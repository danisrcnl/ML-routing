# ML routing
## Directories summary

### Behavioral Model (bmv2)
This is the second version of the reference P4 software switch, nicknamed bmv2 (for behavioral model version 2). The software switch is written in C++11. It takes as input a JSON file generated from your P4 program by a P4 compiler and interprets it to implement the packet-processing behavior specified by that P4 program.

*bmv2/targets/simple_switch* contains the custom **externs** implemented to support features which are not native to P4.

### Examples
Folder containing **instructions for installing the repository** and a guide to implement a custom extern in this context. The directory also provides a bunch of toy examples to show how do externs work.

### Mininet
Mininet creates virtual networks using process-based virtualization and network namespaces - features that are available in recent Linux kernels. In Mininet, hosts are emulated as bash processes running in a network namespace, so any code that would normally run on a Linux server (like a web server or client program) should run just fine within a Mininet "Host". The Mininet "Host" will have its own private network interface and can only see its own processes. Switches in Mininet are software-based switches like Open vSwitch or the OpenFlow reference switch. Links are virtual ethernet pairs, which live in the Linux kernel and connect our emulated switches to emulated hosts (processes).

### P4-Utils
P4-Utils is an extension to Mininet that makes P4 networks easier to build, run and debug. P4-utils is strongly inspired by p4app. Will be useful to run examples.

### p4c
p4c is a reference compiler for the P4 programming language.

### Reinforcement Learning (rl)
Directory in charge of storing all the code relative to the interaction with baselines.
