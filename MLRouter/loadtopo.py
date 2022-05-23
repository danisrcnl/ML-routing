import json
import socket
import struct

def ip2long(ip):
    splitted = ip.split("/")
    packedIP = socket.inet_aton(splitted[0])
    return struct.unpack("!L", packedIP)[0]

class Port:
    def __init__ (self, name):
        self.name = name
        self.mac = None
        self.neighbor = None
        self.ip = None

    def setMac (self, mac):
        self.mac = mac

    def setIp (self, ip):
        self.ip = ip

    def setNeighbor (self, neighbor):
        self.neighbor = neighbor

    def getName (self):
        return self.name

    def getMac (self):
        return self.mac

    def getIp (self):
        return self.ip

    def getNeighbor (self):
        return self.neighbor

class Node:
    def __init__ (self, name):
        self.name = name
        self.ports = {}
        self.distances = {}

    def getName (self):
        return self.name

    def addPort (self, port):
        self.ports[port.getName()] = port

    def getPort (self, portName):
        if portName in self.ports.keys():
            return self.ports[portName]
        else:
            return Port("none")

    def getPorts (self):
        return self.ports

    def addDistance (self, node, distance):
        self.distances[node] = distance

    def getDistance (self, node):
        print("getting distance of", self.name, "from", node)
        return self.distances[node]

    def getDistances (self):
        return self.distances

class Topology:
    def __init__ (self):
        self.switches = []
        self.hosts = []
        self.nodes = []

    def getNode (self, name):
        filter = lambda x: x.getName() == name
        for x in self.nodes:
            if filter(x):
                return x
        return Node("error")

    def addSwitch (self, name):
        s = Node(name)
        self.switches.append(s)
        self.nodes.append(s)

    def addHost (self, name):
        h = Node(name)
        self.hosts.append(h)
        self.nodes.append(h)

    def addLink (self, node1, node2, port_node1, port_node2):
        n1 = self.getNode(node1)
        if n1.getName() == "error":
            return
        n2 = self.getNode(node2)
        if n2.getName() == "error":
            return
        if not port_node1 in n1.getPorts():
            if port_node1 is not "":
                p = Port(port_node1)
                p.setNeighbor(n2)
                n1.addPort(p)

        if not port_node2 in n2.getPorts():
            if port_node2 is not "":
                p = Port(port_node2)
                p.setNeighbor(n1)
                n2.addPort(p)

    def setAddresses (self, node, port, mac, ip):
        n = self.getNode(node)
        if not port in n.getPorts():
            return
        n.getPort(port).setMac(mac)
        n.getPort(port).setIp(ip)

    def getSwitches (self):
        return self.switches

    def getHosts (self):
        return self.hosts

    def getNodes (self):
        return self.nodes

    def getNeighbor (self, node, port):
        n = self.getNode(node)
        return n.getPort(port).getNeighbor()

    def getNodeByIp (self, ip):
        for node in self.nodes:
            for portname in node.getPorts():
                port = node.getPort(portname)
                ip_long = ip2long(port.getIp())
                if ip_long == ip:
                    return node.getName()
        return "error"

    def show (self):
        print("====**** Topology ****====")
        print("\n\n== Switches ==")
        for s in self.switches:
            print(s.getName(), "interfaces:")
            for p in s.getPorts():
                port = s.getPort(p)
                print("\t*", port.getName(), "[ mac: ", port.getMac(), " ip: ", port.getIp(), "] connected to ", port.getNeighbor().getName())
            print("\tDistances:")
            for key in s.getDistances():
                print("\t*", s.getDistances()[key], "from", key)
            print("\n")
        print("\n\n== Hosts ==")
        for h in self.hosts:
            print(h.getName(), "interfaces:")
            for p in h.getPorts():
                port = h.getPort(p)
                print("\t*", port.getName(), "[ mac: ", port.getMac(), " ip: ", port.getIp(), "] connected to ", port.getNeighbor().getName())
            print("\n")

def readtopo (topology):
    f = open("topology.db")
    topo = json.load(f)
    for s in topology.getSwitches():
        for interface in topo[s.getName()]["interfaces_to_node"].keys():
            neighbor = topo[s.getName()]["interfaces_to_node"][interface]
            topology.addLink(s.getName(), neighbor, interface, "")
            topology.setAddresses(s.getName(), interface, topo[s.getName()][neighbor]["mac"], topo[s.getName()][neighbor]["ip"])
    for h in topology.getHosts():
        for interface in topo[h.getName()]["interfaces_to_node"].keys():
            neighbor = topo[h.getName()]["interfaces_to_node"][interface]
            topology.addLink(h.getName(), neighbor, interface, "")
            topology.setAddresses(h.getName(), interface, topo[h.getName()][neighbor]["mac"], topo[h.getName()][neighbor]["ip"])

def readp4app (topology):
    f = open("p4app.json")
    p4app = json.load(f)
    for key in p4app['topology']['switches'].keys():
        topology.addSwitch(key)
    for key in p4app['topology']['hosts'].keys():
        topology.addHost(key)

def readDistances (topology):
    f = open("distances.json")
    distances = json.load(f)
    for s1 in distances.keys():
        node = topology.getNode(s1)
        for s2 in distances[s1].keys():
            node.addDistance(s2, distances[s1][s2])

def loadtopology ():
    topology = Topology()
    readp4app(topology)
    readtopo(topology)
    readDistances(topology)
    topology.show()
    return topology
