import gym
from gym import spaces

class NetEnv (gym.Env):

    NPORTS = 2
    STATE_FEATURES = 3

    state = [0, 0, 0]

    def __init__ (self):
        self.action_space = spaces.Discrete(NPORTS)
        self.observation_space = spaces.Box(STATE_FEATURES)

    def step (self, action):
        # action contains the # of the port the packet must be forwarded to
        
        done = True
        info = {}
        return self.state, reward, done, info

    def reset (self):

    def render ():

    def close ():
