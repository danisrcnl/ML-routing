# ML routing

## Table of contents
- [Overview](#overview)
- [Directories summary](#directories-summary)
- [How to install](#how-to-install)

## Overview
This repository contains a Reinforcement Learning solution to the problem of **routing**.

**ML Router** is the result of the interaction between a P4 and a Python program, both running on each device to concur in evaluating optimal routes according to data collected by the network.

The repository also contains an example which can be run thanks to some tools (e.g., mininet, p4-utils) that make it possible to emulate a network composed by 8 routers and 4 hosts.

## Directories summary

### MLRouter
Contains the toy example of the implementation.

### Behavioral Model (bmv2)
This is the second version of the reference P4 software switch, nicknamed bmv2 (for behavioral model version 2). The software switch is written in C++11. It takes as input a JSON file generated from your P4 program by a P4 compiler and interprets it to implement the packet-processing behavior specified by that P4 program.

*bmv2/targets/simple_switch* contains the custom **externs** implemented to support features which are not native to P4.

### Examples
Folder containing **instructions for installing the repository** and a guide to implement a custom extern in this context. The directory also provides a bunch of toy examples to show how do externs work.

### p4c
p4c is a reference compiler for the P4 programming language. It's been modified to support custom extern implementation basing on [this repository](https://github.com/engjefersonsantiago/p4-programs).

### Reinforcement Learning (rl)
Directory in charge of storing all the code relative to the interaction with baselines, guide to its installation and to gym-custom-environments creation. Also the implementation of the Network Environment created to interact with baselines is there.

## How to install

- the **prerequisites** are some libraries and tools (e.g., mininet, p4utils) which were provided by a VM created by [ngs-ethz](https://github.com/nsg-ethz/p4-learning). Unfortunately it's no longer offered officially by the creators so that it's up to the contributor managing to find it or installing the correct versions of missing libraries. As long as the VM has been installed and opened, versions of bmv2 and p4c will already be inside them.

- replace the existing **bmv2** folder with the one contained into this repository and execute the following commands:
```bash
cd bmv2
./autogen.sh
./configure
make -j4
sudo make install
```

- replace the existing **p4c** folder with the one contained into this repository and execute the following commands:
```bash
cd p4c
./bootstrap.sh
cd build
make -j4
sudo make install
```

- **p4c-bmv2**
```bash
cd p4c-bmv2
pip install -r requirements_v1_1.txt
```
