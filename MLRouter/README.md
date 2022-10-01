# How to run ML-Router

## Intro

To run ML Router we need to run, at the same time, 3 different applications:

- **iPerf3**: an application capable of establishing UDP or TCP communications between two nodes of a network with customizable parameters. We use it to make hosts of the network send packets to each other that can go through the ML Routers.

- **P4 programs**: in charge of implementing the data plane of the network devices and communicating with the Reinforcement Learning module

- **Baselines scripts**: in charge of implementing the control plane of the devices. At training time they evaluate data coming from the network to compute the optimal behavior for the routers, while at runtime (will be also called "playing" time) they use the created models to route packets.

## How-to

- if not done already, generate **iperf** scripts, using the provided generator of scripts:
```bash
python geniperf.py
```
-run **baselines**:

  + if training:
```bash
./runbaselines.sh
sudo p4run
```

  + if playing:
```bash
./runbaselines2.sh
sudo p4run
```

- in the **mininet terminal** which will be opened:
```bash
xterm h1 h2 h3 h4
```

- once the 4 terminals pop up you can launch the correspondig **iperf server script** in each of them. E.g., in h1:
```bash
./h1_server.sh
```

- go back to the **mininet terminal** and open again the 4 terminals to launch the client scripts
```bash
xterm h1 h2 h3 h4
```

- once the 4 terminals pop up you can launch the correspondig **iperf client script** in each of them:
```bash
./cl_hostname_iperf.sh
```
with hosname equal to one among h1, h2, h3, h4

- training/game will start as packets are beginning to travel across routers

(Consider that to enable routers stop simultaneously at training time and be useful at playing time some LOCs in deepq.py of baselines have been modified. As soon as possible these modifications will be included into this repository).
