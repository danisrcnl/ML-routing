from gym.envs.registration import register
register(id = "net-v0", entry_point = "net_env.envs:NetEnv",)
register(id = "net-v1", entry_point = "net_env.envs:NetEnv", kwargs = {'nports' : 4, "id":"s1", "port": 1401})
register(id = "net-v2", entry_point = "net_env.envs:NetEnv", kwargs = {'nports' : 4, "id":"s2", "port": 1402})
register(id = "net-v3", entry_point = "net_env.envs:NetEnv", kwargs = {'nports' : 4, "id":"s3", "port": 1403})
register(id = "net-v4", entry_point = "net_env.envs:NetEnv", kwargs = {'nports' : 4, "id":"s4", "port": 1404})
register(id = "net-v5", entry_point = "net_env.envs:NetEnv", kwargs = {'nports' : 5, "id":"l1", "port": 1411})
register(id = "net-v6", entry_point = "net_env.envs:NetEnv", kwargs = {'nports' : 5, "id":"l2", "port": 1412})
register(id = "net-v7", entry_point = "net_env.envs:NetEnv", kwargs = {'nports' : 5, "id":"l3", "port": 1413})
register(id = "net-v8", entry_point = "net_env.envs:NetEnv", kwargs = {'nports' : 5, "id":"l4", "port": 1414})
# simple topology env
register(id = "net-v9", entry_point = "net_env.envs:NetEnv", kwargs = {'nports' : 2, "id":"s1", "port": 1401})
