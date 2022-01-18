#!/usr/bin/env python
import sys
import socket
import random
import time
from threading import Thread, Event
from scapy.all import *

def get_if():
    ifs=get_if_list()
    iface=None # "h1-eth0"
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print "Cannot find eth0 interface"
        exit(1)
    return iface

def send_packet(iface, addr):

    value = raw_input("Press the return key to send a packet:")
    if value != '':
        print "please press return key or CTRL+C to exit"
        return
    print "Sending on interface %s to %s\n" % (iface, str(addr))
    pkt =  Ether(src=get_if_hwaddr(iface), dst='00:01:02:03:04:05')
    pkt = pkt /IP(dst=addr)
    sendp(pkt, iface=iface, verbose=False)

def main():

    addr = "10.0.0.2"
    addr = socket.gethostbyname(addr)
    iface = get_if()

    try:
        while True:
            send_packet(iface, addr)
            time.sleep(0.5)

    except KeyboardInterrupt:
        print "\nExecution terminated\n"
        return

if __name__ == '__main__':
    main()
