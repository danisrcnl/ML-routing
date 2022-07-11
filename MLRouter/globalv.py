from redis import Redis

cli = Redis('localhost')
shared_var = 0

cli.set("share_place", shared_var)
