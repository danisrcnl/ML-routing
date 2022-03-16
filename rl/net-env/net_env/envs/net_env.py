import gym
from gym import spaces
import socket
import struct
import itertools

PORT, HOST_IP = 1500, '0.0.0.0'

actionHistory = {}
def addAction (curDst, action):
    if actionHistory.get(curDst) is None:
        actionHistory[curDst] = [action]
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
        self.size = 0
        self.dsts = []

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
        print("Number of future destinations:", self.size)
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
        self.destinations.printL()
        print("Previous actions: ", self.prevActions)
    def makeNPArray (self):
        array = np.array()
        array.append(self.destinations.getCurDst())
        for dst in self.destinations.getDsts():
            array.append(dst)
        for action in self.prevActions:
            array.append(action)
        return array


class Packet:
    def __init__ (self, destinations, reward):
        self.futureDestinations = destinations
        self.reward = reward

    def getDsts (self):
        return self.futureDestinations

    def getReward (self):
        return self.reward


def parse_req (data):
    strdata = data.decode('UTF-8')
    print(strdata)
    parsed = strdata.split(' ')
    if parsed[0] == 'GETP':
        destinations = FutureDestinations()
        size = int(parsed[1])
        destinations.setSize(size)
        dst = int(parsed[2])
        destinations.setCurDst(dst)
        lastRw = int(parsed[3])
        max = 4 + size
        for i in range(4, max):
            destinations.pushDst(parsed[i])
        print("Last reward:", lastRw)
        pkt = Packet(destinations, lastRw)
        return pkt

class NetEnv (gym.Env):

    def __init__ (self):
        self.action_space = spaces.Discrete(2) #tb changed
        self.observation_space = spaces.Box(3,) #tb changed
        self.state = State()
        self.pkt = Packet()
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            self.s = s
            self.s.bind((HOST_IP, PORT))
            self.s.listen()
            while True:
                print("listening...")
                self.conn, self.addr = self.s.accept()
                print("connected by", addr)
                return

    def step (self, action):
        # action contains the # of the port the packet must be forwarded to

        # send action back on socket
        # store action in action history
        ret = action
        addAction(self.state.getCurDst(), action)
        sendBack = struct.pack('I', ret)
        self.conn.sendall(sendBack)

        # listen on socket
            # as msg arrives store fields in state(t + 1) and reward(t)

        try:
            data = self.conn.recv(400)
            if not data:
                return self.state, self.pkt.getReward(), True, info
            print("================ Packet received! ================")
            self.pkt = parse_req(data)
            self.state.setDsts(pkt.getDsts())
        except Exception:
            self.conn.close()
            self.s.close()

        done = False
        info = {}
        return self.state, self.pkt.getReward(), done, info

    def reset (self):
        # listen on socket
            # as msg arrives store fields in state, drop reward

        try:
            data = self.conn.recv(400)
            if not data:
                return
            print("================ Packet received! ================")
            pkt = parse_req(data)
            self.state.setDsts(pkt.getDsts())
        except Exception:
            self.conn.close()
            self.s.close()
