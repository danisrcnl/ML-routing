#!/bin/bash

iperf3 -c 10.5.1.2 -p 5570 -t 10 -b 100M -J > iperflogs/h2_output0.txt
iperf3 -c 10.7.3.2 -p 5572 -t 13 -b 100M -J > iperflogs/h2_output1.txt
iperf3 -c 10.7.3.2 -p 5572 -t 11 -b 100M -J > iperflogs/h2_output2.txt
iperf3 -c 10.5.1.2 -p 5570 -t 13 -b 100M -J > iperflogs/h2_output3.txt
iperf3 -c 10.7.3.2 -p 5572 -t 10 -b 100M -J > iperflogs/h2_output4.txt
sleep 3
iperf3 -c 10.8.4.2 -p 5573 -t 13 -b 100M -J > iperflogs/h2_output5.txt
iperf3 -c 10.5.1.2 -p 5570 -t 11 -b 100M -J > iperflogs/h2_output6.txt
iperf3 -c 10.7.3.2 -p 5572 -t 10 -b 100M -J > iperflogs/h2_output7.txt
iperf3 -c 10.7.3.2 -p 5572 -t 10 -b 100M -J > iperflogs/h2_output8.txt
sleep 1
iperf3 -c 10.8.4.2 -p 5573 -t 10 -b 100M -J > iperflogs/h2_output9.txt
iperf3 -c 10.8.4.2 -p 5573 -t 11 -b 100M -J > iperflogs/h2_output10.txt
iperf3 -c 10.8.4.2 -p 5573 -t 13 -b 100M -J > iperflogs/h2_output11.txt
sleep 4
iperf3 -c 10.8.4.2 -p 5573 -t 13 -b 100M -J > iperflogs/h2_output12.txt
iperf3 -c 10.5.1.2 -p 5570 -t 10 -b 100M -J > iperflogs/h2_output13.txt
sleep 4
iperf3 -c 10.8.4.2 -p 5573 -t 13 -b 100M -J > iperflogs/h2_output14.txt
iperf3 -c 10.7.3.2 -p 5572 -t 10 -b 100M -J > iperflogs/h2_output15.txt
sleep 2
iperf3 -c 10.7.3.2 -p 5572 -t 13 -b 100M -J > iperflogs/h2_output16.txt
sleep 4
iperf3 -c 10.7.3.2 -p 5572 -t 14 -b 100M -J > iperflogs/h2_output17.txt
iperf3 -c 10.7.3.2 -p 5572 -t 12 -b 100M -J > iperflogs/h2_output18.txt
iperf3 -c 10.5.1.2 -p 5570 -t 14 -b 100M -J > iperflogs/h2_output19.txt
iperf3 -c 10.5.1.2 -p 5570 -t 14 -b 100M -J > iperflogs/h2_output20.txt
iperf3 -c 10.7.3.2 -p 5572 -t 11 -b 100M -J > iperflogs/h2_output21.txt
iperf3 -c 10.7.3.2 -p 5572 -t 11 -b 100M -J > iperflogs/h2_output22.txt
iperf3 -c 10.5.1.2 -p 5570 -t 13 -b 100M -J > iperflogs/h2_output23.txt
iperf3 -c 10.5.1.2 -p 5570 -t 13 -b 100M -J > iperflogs/h2_output24.txt
iperf3 -c 10.7.3.2 -p 5572 -t 12 -b 100M -J > iperflogs/h2_output25.txt
sleep 4
iperf3 -c 10.7.3.2 -p 5572 -t 14 -b 100M -J > iperflogs/h2_output26.txt
iperf3 -c 10.7.3.2 -p 5572 -t 14 -b 100M -J > iperflogs/h2_output27.txt
sleep 3
iperf3 -c 10.7.3.2 -p 5572 -t 12 -b 100M -J > iperflogs/h2_output28.txt
iperf3 -c 10.5.1.2 -p 5570 -t 10 -b 100M -J > iperflogs/h2_output29.txt
iperf3 -c 10.7.3.2 -p 5572 -t 10 -b 100M -J > iperflogs/h2_output30.txt
sleep 4
iperf3 -c 10.7.3.2 -p 5572 -t 10 -b 100M -J > iperflogs/h2_output31.txt
iperf3 -c 10.5.1.2 -p 5570 -t 12 -b 100M -J > iperflogs/h2_output32.txt
sleep 4
iperf3 -c 10.7.3.2 -p 5572 -t 10 -b 100M -J > iperflogs/h2_output33.txt
iperf3 -c 10.5.1.2 -p 5570 -t 12 -b 100M -J > iperflogs/h2_output34.txt
iperf3 -c 10.8.4.2 -p 5573 -t 13 -b 100M -J > iperflogs/h2_output35.txt
sleep 1
iperf3 -c 10.7.3.2 -p 5572 -t 14 -b 100M -J > iperflogs/h2_output36.txt
sleep 3
iperf3 -c 10.8.4.2 -p 5573 -t 10 -b 100M -J > iperflogs/h2_output37.txt
iperf3 -c 10.5.1.2 -p 5570 -t 11 -b 100M -J > iperflogs/h2_output38.txt
iperf3 -c 10.7.3.2 -p 5572 -t 10 -b 100M -J > iperflogs/h2_output39.txt
sleep 1
iperf3 -c 10.8.4.2 -p 5573 -t 13 -b 100M -J > iperflogs/h2_output40.txt
sleep 4
iperf3 -c 10.8.4.2 -p 5573 -t 14 -b 100M -J > iperflogs/h2_output41.txt
sleep 1
iperf3 -c 10.5.1.2 -p 5570 -t 10 -b 100M -J > iperflogs/h2_output42.txt
sleep 2
iperf3 -c 10.8.4.2 -p 5573 -t 11 -b 100M -J > iperflogs/h2_output43.txt
sleep 4
iperf3 -c 10.7.3.2 -p 5572 -t 10 -b 100M -J > iperflogs/h2_output44.txt
sleep 3
iperf3 -c 10.8.4.2 -p 5573 -t 11 -b 100M -J > iperflogs/h2_output45.txt
iperf3 -c 10.7.3.2 -p 5572 -t 13 -b 100M -J > iperflogs/h2_output46.txt
sleep 1
iperf3 -c 10.5.1.2 -p 5570 -t 11 -b 100M -J > iperflogs/h2_output47.txt
iperf3 -c 10.5.1.2 -p 5570 -t 12 -b 100M -J > iperflogs/h2_output48.txt
iperf3 -c 10.7.3.2 -p 5572 -t 11 -b 100M -J > iperflogs/h2_output49.txt
