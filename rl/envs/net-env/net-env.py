import gym
from gym import spaces

class State:
    def __init__(self):


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
