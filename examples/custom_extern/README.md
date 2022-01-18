# Example

This example just shows how the custom extern implemented following the guide under networking/p4 folder can be used into a p4 program.

## Usage

Be sure you've installed all the modules provided into the root folder of the repository. What you can do now is to type in your shell

```bash
sudo p4run
```

Now mininet should start on your shell and you should be able to interact with its CLI. Enter into the only switch we instantiated

```bash
mininet > xterm h1
```

A shell should open for the selected node (h1) and, from there, you can launch the python script that sends a packet to the switch

```bash
python send_packet.py
```

The script is thought for Python 2.

## Considerations

What you'll notice is that a topology.db file has been generated, along with a directory called log. If you open s1.txt file under that directory you'll see that the line defined in the method print() of our custom implemented extern has been printed each time a new packet has been received.
