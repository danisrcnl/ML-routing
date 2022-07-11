/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

#include "include/headers.p4"
#include "include/parsers.p4"

extern MLController {
    MLController();
    void simulate_computation();
    void print();
    void pushAddr(in macAddr_t mac, in ip4Addr_t address, inout bit<32> pos, in bit<1> valid_bool, inout bit<1> update_entry);
    void popAddr(in macAddr_t mac, in bit<32> pos, in bit<1> valid_bool);
    void getOutputPort(in macAddr_t mac, in bit<32> pos, in bit<1> valid_bool, inout bit<9> outPort, inout bit<1> doForward, inout bit<32> id);
    void sendReward(in bit<1> valid_bool, in bit<32> qTime, in bit<32> id);
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
    bit<1> update_entry = 0;

    action drop () {
        mark_to_drop();
    }

    action setAsIngress() {
        ml_controller.setAsIngress();
    }

    action printArray() {
        ml_controller.print();
    }

    action choosePort() {
        ml_controller.getOutputPort(hdr.ethernet.dstAddr, meta.identifier, meta.valid_bool, outP, fw, meta.id);
    }

    action pushAddress() {
        ml_controller.pushAddr(hdr.ethernet.dstAddr, hdr.ipv4.dstAddr, meta.identifier, meta.valid_bool, update_entry);
    }

    action getNeighbor(bit<9> port) {
        dstMac = hdr.ethernet.dstAddr;
        ml_controller.getNeighborMac(dstMac, port, fw);
    }

    action ipv4_forward_rl(macAddr_t dstAddr, bit<9> port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    apply {
        setAsIngress();
        pushAddress();
        if (update_entry == 1) {
            choosePort();
            if (fw == 1) {
                getNeighbor(outP);
                if (fw == 1) {
                    ipv4_forward_rl(dstMac, outP);
                }
                if (fw == 0) {
                    mark_to_drop();
                }
            }
            if (fw == 0) {
                mark_to_drop();
            }
        }
        if (update_entry == 0 && hdr.ipv4.isValid()) {
            ipv4_lpm.apply();
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
    
    action sendReward() {
        ml_controller.sendReward(meta.valid_bool, standard_metadata.deq_timedelta, meta.id);
    }

    apply {
        setAsEgress();
        popAddress();
        sendReward();
    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    Checksum16() ckip;

     apply {

         hdr.ipv4.hdrChecksum = ckip.get({
             hdr.ipv4.version,
             hdr.ipv4.ihl,
             hdr.ipv4.dscp,
             hdr.ipv4.ecn,
             hdr.ipv4.totalLen,
             hdr.ipv4.identification,
             hdr.ipv4.flags,
             hdr.ipv4.fragOffset,
             hdr.ipv4.ttl,
             hdr.ipv4.protocol,
             hdr.ipv4.srcAddr,
             hdr.ipv4.dstAddr
         });

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
