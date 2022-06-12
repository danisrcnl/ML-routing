import random
hosts = ["h1", "h2", "h3", "h4"]
for host in hosts:
    ports = {}
    ports["10.5.1.2"] = "5566"
    ports["10.6.2.2"] = "5567"
    ports["10.7.3.2"] = "5568"
    ports["10.8.4.2"] = "5569"
    if host == "h1":
        hosts = ["10.6.2.2", "10.7.3.2", "10.8.4.2"]
    if host == "h2":
        hosts = ["10.5.1.2", "10.7.3.2", "10.8.4.2"]
    if host == "h3":
        hosts = ["10.5.1.2", "10.6.2.2", "10.8.4.2"]
    if host == "h4":
        hosts = ["10.5.1.2", "10.6.2.2", "10.7.3.2"]
    f = open(host + "_iperf.sh", "a")
    f.write("#!/bin/bash\n\n")
    for i in range(1, 5):
        ar = random.sample(range(10, 45), 10)
        for elem in ar:
            ipaddr = random.choice(hosts)
            port = ports[ipaddr]
            cmd = "iperf -c " + ipaddr + " -p " + port + " -t " + str(elem) + " -u\n"
            f.write(cmd)
    f.close()
