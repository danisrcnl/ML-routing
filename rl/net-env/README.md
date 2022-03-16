# Network Environment

## Registration

In this folder you can register the custom implemented OpenAI Gym environment by typing in your terminal:
```bash
pip install -e .
```

Once done, if you later change environment .py file, changes are going to be automatically detected.

## Usage

You can use the custom implemented environment as any other registered environment now. For instance, when running baselines.run, you can specify **--env** argument as **net_env:net-v0**
