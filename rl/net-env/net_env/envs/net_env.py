import gym
from gym import spaces
import socket
import struct
import itertools
import collections
import numpy as np
import json
import os
import loadtopo as topo

PORT, HOST_IP = 1400, '0.0.0.0'
MAX = 4294967295

def makeRw (distance, qtime):
    if qtime == 0:
        qtime = 1
    if distance == 0:
        distance = 1
    return (1/(distance*10)) + (1/qtime)

def fill (vec, max):
    if (len(vec) < max):
        for i in range (0, max - len(vec)):
            vec.append(0)
        return vec
    else:
        return vec

actionHistory = {}
def addAction (curDst, action):
    if actionHistory.get(curDst) is None:
        actionHistory[curDst] = collections.deque([action], 5)
    else:
        actionHistory[curDst].append(action)
def getActions (curDst):
    if actionHistory.get(curDst) is None:
        return []
    else:
        return actionHistory[curDst]


class FutureDestinations:
    def __init__ (self):
        self.curDst = 0
        self.size = 5
        self.dsts = collections.deque(maxlen = 5)

    def pushDst (self, dst):
        self.dsts.append(int(dst))

    def setSize (self, size):
        self.size = int(size)

    def setCurDst (self, dst):
        self.curDst = int(dst)

    def getCurDst (self):
        return self.curDst

    def getDsts (self):
        return self.dsts

    def reset (self):
        self.dsts = []
        self.curDst = 0
        self.size = 0

    def show (self):
        print("Number of future destinations:", len(self.dsts))
        print("Current destination:", self.curDst)
        print("List of future destinations:")
        for dst in self.dsts:
            print(dst)

class State:
    def __init__ (self):
        self.destinations = FutureDestinations()
        self.prevActions = []
    def setDsts (self, destinations):
        self.destinations = destinations
        self.prevActions = getActions(self.destinations.getCurDst())
    def getCurDst (self):
        return self.destinations.getCurDst()
    def show (self):
        print("Future destinations: ")
        self.destinations.show()
        print("Previous actions: ", self.prevActions)
    def makeNPArray (self):
        firstrow = []
        firstrow.append(self.destinations.getCurDst())
        array = np.array(object = [fill(firstrow, 5), fill(self.destinations.getDsts(), 5), fill(self.prevActions, 5)])
        return array


class Packet:
    def __init__ (self, destinations, reward):
        self.futureDestinations = destinations
        self.reward = reward

    def getDsts (self):
        return self.futureDestinations

    def getReward (self):
        return self.reward

    def show (self):
        print("***************************")
        print("Packet:")
        print("Future Destinations:")
        self.futureDestinations.show()
        print("Last reward:", self.reward)
        print("***************************")


def parse_req (data):
    strdata = data.decode('UTF-8')
    print(strdata)
    parsed = strdata.split(' ')
    if parsed[0] == 'GETP':
        destinations = FutureDestinations()
        size = int(parsed[1])
        dst = int(parsed[2])
        destinations.setCurDst(dst)
        lastRw = int(parsed[3])
        max = 4 + size
        for i in range(4, max):
            destinations.pushDst(parsed[i])
        pkt = Packet(destinations, lastRw)
        return pkt

class NetEnv (gym.Env):

    def __init__ (self, nports, id, port):
        self.nports = nports
        self.id = id
        print("initialized with nports =", nports, ", id =", id)
        self.action_space = spaces.Discrete(self.nports)
        self.observation_space = spaces.Box(low = 0, high = MAX, shape=(3, 5))
        self.state = State()
        self.pkt = Packet(0, 0)
        self.port = port
        self.firstRun = True
        self.node = None
        self.topology = None

        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            self.s = s
            self.s.bind((HOST_IP, self.port))
            self.s.listen()
            while True:
                print("listening on address " + HOST_IP + ", port " + str(self.port) + "...")
                self.conn, self.addr = self.s.accept()
                print("connected by", self.addr)
                if self.firstRun:
                    self.topology = topo.loadtopology()
                    self.node = self.topology.getNode(id)
                    self.firstRun = False
                return

    def step (self, action):
        action = action + 1 # because action goes from 0 to N-1, while ports are counted from 1 to N
        info = {}
        # action contains the # of the port the packet must be forwarded to

        # send action back on socket
        # store action in action history
        ret = action
        addAction(self.state.getCurDst(), action)
        sendBack = struct.pack('I', ret)
        self.conn.sendall(sendBack)

        ifname = self.id + "-eth" + str(action)
        interface = self.node.getPort(ifname)
        targetNode = self.topology.getNodeByIp(self.state.getCurDst())
        if interface.getName() == "none":
            print("didn't find interface", ifname)
            distance = 1
        else:
            neighbor = interface.getNeighbor()
            if targetNode == "error":
                print("didn't find target node")
                distance = 1
            else:
                if "h" in neighbor.getName():
                    if targetNode == neighbor.getName():
                        distance = 0.001
                    else:
                        distance = 100
                else:
                    distance = neighbor.getDistance(targetNode)

        # listen on socket
            # as msg arrives store fields in state(t + 1) and reward(t)

        try:
            data = self.conn.recv(512)
            if not data:
                print("no data")
                return self.state.makeNPArray(), self.pkt.getReward(), True, info
            print("================ Packet received! ================")
            self.pkt = parse_req(data)
            self.pkt.show()
            self.state.setDsts(self.pkt.getDsts())
        except Exception as e:
            print("Exception occured:", e)
            self.conn.close()
            self.s.close()

        done = False
        rw = makeRw(distance, self.pkt.getReward())
        print("Sending back reward of", rw)
        return self.state.makeNPArray(), rw, done, info

    def reset (self):
        # listen on socket
            # as msg arrives store fields in state, drop reward

        try:
            data = self.conn.recv(512)
            if not data:
                return
            print("================ Packet received! ================")
            pkt = parse_req(data)
            self.state.setDsts(pkt.getDsts())
        except Exception:
            self.conn.close()
            self.s.close()
