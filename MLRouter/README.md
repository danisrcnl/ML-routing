# How to run ML-Router

- training
```bash
./runbaselines.sh
sudo p4run
```

- playing
```bash
./runbaselines_play.sh
sudo p4run
```

(Consider that to enable routers stop simultaneously at training time and be useful at playing time some LOCs in deepq.py of baselines have been modified. As soon as possible these modifications will be included into this repository).

