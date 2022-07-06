#!/bin/bash

iperf3 -c 10.7.3.2 -p 5576 -t 14 -b 100M -J > iperflogs/h4_output0.txt
iperf3 -c 10.7.3.2 -p 5576 -t 12 -b 100M -J > iperflogs/h4_output1.txt
iperf3 -c 10.5.1.2 -p 5566 -t 13 -b 100M -J > iperflogs/h4_output2.txt
iperf3 -c 10.5.1.2 -p 5566 -t 11 -b 100M -J > iperflogs/h4_output3.txt
iperf3 -c 10.7.3.2 -p 5576 -t 14 -b 100M -J > iperflogs/h4_output4.txt
iperf3 -c 10.5.1.2 -p 5566 -t 10 -b 100M -J > iperflogs/h4_output5.txt
iperf3 -c 10.7.3.2 -p 5576 -t 13 -b 100M -J > iperflogs/h4_output6.txt
iperf3 -c 10.5.1.2 -p 5566 -t 10 -b 100M -J > iperflogs/h4_output7.txt
iperf3 -c 10.6.2.2 -p 5571 -t 14 -b 100M -J > iperflogs/h4_output8.txt
iperf3 -c 10.5.1.2 -p 5566 -t 12 -b 100M -J > iperflogs/h4_output9.txt
iperf3 -c 10.6.2.2 -p 5571 -t 13 -b 100M -J > iperflogs/h4_output10.txt
iperf3 -c 10.6.2.2 -p 5571 -t 12 -b 100M -J > iperflogs/h4_output11.txt
iperf3 -c 10.7.3.2 -p 5576 -t 11 -b 100M -J > iperflogs/h4_output12.txt
iperf3 -c 10.5.1.2 -p 5566 -t 12 -b 100M -J > iperflogs/h4_output13.txt
iperf3 -c 10.7.3.2 -p 5576 -t 12 -b 100M -J > iperflogs/h4_output14.txt
sleep 3
iperf3 -c 10.5.1.2 -p 5566 -t 10 -b 100M -J > iperflogs/h4_output15.txt
iperf3 -c 10.5.1.2 -p 5566 -t 11 -b 100M -J > iperflogs/h4_output16.txt
iperf3 -c 10.6.2.2 -p 5571 -t 14 -b 100M -J > iperflogs/h4_output17.txt
sleep 4
iperf3 -c 10.5.1.2 -p 5566 -t 13 -b 100M -J > iperflogs/h4_output18.txt
iperf3 -c 10.6.2.2 -p 5571 -t 10 -b 100M -J > iperflogs/h4_output19.txt
iperf3 -c 10.6.2.2 -p 5571 -t 13 -b 100M -J > iperflogs/h4_output20.txt
sleep 3
iperf3 -c 10.7.3.2 -p 5576 -t 10 -b 100M -J > iperflogs/h4_output21.txt
iperf3 -c 10.5.1.2 -p 5566 -t 10 -b 100M -J > iperflogs/h4_output22.txt
iperf3 -c 10.7.3.2 -p 5576 -t 13 -b 100M -J > iperflogs/h4_output23.txt
sleep 3
iperf3 -c 10.7.3.2 -p 5576 -t 12 -b 100M -J > iperflogs/h4_output24.txt
iperf3 -c 10.5.1.2 -p 5566 -t 14 -b 100M -J > iperflogs/h4_output25.txt
iperf3 -c 10.5.1.2 -p 5566 -t 14 -b 100M -J > iperflogs/h4_output26.txt
iperf3 -c 10.5.1.2 -p 5566 -t 14 -b 100M -J > iperflogs/h4_output27.txt
iperf3 -c 10.7.3.2 -p 5576 -t 10 -b 100M -J > iperflogs/h4_output28.txt
iperf3 -c 10.7.3.2 -p 5576 -t 11 -b 100M -J > iperflogs/h4_output29.txt
iperf3 -c 10.7.3.2 -p 5576 -t 13 -b 100M -J > iperflogs/h4_output30.txt
iperf3 -c 10.7.3.2 -p 5576 -t 13 -b 100M -J > iperflogs/h4_output31.txt
sleep 2
iperf3 -c 10.7.3.2 -p 5576 -t 11 -b 100M -J > iperflogs/h4_output32.txt
iperf3 -c 10.5.1.2 -p 5566 -t 14 -b 100M -J > iperflogs/h4_output33.txt
iperf3 -c 10.6.2.2 -p 5571 -t 10 -b 100M -J > iperflogs/h4_output34.txt
iperf3 -c 10.7.3.2 -p 5576 -t 14 -b 100M -J > iperflogs/h4_output35.txt
iperf3 -c 10.5.1.2 -p 5566 -t 13 -b 100M -J > iperflogs/h4_output36.txt
sleep 2
iperf3 -c 10.7.3.2 -p 5576 -t 14 -b 100M -J > iperflogs/h4_output37.txt
iperf3 -c 10.5.1.2 -p 5566 -t 11 -b 100M -J > iperflogs/h4_output38.txt
iperf3 -c 10.7.3.2 -p 5576 -t 10 -b 100M -J > iperflogs/h4_output39.txt
iperf3 -c 10.5.1.2 -p 5566 -t 11 -b 100M -J > iperflogs/h4_output40.txt
sleep 3
iperf3 -c 10.7.3.2 -p 5576 -t 11 -b 100M -J > iperflogs/h4_output41.txt
iperf3 -c 10.6.2.2 -p 5571 -t 12 -b 100M -J > iperflogs/h4_output42.txt
iperf3 -c 10.7.3.2 -p 5576 -t 13 -b 100M -J > iperflogs/h4_output43.txt
iperf3 -c 10.6.2.2 -p 5571 -t 14 -b 100M -J > iperflogs/h4_output44.txt
iperf3 -c 10.6.2.2 -p 5571 -t 10 -b 100M -J > iperflogs/h4_output45.txt
iperf3 -c 10.6.2.2 -p 5571 -t 10 -b 100M -J > iperflogs/h4_output46.txt
iperf3 -c 10.6.2.2 -p 5571 -t 12 -b 100M -J > iperflogs/h4_output47.txt
iperf3 -c 10.5.1.2 -p 5566 -t 13 -b 100M -J > iperflogs/h4_output48.txt
iperf3 -c 10.5.1.2 -p 5566 -t 12 -b 100M -J > iperflogs/h4_output49.txt
