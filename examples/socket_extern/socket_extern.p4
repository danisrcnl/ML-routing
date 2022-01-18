/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/
typedef bit<48> macAddr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

struct headers {
    ethernet_t   ethernet;
}

struct metadata {
    /* empty */
}

extern SocketExtern {
    SocketExtern(bit<32> data);
    void sendData(in bit<32> data);
    void getData(inout bit<32> data);
    void printData(in bit<32> data);
}
/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/
parser MyParser(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

      state start{
          packet.extract(hdr.ethernet);
          transition accept;
      }

}
/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(in headers hdr, inout metadata meta) {
    apply { }
}
/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/
control MyIngress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {

    @userextern @name("socket_extern_instance")
    SocketExtern(0x0) socket_extern_instance;

    bit<32> myvar = 0x1;

    action socket_test() {
        // sending 1 to the python server (server.py)
        socket_extern_instance.sendData(myvar);
        // getting the value stored into the class (originally 0) that should have
        // been updated as soon as the server replied with twice the value received
        // by sendData method, that was 1
        socket_extern_instance.getData(myvar);
        // finally printing in the log of switch s1 (/log/s1.log) the value to check
        // it was correctly assigned to the chosen variable
        socket_extern_instance.printData(myvar);
    }

    apply {
      socket_test();
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply { }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {	}
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
	MyParser(),
	MyVerifyChecksum(),
	MyIngress(),
	MyEgress(),
	MyComputeChecksum(),
	MyDeparser()
) main;
