import socket
import struct
import itertools

PORT, HOST_IP = 1500, '0.0.0.0'

def main():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((HOST_IP, PORT))
        s.listen()
        while True:
            print("listening...")
            condition = True
            conn, addr = s.accept()
            with conn:
                print('Connected by', addr)
                while condition:
                    try:
                        data = conn.recv(400)
                        if not data:
                            break
                        print("================ Packet received! ================")
                        parse_req(data)
                        ret = 1 # qui ci sarà baselines a decidere
                        sendBack = struct.pack('I', ret)
                        conn.sendall(sendBack)
                    except Exception:
                        conn.close()
                        s.close()


def parse_req(data):
    strdata = data.decode('UTF-8')
    print(strdata)
    parsed = strdata.split(' ')
    if parsed[0] == 'GETP':
        destinations = FutureDestinations()
        size = int(parsed[1])
        destinations.setSize(size)
        dst = int(parsed[2])
        destinations.setCurDst(dst)
        lastRw = int(parsed[3])
        max = 4 + size
        for i in range(4, max):
            destinations.pushDst(parsed[i])
        print("Last reward:", lastRw)
        destinations.show()


class FutureDestinations:
    def __init__(self):
        self.curDst = 0
        self.size = 0
        self.dsts = []

    def pushDst(self, dst):
        self.dsts.append(int(dst))

    def setSize(self, size):
        self.size = int(size)

    def setCurDst(self, dst):
        self.curDst = int(dst)

    def show(self):
        print("Number of future destinations:", self.size)
        print("Current destination:", self.curDst)
        print("List of future destinations:")
        for dst in self.dsts:
            print(dst)

try:
    main()
except KeyboardInterrupt:
    print("\rKeyboard interrupt, exiting")
    try:
        conn.close()
    except Exception:
        "No connection yet"
    try:
        s.close()
    except Exception:
        "No socket yet"
