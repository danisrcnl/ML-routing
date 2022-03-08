/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

#include "include/headers.p4"
#include "include/parsers.p4"

extern MLController {
    MLController();
    void simulate_computation();
    void print();
    void pushAddr(in ip4Addr_t address, inout bit<32> pos, in bit<1> valid_bool);
    void popAddr(in bit<32> pos, in bit<1> valid_bool);
    void getOutputPort(in bit<32> pos, in bit<1> valid_bool, inout bit<32> outPort);
    void sendReward(in bit<1> valid_bool, in bit<32> qTime);
}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(in headers hdr, inout metadata meta) {
    apply {  }
}

/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    @userextern @name("ml_controller")
    MLController() ml_controller;

    bit<32> outP = 0x0;

    action printArray() {
        ml_controller.print();
    }

    action choosePort() {
        ml_controller.getOutputPort(meta.identifier, meta.valid_bool, outP);
    }

    action pushAddress() {
        ml_controller.pushAddr(hdr.ipv4.dstAddr, meta.identifier, meta.valid_bool);
    }

    apply {
        pushAddress();
        choosePort();
        printArray();
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {

    @userextern @name("ml_controller")
    MLController() ml_controller;

    action popAddress () {
        ml_controller.popAddr(meta.identifier, meta.valid_bool);
    }

    action printArray() {
        ml_controller.print();
    }

    apply {
        popAddress();
        ml_controller.sendReward(meta.valid_bool, standard_metadata.deq_timedelta);
    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
     apply {

    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

//switch architecture
V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
