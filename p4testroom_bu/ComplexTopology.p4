/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

#include "include/headers.p4"
#include "include/parsers.p4"

extern MLController {
    MLController();
    void simulate_computation();
    void print();
    void pushAddr(in macAddr_t mac, in ip4Addr_t address, inout bit<32> pos, in bit<1> valid_bool);
    void popAddr(in macAddr_t mac, in bit<32> pos, in bit<1> valid_bool);
    void getOutputPort(in macAddr_t mac, in bit<32> pos, in bit<1> valid_bool, inout bit<9> outPort, inout bit<1> doForward);
    void sendReward(in bit<1> valid_bool, in bit<32> qTime);
    void setAsIngress();
    void setAsEgress();
    void getNeighborMac(inout macAddr_t mac, in bit<9> port, inout bit<1> doForward);
    void logFw(in macAddr_t macsrc, in macAddr_t macdst, in bit<9> port);
    void logDrop_f(in macAddr_t macsrc, in macAddr_t macdst, in bit<9> in_port);
    void logFw_f(in macAddr_t macsrc, in macAddr_t macdst, in ip4Addr_t ipdst, in bit<9> in_port, in bit<9> out_port, in macAddr_t destination);
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

    bit<9> outP = 0x0;
    macAddr_t dstMac;
    bit<1> fw = 0;

    action setAsIngress() {
        ml_controller.setAsIngress();
    }

    action printArray() {
        ml_controller.print();
    }

    action choosePort() {
        ml_controller.getOutputPort(hdr.ethernet.dstAddr, meta.identifier, meta.valid_bool, outP, fw);
    }

    action pushAddress() {
        ml_controller.pushAddr(hdr.ethernet.dstAddr, hdr.ipv4.dstAddr, meta.identifier, meta.valid_bool);
    }

    action getNeighbor(bit<9> port) {
        dstMac = hdr.ethernet.dstAddr;
        ml_controller.getNeighborMac(dstMac, port, fw);
    }

    action ipv4_forward(macAddr_t dstAddr, bit<9> port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    apply {
        setAsIngress();
        pushAddress();
        choosePort();
        if (fw == 1) {
            getNeighbor(outP);
            if (fw == 1) {
                ml_controller.logFw_f(hdr.ethernet.srcAddr, hdr.ethernet.dstAddr, hdr.ipv4.dstAddr, standard_metadata.ingress_port, outP, dstMac);
                ipv4_forward(dstMac, outP);
            }
            if (fw == 0) {
                ml_controller.logDrop_f(hdr.ethernet.srcAddr, hdr.ethernet.dstAddr, standard_metadata.ingress_port);
                mark_to_drop();
            }
        }
        if (fw == 0) {
            ml_controller.logDrop_f(hdr.ethernet.srcAddr, hdr.ethernet.dstAddr, standard_metadata.ingress_port);
            mark_to_drop();
        }

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

    action setAsEgress () {
        ml_controller.setAsEgress();
    }

    action popAddress () {
        ml_controller.popAddr(hdr.ethernet.srcAddr, meta.identifier, meta.valid_bool);
    }

    action printArray() {
        ml_controller.print();
    }

    apply {
        setAsEgress();
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
