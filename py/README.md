# Installation guide

## 1. Prerequisites

In order to use Baselines, it's required python3 (>=3.5) with the development headers. You'll also need system packages CMake, OpenMPI and zlib. Those can be installed as follows
### Ubuntu 
    
```bash
sudo apt-get update && sudo apt-get install cmake libopenmpi-dev python3-dev zlib1g-dev
```
    
### Mac OS X
Installation of system packages on Mac requires [Homebrew](https://brew.sh). With Homebrew installed, run the following:
```bash
brew install cmake openmpi
```

### FFMPEG
You'll also need **ffmpeg** to be installed, you can check if you already have it by typing:
```bash
ffmpeg -version
```

If you don't, just get it running this couple of commands:
```bash
sudo apt update
sudo apt install ffmpeg
```

## 2. Create a virtual environment

A virtual environment is strongly recommended, since Baselines is going to work with an older version of Tensorflow (1.14). Thus you need to install packages releases which are older than the ones you may have installed on your device due to other usage purposes. An isolated environment is going to guarantee that everything will work.

The first thing you need to do is to install **virtualenv** package:
```bash
pip install virtualenv
```

Now move to the directory you want to create the virtual environment in and create it:
```bash
virtualenv virtualEnvironmentName --python=python3
```

The last parameter (--python=python3) guarantees that the only installed version of python when into the virtual environment will be Python 3. Since it's required Python3 (>=3.5), make sure that you have a compatible release installed on your device. **If you have many different Python3 releases installed, you can explicitly force one of them**:

```bash
virtualenv virtualEnvironmentName --python=python3.x
```

Now that you have created a virtual environment, you need to **activate** it. By activating it, you're going to refactor you Python environment to the one you're creating in your virtual environment.
Put yourself in the directory containing the virtual environment and type:

```bash
. virtualEnvironmentName/bin/activate
```

Once you've activated it, you should see something like this on your CLI:

```bash
(virtualEnvironmentName) user@host:~$
```

This means you're into your virtual environment and every script you will call will refer to Python packages contained in it (not system's ones).

## 3. Install needed packages

Now you must install all the packages needed to run Baselines.

### Tensorflow
```bash
pip install tensorflow-gpu==1.14 # if you have a CUDA-compatible gpu and proper drivers
```
or
```bash
pip install tensorflow==1.14 # otherwise
```

### Other packages
In the requirements.txt file you can find all the compatible packages releases you have to install running:

```bash
pip install packageName==releaseNumber
```

### Baselines
To get baselines you have to clone its repository firts:
```bash
git clone https://github.com/openai/baselines.git
cd baselines
```

And then you can install it:
```bash
pip install -e .
```
