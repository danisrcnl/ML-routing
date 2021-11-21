#include <core.p4>
#include <v1model.p4>

struct intrinsic_metadata_t {
    bit<4>  mcast_grp;
    bit<4>  egress_rid;
    bit<16> mcast_hash;
    bit<32> lf_field_list;
}

struct meta_t {
    bit<1>  do_forward;
    bit<32> ipv4_sa;
    bit<32> ipv4_da;
    bit<16> tcp_sp;
    bit<16> tcp_dp;
    bit<32> nhop_ipv4;
    bit<32> if_ipv4_addr;
    bit<48> if_mac_addr;
    bit<1>  is_ext_if;
    bit<16> tcpLength;
    bit<8>  if_index;
}

header cpu_header_t {
    bit<64> preamble;
    bit<8>  device;
    bit<8>  reason;
    bit<8>  if_index;
}

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<4>  res;
    bit<8>  flags;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

struct metadata {
    @name("intrinsic_metadata") 
    intrinsic_metadata_t intrinsic_metadata;
    @name("meta") 
    meta_t               meta;
}

struct headers {
    @name("cpu_header") 
    cpu_header_t cpu_header;
    @name("ethernet") 
    ethernet_t   ethernet;
    @name("ipv4") 
    ipv4_t       ipv4;
    @name("tcp") 
    tcp_t        tcp;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    bit<64> tmp_7;
    @name("parse_cpu_header") state parse_cpu_header {
        packet.extract<cpu_header_t>(hdr.cpu_header);
        meta.meta.if_index = hdr.cpu_header.if_index;
        transition parse_ethernet;
    }
    @name("parse_ethernet") state parse_ethernet {
        packet.extract<ethernet_t>(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    @name("parse_ipv4") state parse_ipv4 {
        packet.extract<ipv4_t>(hdr.ipv4);
        meta.meta.ipv4_sa = hdr.ipv4.srcAddr;
        meta.meta.ipv4_da = hdr.ipv4.dstAddr;
        meta.meta.tcpLength = hdr.ipv4.totalLen + 16w65516;
        transition select(hdr.ipv4.protocol) {
            8w0x6: parse_tcp;
            default: accept;
        }
    }
    @name("parse_tcp") state parse_tcp {
        packet.extract<tcp_t>(hdr.tcp);
        meta.meta.tcp_sp = hdr.tcp.srcPort;
        meta.meta.tcp_dp = hdr.tcp.dstPort;
        transition accept;
    }
    @name("start") state start {
        meta.meta.if_index = (bit<8>)standard_metadata.ingress_port;
        tmp_7 = packet.lookahead<bit<64>>();
        transition select(tmp_7[63:0]) {
            64w0: parse_cpu_header;
            default: parse_ethernet;
        }
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("NoAction") action NoAction_0() {
    }
    @name("NoAction") action NoAction_1() {
    }
    @name(".do_rewrites") action do_rewrites_0(bit<48> smac) {
        hdr.cpu_header.setInvalid();
        hdr.ethernet.srcAddr = smac;
        hdr.ipv4.srcAddr = meta.meta.ipv4_sa;
        hdr.ipv4.dstAddr = meta.meta.ipv4_da;
        hdr.tcp.srcPort = meta.meta.tcp_sp;
        hdr.tcp.dstPort = meta.meta.tcp_dp;
    }
    @name("._drop") action _drop_0() {
        mark_to_drop();
    }
    @name(".do_cpu_encap") action do_cpu_encap_0() {
        hdr.cpu_header.setValid();
        hdr.cpu_header.preamble = 64w0;
        hdr.cpu_header.device = 8w0;
        hdr.cpu_header.reason = 8w0xab;
        hdr.cpu_header.if_index = meta.meta.if_index;
    }
    @name("send_frame") table send_frame {
        actions = {
            do_rewrites_0();
            _drop_0();
            @default_only NoAction_0();
        }
        key = {
            standard_metadata.egress_port: exact @name("standard_metadata.egress_port") ;
        }
        size = 256;
        default_action = NoAction_0();
    }
    @name("send_to_cpu") table send_to_cpu {
        actions = {
            do_cpu_encap_0();
            @default_only NoAction_1();
        }
        default_action = NoAction_1();
    }
    apply {
        if (standard_metadata.instance_type == 32w0) 
            send_frame.apply();
        else 
            send_to_cpu.apply();
    }
}

struct tuple_0 {
    standard_metadata_t field;
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("NoAction") action NoAction_8() {
    }
    @name("NoAction") action NoAction_9() {
    }
    @name("NoAction") action NoAction_10() {
    }
    @name("NoAction") action NoAction_11() {
    }
    @name(".set_dmac") action set_dmac_0(bit<48> dmac) {
        hdr.ethernet.dstAddr = dmac;
    }
    @name("._drop") action _drop_1() {
        mark_to_drop();
    }
    @name("._drop") action _drop_6() {
        mark_to_drop();
    }
    @name("._drop") action _drop_7() {
        mark_to_drop();
    }
    @name("._drop") action _drop_8() {
        mark_to_drop();
    }
    @name(".set_if_info") action set_if_info_0(bit<32> ipv4_addr, bit<48> mac_addr, bit<1> is_ext) {
        meta.meta.if_ipv4_addr = ipv4_addr;
        meta.meta.if_mac_addr = mac_addr;
        meta.meta.is_ext_if = is_ext;
    }
    @name(".set_nhop") action set_nhop_0(bit<32> nhop_ipv4, bit<9> port) {
        meta.meta.nhop_ipv4 = nhop_ipv4;
        standard_metadata.egress_spec = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl + 8w255;
    }
    @name(".nat_miss_int_to_ext") action nat_miss_int_to_ext_0() {
        clone3<tuple_0>(CloneType.I2E, 32w250, { standard_metadata });
    }
    @name(".nat_miss_ext_to_int") action nat_miss_ext_to_int_0() {
        meta.meta.do_forward = 1w0;
        mark_to_drop();
    }
    @name(".nat_hit_int_to_ext") action nat_hit_int_to_ext_0(bit<32> srcAddr, bit<16> srcPort) {
        meta.meta.do_forward = 1w1;
        meta.meta.ipv4_sa = srcAddr;
        meta.meta.tcp_sp = srcPort;
    }
    @name(".nat_hit_ext_to_int") action nat_hit_ext_to_int_0(bit<32> dstAddr, bit<16> dstPort) {
        meta.meta.do_forward = 1w1;
        meta.meta.ipv4_da = dstAddr;
        meta.meta.tcp_dp = dstPort;
    }
    @name(".nat_no_nat") action nat_no_nat_0() {
        meta.meta.do_forward = 1w1;
    }
    @name("forward") table forward {
        actions = {
            set_dmac_0();
            _drop_1();
            @default_only NoAction_8();
        }
        key = {
            meta.meta.nhop_ipv4: exact @name("meta.meta.nhop_ipv4") ;
        }
        size = 512;
        default_action = NoAction_8();
    }
    @name("if_info") table if_info {
        actions = {
            _drop_6();
            set_if_info_0();
            @default_only NoAction_9();
        }
        key = {
            meta.meta.if_index: exact @name("meta.meta.if_index") ;
        }
        default_action = NoAction_9();
    }
    @name("ipv4_lpm") table ipv4_lpm {
        actions = {
            set_nhop_0();
            _drop_7();
            @default_only NoAction_10();
        }
        key = {
            meta.meta.ipv4_da: lpm @name("meta.meta.ipv4_da") ;
        }
        size = 1024;
        default_action = NoAction_10();
    }
    @name("nat") table nat {
        actions = {
            _drop_8();
            nat_miss_int_to_ext_0();
            nat_miss_ext_to_int_0();
            nat_hit_int_to_ext_0();
            nat_hit_ext_to_int_0();
            nat_no_nat_0();
            @default_only NoAction_11();
        }
        key = {
            meta.meta.is_ext_if: exact @name("meta.meta.is_ext_if") ;
            hdr.ipv4.isValid() : exact @name("hdr.ipv4.isValid()") ;
            hdr.tcp.isValid()  : exact @name("hdr.tcp.isValid()") ;
            hdr.ipv4.srcAddr   : ternary @name("hdr.ipv4.srcAddr") ;
            hdr.ipv4.dstAddr   : ternary @name("hdr.ipv4.dstAddr") ;
            hdr.tcp.srcPort    : ternary @name("hdr.tcp.srcPort") ;
            hdr.tcp.dstPort    : ternary @name("hdr.tcp.dstPort") ;
        }
        size = 128;
        default_action = NoAction_11();
    }
    apply {
        if_info.apply();
        nat.apply();
        if (meta.meta.do_forward == 1w1 && hdr.ipv4.ttl > 8w0) {
            ipv4_lpm.apply();
            forward.apply();
        }
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<cpu_header_t>(hdr.cpu_header);
        packet.emit<ethernet_t>(hdr.ethernet);
        packet.emit<ipv4_t>(hdr.ipv4);
        packet.emit<tcp_t>(hdr.tcp);
    }
}

struct tuple_1 {
    bit<4>  field_0;
    bit<4>  field_1;
    bit<8>  field_2;
    bit<16> field_3;
    bit<16> field_4;
    bit<3>  field_5;
    bit<13> field_6;
    bit<8>  field_7;
    bit<8>  field_8;
    bit<32> field_9;
    bit<32> field_10;
}

struct tuple_2 {
    bit<32> field_11;
    bit<32> field_12;
    bit<8>  field_13;
    bit<8>  field_14;
    bit<16> field_15;
    bit<16> field_16;
    bit<16> field_17;
    bit<32> field_18;
    bit<32> field_19;
    bit<4>  field_20;
    bit<4>  field_21;
    bit<8>  field_22;
    bit<16> field_23;
    bit<16> field_24;
}

control verifyChecksum(in headers hdr, inout metadata meta) {
    bit<16> tmp_8;
    bool tmp_10;
    bit<16> tmp_11;
    @name("ipv4_checksum") Checksum16() ipv4_checksum;
    @name("tcp_checksum") Checksum16() tcp_checksum;
    apply {
        tmp_8 = ipv4_checksum.get<tuple_1>({ hdr.ipv4.version, hdr.ipv4.ihl, hdr.ipv4.diffserv, hdr.ipv4.totalLen, hdr.ipv4.identification, hdr.ipv4.flags, hdr.ipv4.fragOffset, hdr.ipv4.ttl, hdr.ipv4.protocol, hdr.ipv4.srcAddr, hdr.ipv4.dstAddr });
        if (hdr.ipv4.hdrChecksum == tmp_8) 
            mark_to_drop();
        if (!hdr.tcp.isValid()) 
            tmp_10 = false;
        else {
            tmp_11 = tcp_checksum.get<tuple_2>({ hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, 8w0, hdr.ipv4.protocol, meta.meta.tcpLength, hdr.tcp.srcPort, hdr.tcp.dstPort, hdr.tcp.seqNo, hdr.tcp.ackNo, hdr.tcp.dataOffset, hdr.tcp.res, hdr.tcp.flags, hdr.tcp.window, hdr.tcp.urgentPtr });
            tmp_10 = hdr.tcp.checksum == tmp_11;
        }
        if (tmp_10) 
            mark_to_drop();
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    bit<16> tmp_13;
    bit<16> tmp_14;
    @name("ipv4_checksum") Checksum16() ipv4_checksum_2;
    @name("tcp_checksum") Checksum16() tcp_checksum_2;
    apply {
        tmp_13 = ipv4_checksum_2.get<tuple_1>({ hdr.ipv4.version, hdr.ipv4.ihl, hdr.ipv4.diffserv, hdr.ipv4.totalLen, hdr.ipv4.identification, hdr.ipv4.flags, hdr.ipv4.fragOffset, hdr.ipv4.ttl, hdr.ipv4.protocol, hdr.ipv4.srcAddr, hdr.ipv4.dstAddr });
        hdr.ipv4.hdrChecksum = tmp_13;
        if (hdr.tcp.isValid()) {
            tmp_14 = tcp_checksum_2.get<tuple_2>({ hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, 8w0, hdr.ipv4.protocol, meta.meta.tcpLength, hdr.tcp.srcPort, hdr.tcp.dstPort, hdr.tcp.seqNo, hdr.tcp.ackNo, hdr.tcp.dataOffset, hdr.tcp.res, hdr.tcp.flags, hdr.tcp.window, hdr.tcp.urgentPtr });
            hdr.tcp.checksum = tmp_14;
        }
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;