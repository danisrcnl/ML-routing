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
from math import log
import matplotlib.pyplot as plt

PORT, HOST_IP = 1400, '0.0.0.0'
MAX = 4294967295
AH_LENGTH = 2 # max 5
FD_LENGTH = 2 # max 5
LAMBDA1 = 1
LAMBDA2 = 5 #0.5
LAMBDA3 = 1
LAMBDA4 = 0.005 #0.0005
NHOSTS = 4
MAXPORTS = 5
MAXQTIME = 10000
MINQTIME = 0
MINDISTANCE = 1
MAXDISTANCE = 4
PLOT_FREQ = 1000
PLOT_SOIL = 0
MEANSTEP = 250

def minRw (isBackbone):
    delta1 = 0
    if isBackbone:
        delta3 = 0
        delta4 = 1
    else:
        delta3 = 1
        delta4 = 0
    seconds = MAXQTIME / 1000000
    #seconds = 10
    rw1 = LAMBDA1 * delta1
    rw2 = LAMBDA2 * seconds
    rw3 = LAMBDA3 * delta3
    rw4 = LAMBDA4 * delta4 * MAXDISTANCE
    rw = 0 + rw1 - rw2 - rw3 - rw4
    return rw

def maxRw (isBackbone):
    if isBackbone:
        delta1 = 0
        delta4 = 1
    else:
        delta1 = 1
        delta4 = 0
    delta3 = 0
    seconds = MINQTIME / 1000000
    #seconds = 0
    rw1 = LAMBDA1 * delta1
    rw2 = LAMBDA2 * seconds
    rw3 = LAMBDA3 * delta3
    rw4 = LAMBDA4 * delta4 * MINDISTANCE
    rw = 0 + rw1 - rw2 - rw3 - rw4
    return rw

def makeRw (distance, qtime, dropped):
    delta1 = 1
    delta3 = dropped
    if delta3 == 1:
        delta1 = 0
    rw1 = LAMBDA1 * delta1 * (1 / (distance + 1))
    rw2 = LAMBDA2 * (1 / log(qtime + 10, 10))
    rw3 = LAMBDA3 * delta3
    rw = rw1 + rw2 - rw3
    return rw1, rw2, rw3, rw

def makeRw2 (distance, qtime, dropped, delivered, isBackbone):
    delta1 = delivered
    delta3 = dropped
    if isBackbone:
        delta4 = 1
    else:
        delta4 = 0
    if delta3 == 1:
        delta1 = 0
    if qtime > MAXQTIME:
        qtime = MAXQTIME
    seconds = qtime / 1000000
    rw1 = LAMBDA1 * delta1
    rw2 = LAMBDA2 * seconds
    rw3 = LAMBDA3 * delta3
    rw4 = LAMBDA4 * delta4 * distance
    rw = 0 + rw1 - rw2 - rw3 - rw4
    return rw1, rw2, rw3, rw4, rw

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
        actionHistory[curDst] = collections.deque([action], AH_LENGTH)
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
        self.dsts = collections.deque(maxlen = FD_LENGTH)

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
    def __init__ (self, nfeatures, nports):
        self.destinations = FutureDestinations()
        self.prevActions = []
        self.nfeatures = nfeatures
        self.topology = None
        self.nports = nports
    def setDsts (self, destinations):
        self.destinations = destinations
        self.prevActions = getActions(self.destinations.getCurDst())
    def setTopo (self, topology):
        self.topology = topology
    def getCurDst (self):
        return self.destinations.getCurDst()
    def show (self):
        print("Future destinations: ")
        self.destinations.show()
        print("Previous actions: ", self.prevActions)

    def makeNPArray (self):
        features = np.full(self.nfeatures, 0)
        counter = 0
        targetHost = self.topology.getNodeByIp(self.destinations.getCurDst())
        index = (counter * NHOSTS) + (int(targetHost[1]) - 1)
        features[index] = 1
        futureDestinations = self.destinations.getDsts()
        for fd in futureDestinations:
            counter += 1
            targetHost = self.topology.getNodeByIp(fd)
            index = (counter * NHOSTS) + (int(targetHost[1]) - 1)
            features[index] = 1
        for i in range(0, FD_LENGTH - len(futureDestinations)):
            counter += 1
        start = (counter * NHOSTS) + NHOSTS
        counter = 0
        hosts = self.topology.getHosts()
        for h in hosts:
            hostname = h.getName()
            if actionHistory.get(hostname) is not None:
                ah = actionHistory[hostname]
                for action in ah:
                    action -= 1
                    index = start + ((counter * self.nports) + action)
                    features[index] = 1
                    counter += 1
            start += (MAXPORTS * AH_LENGTH)
            counter = 0

        return features

        '''
        firstrow = []
        firstrow.append(self.destinations.getCurDst())
        array = np.array(object = [fill(firstrow, 5), fill(self.destinations.getDsts(), 5), fill(self.prevActions, 5)])
        return array
        '''


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
        #self.observation_space = spaces.Box(low = 0, high = MAX, shape=(3, 5))
        self.nfeatures = (AH_LENGTH * MAXPORTS * NHOSTS) + (FD_LENGTH * NHOSTS) + NHOSTS
        self.observation_space = spaces.Box(low = np.full(self.nfeatures, 0), high = np.full(self.nfeatures, 1))
        self.state = State(self.nfeatures, self.nports)
        self.pkt = Packet(0, 0)
        self.port = port
        self.firstRun = True
        self.node = None
        self.topology = None
        self.rw1 = []
        self.rw2 = []
        self.rw3 = []
        self.rw4 = []
        self.rw = []
        self.sumrw = 0
        self.meanrw = []
        self.meanrw2 = []
        self.tmpmean = []
        self.tmpmean2 = []
        self.counter = 0
        self.resetvar = False
        #filelog = open(self.id + "_rl_log.txt", "w")
        #filelog.close()

        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            self.s = s
            self.s.bind((HOST_IP, self.port))
            self.s.listen()
            while True:
                print("listening on address " + HOST_IP + ", port " + str(self.port) + "...")
                self.conn, self.addr = self.s.accept()
                #self.conn.settimeout(20)
                print("connected by", self.addr)
                if self.firstRun:
                    self.topology = topo.loadtopology()
                    self.state.setTopo(self.topology)
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
        neighbor = interface.getNeighbor()
        dropped = 0
        delivered = 0
        if "h" in neighbor.getName():
            distance = 0
            if targetNode != neighbor.getName():
                dropped = 1
            else:
                delivered = 1
        else:
            distance = neighbor.getDistance(targetNode)

        # listen on socket
            # as msg arrives store fields in state(t + 1) and reward(t)

        try:
            data = self.conn.recv(512)
            if not data:
                print("no data")
                return self.state.makeNPArray(), self.pkt.getReward(), True, info
            self.pkt = parse_req(data)
            self.state.setDsts(self.pkt.getDsts())
        except Exception as e:
            print("Exception occured:", e)
            self.conn.close()
            self.s.close()

        done = False
        isBackbone = "s" in self.id
        qtime = self.pkt.getReward()
        rw1, rw2, rw3, rw4, rw = makeRw2(distance, qtime, dropped, delivered, isBackbone)
        '''
        filelog = open(self.id + "_rl_log.txt", "a")

        filelog.write("destination: " + targetNode + ", action: " + str(action) +
            ", rw = " + str(rw) + " (distance: " + str(distance) + ", qtime: " + str(qtime) + ")\n")
        filelog.close()
        '''
        self.rw1.append(rw1)
        self.rw2.append(rw2)
        self.rw3.append(rw3)
        self.rw4.append(rw4)
        self.rw.append(rw)
        self.sumrw += rw
        self.counter += 1
        if (self.counter % MEANSTEP) == 0:
            self.tmpmean = []
            self.tmpmean2 = []
        self.tmpmean.append(rw)
        self.tmpmean2.append(rw2)
        self.meanrw.append(sum(self.tmpmean) / len(self.tmpmean))
        self.meanrw2.append(sum(self.tmpmean2) / len(self.tmpmean2))
        if (self.counter % PLOT_FREQ) == 0 and self.counter >= PLOT_SOIL:
            fig, axs = plt.subplot_mosaic([
                ["upL", "upR"],
                ["midL", "midR"],
                ["low", "low"]
            ], constrained_layout = True)
            plrw1 = axs["upL"]
            plrw2 = axs["upR"]
            plrw3 = axs["midL"]
            plrw4 = axs["midR"]
            plrw = axs["low"]
            plrw1.plot(range(len(self.rw1)), self.rw1)
            plrw1.set_title("rw1 = LAMBDA1 * delta1")
            plrw2.axis(ymin=0, ymax=(MAXQTIME*LAMBDA2 / 1000000))
            plrw2.plot(range(len(self.rw2)), self.rw2)
            plrw2.plot(range(len(self.meanrw2)), self.meanrw2)
            plrw2.set_title("rw2 = LAMBDA2 * seconds")
            plrw3.plot(range(len(self.rw3)), self.rw3)
            plrw3.set_title("rw3 = LAMBDA3 * delta3")
            plrw4.axis(ymin=LAMBDA4*MINDISTANCE, ymax=LAMBDA4*MAXDISTANCE)
            plrw4.plot(range(len(self.rw4)), self.rw4)
            plrw4.set_title("rw4 = LAMBDA4 * delta4 * distance")
            plrw.axis(ymin=minRw(isBackbone), ymax=maxRw(isBackbone))
            plrw.plot(range(len(self.rw)), self.rw)
            plrw.plot(range(len(self.rw)), self.meanrw)
            plrw.set_title("rw = rw1 - rw2 - rw3 - rw4")
            plt.rcParams["figure.figsize"] = (20,10)
            plt.savefig(self.id + "_rw.png", dpi = 300)
            plt.clf()
        print(self.sumrw / len(self.rw))
        return self.state.makeNPArray(), rw, done, info

    def reset (self):
        # listen on socket
            # as msg arrives store fields in state, drop reward
        if not self.resetvar:
            try:
                data = self.conn.recv(512)
                if not data:
                    return
                pkt = parse_req(data)
                self.state.setDsts(pkt.getDsts())
            except Exception:
                self.conn.close()
                self.s.close()

        self.resetvar = True

        return self.state.makeNPArray()

    def render (self, mode="human", close=False):
        print("render called")
