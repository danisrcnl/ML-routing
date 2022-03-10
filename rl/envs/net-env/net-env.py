import gym
from gym import spaces
import socket
import struct
import itertools

PORT, HOST_IP = 1500, '0.0.0.0'

actionHistory = {}
def addAction(curDst, action):
    if actionHistory.get(curDst) is None:
        actionHistory[curDst] = [action]
    else:
        actionHistory[curDst].append(action)
def getActions(curDst):
    if actionHistory.get(curDst) is None:
        return []
    else:
        return actionHistory[curDst]

class State:
    def __init__(self):
        self.destinations = FutureDestinations()
        self.prevActions = []
    def setDsts(self, destinations):
        self.destinations = destinations
        self.prevActions = getActions(self.destinations.getCurDst())
    def show(self):
        print("Future destinations: ")
        self.destinations.printL()
        print("Previous actions: ", self.prevActions)

class FutureDestinations:
    def __init__(self):
        self.curDst = 0
        self.size = 0
        self.dsts = []

    def pushDst(self, dst):
        self.dsts.append(int(dst))

    def setSize(self, size):
        self.size = int(size)

    def setCurDst(self, dst):
        self.curDst = int(dst)

    def getCurDst(self):
        return self.curDst

    def reset(self):
        self.dsts = []
        self.curDst = 0
        self.size = 0

    def show(self):
        print("Number of future destinations:", self.size)
        print("Current destination:", self.curDst)
        print("List of future destinations:")
        for dst in self.dsts:
            print(dst)


class NetEnv (gym.Env):

    NPORTS = 2
    STATE_FEATURES = 3

    def __init__ (self):
        self.action_space = spaces.Discrete(NPORTS)
        self.observation_space = spaces.Box(STATE_FEATURES)
        self.state = State()

    def step (self, action):
        # action contains the # of the port the packet must be forwarded to

        # send action back on socket

        # listen on socket
            # as msg arrives store fields in state(t + 1) and reward(t)

        done = False
        info = {}
        return self.state, reward, done, info

    def reset (self):
        # listen on socket
            # as msg arrives store fields in state, drop reward

    def render ():

    def close ():
