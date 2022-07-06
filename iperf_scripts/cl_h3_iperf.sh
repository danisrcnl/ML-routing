#!/bin/bash

iperf3 -c 10.5.1.2 -p 5574 -t 12 -b 100M -J > iperflogs/h3_output0.txt
iperf3 -c 10.6.2.2 -p 5575 -t 12 -b 100M -J > iperflogs/h3_output1.txt
iperf3 -c 10.8.4.2 -p 5577 -t 13 -b 100M -J > iperflogs/h3_output2.txt
iperf3 -c 10.6.2.2 -p 5575 -t 12 -b 100M -J > iperflogs/h3_output3.txt
iperf3 -c 10.6.2.2 -p 5575 -t 11 -b 100M -J > iperflogs/h3_output4.txt
iperf3 -c 10.8.4.2 -p 5577 -t 11 -b 100M -J > iperflogs/h3_output5.txt
iperf3 -c 10.8.4.2 -p 5577 -t 13 -b 100M -J > iperflogs/h3_output6.txt
sleep 2
iperf3 -c 10.5.1.2 -p 5574 -t 11 -b 100M -J > iperflogs/h3_output7.txt
iperf3 -c 10.6.2.2 -p 5575 -t 11 -b 100M -J > iperflogs/h3_output8.txt
iperf3 -c 10.8.4.2 -p 5577 -t 12 -b 100M -J > iperflogs/h3_output9.txt
iperf3 -c 10.5.1.2 -p 5574 -t 12 -b 100M -J > iperflogs/h3_output10.txt
sleep 2
iperf3 -c 10.8.4.2 -p 5577 -t 13 -b 100M -J > iperflogs/h3_output11.txt
iperf3 -c 10.5.1.2 -p 5574 -t 13 -b 100M -J > iperflogs/h3_output12.txt
iperf3 -c 10.5.1.2 -p 5574 -t 11 -b 100M -J > iperflogs/h3_output13.txt
sleep 4
iperf3 -c 10.6.2.2 -p 5575 -t 11 -b 100M -J > iperflogs/h3_output14.txt
iperf3 -c 10.5.1.2 -p 5574 -t 10 -b 100M -J > iperflogs/h3_output15.txt
iperf3 -c 10.8.4.2 -p 5577 -t 14 -b 100M -J > iperflogs/h3_output16.txt
iperf3 -c 10.6.2.2 -p 5575 -t 14 -b 100M -J > iperflogs/h3_output17.txt
sleep 4
iperf3 -c 10.8.4.2 -p 5577 -t 13 -b 100M -J > iperflogs/h3_output18.txt
iperf3 -c 10.8.4.2 -p 5577 -t 11 -b 100M -J > iperflogs/h3_output19.txt
iperf3 -c 10.6.2.2 -p 5575 -t 13 -b 100M -J > iperflogs/h3_output20.txt
iperf3 -c 10.5.1.2 -p 5574 -t 12 -b 100M -J > iperflogs/h3_output21.txt
iperf3 -c 10.5.1.2 -p 5574 -t 10 -b 100M -J > iperflogs/h3_output22.txt
iperf3 -c 10.6.2.2 -p 5575 -t 11 -b 100M -J > iperflogs/h3_output23.txt
iperf3 -c 10.6.2.2 -p 5575 -t 12 -b 100M -J > iperflogs/h3_output24.txt
iperf3 -c 10.6.2.2 -p 5575 -t 14 -b 100M -J > iperflogs/h3_output25.txt
iperf3 -c 10.8.4.2 -p 5577 -t 12 -b 100M -J > iperflogs/h3_output26.txt
iperf3 -c 10.5.1.2 -p 5574 -t 11 -b 100M -J > iperflogs/h3_output27.txt
iperf3 -c 10.5.1.2 -p 5574 -t 11 -b 100M -J > iperflogs/h3_output28.txt
iperf3 -c 10.5.1.2 -p 5574 -t 12 -b 100M -J > iperflogs/h3_output29.txt
sleep 3
iperf3 -c 10.8.4.2 -p 5577 -t 13 -b 100M -J > iperflogs/h3_output30.txt
iperf3 -c 10.8.4.2 -p 5577 -t 10 -b 100M -J > iperflogs/h3_output31.txt
iperf3 -c 10.6.2.2 -p 5575 -t 10 -b 100M -J > iperflogs/h3_output32.txt
sleep 1
iperf3 -c 10.6.2.2 -p 5575 -t 10 -b 100M -J > iperflogs/h3_output33.txt
sleep 4
iperf3 -c 10.8.4.2 -p 5577 -t 13 -b 100M -J > iperflogs/h3_output34.txt
iperf3 -c 10.8.4.2 -p 5577 -t 10 -b 100M -J > iperflogs/h3_output35.txt
iperf3 -c 10.5.1.2 -p 5574 -t 14 -b 100M -J > iperflogs/h3_output36.txt
iperf3 -c 10.6.2.2 -p 5575 -t 12 -b 100M -J > iperflogs/h3_output37.txt
iperf3 -c 10.5.1.2 -p 5574 -t 14 -b 100M -J > iperflogs/h3_output38.txt
iperf3 -c 10.8.4.2 -p 5577 -t 12 -b 100M -J > iperflogs/h3_output39.txt
iperf3 -c 10.8.4.2 -p 5577 -t 11 -b 100M -J > iperflogs/h3_output40.txt
iperf3 -c 10.8.4.2 -p 5577 -t 12 -b 100M -J > iperflogs/h3_output41.txt
iperf3 -c 10.5.1.2 -p 5574 -t 11 -b 100M -J > iperflogs/h3_output42.txt
iperf3 -c 10.5.1.2 -p 5574 -t 12 -b 100M -J > iperflogs/h3_output43.txt
iperf3 -c 10.5.1.2 -p 5574 -t 10 -b 100M -J > iperflogs/h3_output44.txt
iperf3 -c 10.5.1.2 -p 5574 -t 14 -b 100M -J > iperflogs/h3_output45.txt
iperf3 -c 10.5.1.2 -p 5574 -t 13 -b 100M -J > iperflogs/h3_output46.txt
sleep 4
iperf3 -c 10.6.2.2 -p 5575 -t 14 -b 100M -J > iperflogs/h3_output47.txt
iperf3 -c 10.5.1.2 -p 5574 -t 10 -b 100M -J > iperflogs/h3_output48.txt
iperf3 -c 10.6.2.2 -p 5575 -t 10 -b 100M -J > iperflogs/h3_output49.txt
