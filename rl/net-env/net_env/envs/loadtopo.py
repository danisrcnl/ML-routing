import json

class Topology:
    def __init__ (self):
        self.switches = []
        self.hosts = []
        self.nodes = {}

    def addSwitch (self, name):
        self.switches.append(name)
        if not name in self.nodes:
            self.nodes[name] = {}

    def addHost (self, name):
        self.hosts.append(name)
        if not name in self.nodes:
            self.nodes[name] = {}

    def addLink (self, node1, node2, port_node1, port_node2):
        if not port_node1 in self.nodes[node1]:
            if port_node1 is not "":
                self.nodes[node1][port_node1] = node2
        if not port_node2 in self.nodes[node2]:
            if port_node2 is not "":
                self.nodes[node2][port_node2] = node1

    def getSwitches (self):
        return self.switches

    def getHosts (self):
        return self.hosts

    def getNodes (self):
        return self.nodes

    def getNeighbor (self, node, port):
        return self.nodes[node][port]

    def show (self):
        print("====**** Topology ****====")
        print("== Switches ==")
        for s in self.switches:
            print(s, "connects to:")
            for key in self.nodes[s].keys():
                print("\t*", self.nodes[s][key], "on port", key)
        print("== Hosts ==")
        for h in self.hosts:
            print(h, "connects to:")
            for key in self.nodes[h].keys():
                print("\t*", self.nodes[h][key], "on port", key)


def readtopo (topology):
    f = open("topology.db")
    topo = json.load(f)
    for s in topology.getSwitches():
        for interface in topo[s]["interfaces_to_node"].keys():
            topology.addLink(s, topo[s]["interfaces_to_node"][interface], interface, "")
    for h in topology.getHosts():
        for interface in topo[h]["interfaces_to_node"].keys():
            topology.addLink(h, topo[h]["interfaces_to_node"][interface], interface, "")

def readp4app (topology):
    f = open("p4app.json")
    p4app = json.load(f)
    for key in p4app['topology']['switches'].keys():
        topology.addSwitch(key)
    for key in p4app['topology']['hosts'].keys():
        topology.addHost(key)

def loadtopology ():
    topology = Topology()
    readp4app(topology)
    readtopo(topology)
    return topology


loadtopology()
