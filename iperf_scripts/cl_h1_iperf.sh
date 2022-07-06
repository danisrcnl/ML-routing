#!/bin/bash

iperf3 -c 10.7.3.2 -p 5568 -t 30 -b 100M -J > iperflogs/h1_output0.txt
sleep 3
iperf3 -c 10.8.4.2 -p 5569 -t 30 -b 100M -J > iperflogs/h1_output1.txt
iperf3 -c 10.8.4.2 -p 5569 -t 10 -b 100M -J > iperflogs/h1_output2.txt
sleep 2
iperf3 -c 10.7.3.2 -p 5568 -t 10 -b 100M -J > iperflogs/h1_output3.txt
iperf3 -c 10.6.2.2 -p 5567 -t 60 -b 100M -J > iperflogs/heavyload.txt
iperf3 -c 10.7.3.2 -p 5568 -t 14 -b 100M -J > iperflogs/h1_output5.txt
iperf3 -c 10.7.3.2 -p 5568 -t 12 -b 100M -J > iperflogs/h1_output6.txt
iperf3 -c 10.7.3.2 -p 5568 -t 13 -b 100M -J > iperflogs/h1_output7.txt
iperf3 -c 10.8.4.2 -p 5569 -t 13 -b 100M -J > iperflogs/h1_output8.txt
iperf3 -c 10.6.2.2 -p 5567 -t 14 -b 100M -J > iperflogs/h1_output9.txt
iperf3 -c 10.6.2.2 -p 5567 -t 12 -b 100M -J > iperflogs/h1_output10.txt
iperf3 -c 10.6.2.2 -p 5567 -t 13 -b 100M -J > iperflogs/h1_output11.txt
iperf3 -c 10.7.3.2 -p 5568 -t 14 -b 100M -J > iperflogs/h1_output12.txt
iperf3 -c 10.6.2.2 -p 5567 -t 11 -b 100M -J > iperflogs/h1_output13.txt
iperf3 -c 10.7.3.2 -p 5568 -t 12 -b 100M -J > iperflogs/h1_output14.txt
iperf3 -c 10.7.3.2 -p 5568 -t 12 -b 100M -J > iperflogs/h1_output15.txt
iperf3 -c 10.6.2.2 -p 5567 -t 13 -b 100M -J > iperflogs/h1_output16.txt
iperf3 -c 10.7.3.2 -p 5568 -t 13 -b 100M -J > iperflogs/h1_output17.txt
iperf3 -c 10.6.2.2 -p 5567 -t 11 -b 100M -J > iperflogs/h1_output18.txt
iperf3 -c 10.8.4.2 -p 5569 -t 14 -b 100M -J > iperflogs/h1_output19.txt
iperf3 -c 10.6.2.2 -p 5567 -t 11 -b 100M -J > iperflogs/h1_output20.txt
iperf3 -c 10.8.4.2 -p 5569 -t 10 -b 100M -J > iperflogs/h1_output21.txt
sleep 4
iperf3 -c 10.7.3.2 -p 5568 -t 12 -b 100M -J > iperflogs/h1_output22.txt
iperf3 -c 10.6.2.2 -p 5567 -t 14 -b 100M -J > iperflogs/h1_output23.txt
iperf3 -c 10.6.2.2 -p 5567 -t 14 -b 100M -J > iperflogs/h1_output24.txt
sleep 2
iperf3 -c 10.6.2.2 -p 5567 -t 12 -b 100M -J > iperflogs/h1_output25.txt
iperf3 -c 10.6.2.2 -p 5567 -t 11 -b 100M -J > iperflogs/h1_output26.txt
iperf3 -c 10.6.2.2 -p 5567 -t 13 -b 100M -J > iperflogs/h1_output27.txt
iperf3 -c 10.6.2.2 -p 5567 -t 13 -b 100M -J > iperflogs/h1_output28.txt
sleep 1
iperf3 -c 10.8.4.2 -p 5569 -t 11 -b 100M -J > iperflogs/h1_output29.txt
sleep 3
iperf3 -c 10.6.2.2 -p 5567 -t 13 -b 100M -J > iperflogs/h1_output30.txt
iperf3 -c 10.8.4.2 -p 5569 -t 14 -b 100M -J > iperflogs/h1_output31.txt
iperf3 -c 10.7.3.2 -p 5568 -t 14 -b 100M -J > iperflogs/h1_output32.txt
sleep 3
iperf3 -c 10.6.2.2 -p 5567 -t 13 -b 100M -J > iperflogs/h1_output33.txt
iperf3 -c 10.7.3.2 -p 5568 -t 13 -b 100M -J > iperflogs/h1_output34.txt
iperf3 -c 10.6.2.2 -p 5567 -t 12 -b 100M -J > iperflogs/h1_output35.txt
iperf3 -c 10.7.3.2 -p 5568 -t 13 -b 100M -J > iperflogs/h1_output36.txt
iperf3 -c 10.6.2.2 -p 5567 -t 10 -b 100M -J > iperflogs/h1_output37.txt
iperf3 -c 10.6.2.2 -p 5567 -t 11 -b 100M -J > iperflogs/h1_output38.txt
sleep 4
iperf3 -c 10.7.3.2 -p 5568 -t 11 -b 100M -J > iperflogs/h1_output39.txt
iperf3 -c 10.7.3.2 -p 5568 -t 13 -b 100M -J > iperflogs/h1_output40.txt
iperf3 -c 10.8.4.2 -p 5569 -t 11 -b 100M -J > iperflogs/h1_output41.txt
iperf3 -c 10.8.4.2 -p 5569 -t 10 -b 100M -J > iperflogs/h1_output42.txt
iperf3 -c 10.7.3.2 -p 5568 -t 13 -b 100M -J > iperflogs/h1_output43.txt
iperf3 -c 10.8.4.2 -p 5569 -t 12 -b 100M -J > iperflogs/h1_output44.txt
iperf3 -c 10.8.4.2 -p 5569 -t 12 -b 100M -J > iperflogs/h1_output45.txt
iperf3 -c 10.6.2.2 -p 5567 -t 10 -b 100M -J > iperflogs/h1_output46.txt
iperf3 -c 10.6.2.2 -p 5567 -t 13 -b 100M -J > iperflogs/h1_output47.txt
iperf3 -c 10.8.4.2 -p 5569 -t 13 -b 100M -J > iperflogs/h1_output48.txt
iperf3 -c 10.8.4.2 -p 5569 -t 11 -b 100M -J > iperflogs/h1_output49.txt
