#!/bin/bash

#!/bin/bash

sudo apt-get install mate-terminal

tab="--tab"
cmd1="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v1 --load_path=./netModelS1.pkl --num_timesteps=0 --play';bash"
cmd2="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v2 --load_path=./netModelS2.pkl --num_timesteps=0 --play';bash"
cmd3="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v3 --load_path=./netModelS3.pkl --num_timesteps=0 --play';bash"
cmd4="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v4 --load_path=./netModelS4.pkl --num_timesteps=0 --play';bash"
cmd5="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v5 --load_path=./netModelL1.pkl --num_timesteps=0 --play';bash"
cmd6="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v6 --load_path=./netModelL2.pkl --num_timesteps=0 --play';bash"
cmd7="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v7 --load_path=./netModelL3.pkl --num_timesteps=0 --play';bash"
cmd8="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v8 --load_path=./netModelL4.pkl --num_timesteps=0 --play';bash"
foo=""

foo+=($tab -t "s1" -e "$cmd1")
foo+=($tab -t "s2" -e "$cmd2")
foo+=($tab -t "s3" -e "$cmd3")
foo+=($tab -t "s4" -e "$cmd4")
foo+=($tab -t "l1" -e "$cmd5")
foo+=($tab -t "l2" -e "$cmd6")
foo+=($tab -t "l3" -e "$cmd7")
foo+=($tab -t "l4" -e "$cmd8")

mate-terminal "${foo[@]}"

exit 0
