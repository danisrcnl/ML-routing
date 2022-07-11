import numpy as np
import random

def decision (probability):
    return random.random() < probability



hosts = ["h1", "h2", "h3", "h4"]
unused = {}
for host in hosts:
    offset = (int(host[1]) - 1) * 4
    ports = {}
    ports["10.5.1.2"] = str(5566 + offset)
    ports["10.6.2.2"] = str(5567 + offset)
    ports["10.7.3.2"] = str(5568 + offset)
    ports["10.8.4.2"] = str(5569 + offset)
    if host == "h1":
        hosts = ["10.6.2.2", "10.7.3.2", "10.8.4.2"]
        unused["10.5.1.2"] = ports["10.5.1.2"]
        sport = ["5566", "5570", "5574"]
    if host == "h2":
        hosts = ["10.5.1.2", "10.7.3.2", "10.8.4.2"]
        unused["10.6.2.2"] = ports["10.6.2.2"]
        sport = ["5567", "5571", "5575"]
    if host == "h3":
        hosts = ["10.5.1.2", "10.6.2.2", "10.8.4.2"]
        unused["10.7.3.2"] = ports["10.7.3.2"]
        sport = ["5568", "5572", "5576"]
    if host == "h4":
        hosts = ["10.5.1.2", "10.6.2.2", "10.7.3.2"]
        ports = unused
        sport = ["5569", "5573", "5577"]
    f = open(host + "_server.sh", "w")
    f.write("#!/bin/bash\n\n")
    f.write("iperf3 -s -p " + sport[0] + " & iperf3 -s -p " + sport[1] + " & iperf3 -s -p " + sport[2])
    f = open("cl_" + host + "_iperf.sh", "w")
    f.write("#!/bin/bash\n\n")
    ar = np.random.choice(range(10, 15), size = 50, replace = True)
    counter = 0
    for elem in ar:
        ipaddr = random.choice(hosts)
        port = ports[ipaddr]
        cmd = "iperf3 -c " + ipaddr + " -p " + port + " -t " + str(elem) + " -b 100M\n"
        f.write(cmd)
        if decision(0.2):
            time = random.sample(range(1, 5), 1)
            cmd = "sleep " + str(time[0]) + "\n"
            f.write(cmd)
        counter += 1

    f.close()
