import socket
import struct

PORT, HOST_IP = 1500, '0.0.0.0'
key = 4

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
                        data = conn.recv(4)
                        if not data:
                            break
                        t = parse(data)
                        print(t)
                        t = 2*t
                        d = struct.pack('I', t)
                        conn.sendall(d)
                        conn.close()
                        condition = False
                    except Exception:
                        conn.close()
                        s.close()


def parse(data):
    value = 0
    i = 0
    ciphers = 0
    while data[i] != '/' and data[i] > 47 and data[i] < 58:
        i = i + 1
    ciphers = i
    i = 0
    while i < ciphers:
        value += (int(chr(data[i])) * pow(10, ciphers - i - 1))
        i = i + 1
    return value



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
