#!/bin/bash

sudo apt-get install mate-terminal

tab="--tab"
cmd1="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v1 --save_path=./netModelS1.pkl --log_path=./bl_s1/ --num_timesteps=10000';bash"
cmd2="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v2 --save_path=./netModelS2.pkl --log_path=./bl_s2/ --num_timesteps=10000';bash"
cmd3="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v3 --save_path=./netModelS3.pkl --log_path=./bl_s3/ --num_timesteps=10000';bash"
cmd4="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v4 --save_path=./netModelS4.pkl --log_path=./bl_s4/ --num_timesteps=10000';bash"
cmd5="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v5 --save_path=./netModelL1.pkl --log_path=./bl_l1/ --num_timesteps=10000';bash"
cmd6="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v6 --save_path=./netModelL2.pkl --log_path=./bl_l2/ --num_timesteps=10000';bash"
cmd7="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v7 --save_path=./netModelL3.pkl --log_path=./bl_l3/ --num_timesteps=10000';bash"
cmd8="bash -c '. /home/p4/myvenv/bin/activate; python -m baselines.run --alg=deepq --env=net_env:net-v8 --save_path=./netModelL4.pkl --log_path=./bl_l4/ --num_timesteps=10000';bash"
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
