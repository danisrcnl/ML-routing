#!/usr/bin/env python
import sys
import socket
import random
import time
from threading import Thread, Event
from scapy.all import *

def send_packet():

    value = raw_input("Press the return key to send a packet:")
    if value != '':
        print "please press return key or CTRL+C to exit"
        return
    e = Ether()
    i = IP(dst='10.1.1.1')
    pkt = e/i
    sendpfast(pkt, pps=1000, loop=500, parse_results=1)

def main():

    try:
        while True:
            send_packet()
            time.sleep(0.5)

    except KeyboardInterrupt:
        print "\nExecution terminated\n"
        return

if __name__ == '__main__':
    main()
