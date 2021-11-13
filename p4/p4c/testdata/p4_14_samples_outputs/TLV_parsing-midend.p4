header ipv4_option_timestamp_t_1 {
    bit<8> value;
    bit<8> len;
}

header ipv4_option_timestamp_t_2 {
    varbit<304> data;
}

#include <core.p4>
#include <v1model.p4>

struct intrinsic_metadata_t {
    bit<4>  mcast_grp;
    bit<4>  egress_rid;
    bit<16> mcast_hash;
    bit<32> lf_field_list;
}

struct my_metadata_t {
    bit<8> parse_ipv4_counter;
}

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header ipv4_base_t {
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

header ipv4_option_security_t {
    bit<8>  value;
    bit<8>  len;
    bit<72> security;
}

header ipv4_option_timestamp_t {
    bit<8>      value;
    bit<8>      len;
    @length(len) 
    varbit<304> data;
}

header ipv4_option_EOL_t {
    bit<8> value;
}

header ipv4_option_NOP_t {
    bit<8> value;
}

struct metadata {
    @name("intrinsic_metadata") 
    intrinsic_metadata_t intrinsic_metadata;
    @name("my_metadata") 
    my_metadata_t        my_metadata;
}

struct headers {
    @name("ethernet") 
    ethernet_t              ethernet;
    @name("ipv4_base") 
    ipv4_base_t             ipv4_base;
    @name("ipv4_option_security") 
    ipv4_option_security_t  ipv4_option_security;
    @name("ipv4_option_timestamp") 
    ipv4_option_timestamp_t ipv4_option_timestamp;
    @name("ipv4_option_EOL") 
    ipv4_option_EOL_t[3]    ipv4_option_EOL;
    @name("ipv4_option_NOP") 
    ipv4_option_NOP_t[3]    ipv4_option_NOP;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    ipv4_option_timestamp_t_1 tmp_hdr;
    ipv4_option_timestamp_t_2 tmp_hdr_0;
    bit<8> tmp_1;
    @name("parse_ethernet") state parse_ethernet {
        packet.extract<ethernet_t>(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    @name("parse_ipv4") state parse_ipv4 {
        packet.extract<ipv4_base_t>(hdr.ipv4_base);
        meta.my_metadata.parse_ipv4_counter = (bit<8>)((hdr.ipv4_base.ihl << 2) + 4w12);
        transition select(hdr.ipv4_base.ihl) {
            4w0x5: accept;
            default: parse_ipv4_options;
        }
    }
    @name("parse_ipv4_option_EOL") state parse_ipv4_option_EOL {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_EOL.next);
        meta.my_metadata.parse_ipv4_counter = meta.my_metadata.parse_ipv4_counter + 8w255;
        transition parse_ipv4_options;
    }
    @name("parse_ipv4_option_NOP") state parse_ipv4_option_NOP {
        packet.extract<ipv4_option_EOL_t>(hdr.ipv4_option_NOP.next);
        meta.my_metadata.parse_ipv4_counter = meta.my_metadata.parse_ipv4_counter + 8w255;
        transition parse_ipv4_options;
    }
    @name("parse_ipv4_option_security") state parse_ipv4_option_security {
        packet.extract<ipv4_option_security_t>(hdr.ipv4_option_security);
        meta.my_metadata.parse_ipv4_counter = meta.my_metadata.parse_ipv4_counter + 8w245;
        transition parse_ipv4_options;
    }
    @name("parse_ipv4_option_timestamp") state parse_ipv4_option_timestamp {
        packet.extract<ipv4_option_timestamp_t_1>(tmp_hdr);
        packet.extract<ipv4_option_timestamp_t_2>(tmp_hdr_0, (bit<32>)tmp_hdr.len);
        hdr.ipv4_option_timestamp.setValid();
        hdr.ipv4_option_timestamp.value = tmp_hdr.value;
        hdr.ipv4_option_timestamp.len = tmp_hdr.len;
        hdr.ipv4_option_timestamp.data = tmp_hdr_0.data;
        meta.my_metadata.parse_ipv4_counter = meta.my_metadata.parse_ipv4_counter - hdr.ipv4_option_timestamp.len;
        transition parse_ipv4_options;
    }
    @name("parse_ipv4_options") state parse_ipv4_options {
        tmp_1 = packet.lookahead<bit<8>>();
        transition select(meta.my_metadata.parse_ipv4_counter, tmp_1[7:0]) {
            (8w0x0 &&& 8w0xff, 8w0x0 &&& 8w0x0): accept;
            (8w0x0 &&& 8w0x0, 8w0x0 &&& 8w0xff): parse_ipv4_option_EOL;
            (8w0x0 &&& 8w0x0, 8w0x1 &&& 8w0xff): parse_ipv4_option_NOP;
            (8w0x0 &&& 8w0x0, 8w0x82 &&& 8w0xff): parse_ipv4_option_security;
            (8w0x0 &&& 8w0x0, 8w0x44 &&& 8w0xff): parse_ipv4_option_timestamp;
            default: noMatch;
        }
    }
    @header_ordering("ethernet", "ipv4_base", "ipv4_option_security", "ipv4_option_NOP", "ipv4_option_timestamp", "ipv4_option_EOL") @name("start") state start {
        transition parse_ethernet;
    }
    state noMatch {
        verify(false, error.NoMatch);
        transition reject;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("NoAction") action NoAction_0() {
    }
    @name(".format_options_security") action format_options_security_0() {
        hdr.ipv4_option_NOP.pop_front(3);
        hdr.ipv4_option_EOL.pop_front(3);
        hdr.ipv4_option_EOL.push_front(1);
        hdr.ipv4_base.ihl = 4w8;
    }
    @name(".format_options_timestamp") action format_options_timestamp_0() {
        hdr.ipv4_option_NOP.pop_front(3);
        hdr.ipv4_option_EOL.pop_front(3);
        hdr.ipv4_base.ihl = (bit<4>)(8w5 + (hdr.ipv4_option_timestamp.len >> 8w3));
    }
    @name(".format_options_both") action format_options_both_0() {
        hdr.ipv4_option_NOP.pop_front(3);
        hdr.ipv4_option_EOL.pop_front(3);
        hdr.ipv4_option_NOP.push_front(1);
        hdr.ipv4_option_NOP[0].value = 8w0x1;
        hdr.ipv4_base.ihl = (bit<4>)(8w8 + (hdr.ipv4_option_timestamp.len >> 8w2));
    }
    @name("._nop") action _nop_0() {
    }
    @name("format_options") table format_options {
        actions = {
            format_options_security_0();
            format_options_timestamp_0();
            format_options_both_0();
            _nop_0();
            @default_only NoAction_0();
        }
        key = {
            hdr.ipv4_option_security.isValid() : exact @name("hdr.ipv4_option_security.isValid()") ;
            hdr.ipv4_option_timestamp.isValid(): exact @name("hdr.ipv4_option_timestamp.isValid()") ;
        }
        size = 4;
        default_action = NoAction_0();
    }
    apply {
        format_options.apply();
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<ethernet_t>(hdr.ethernet);
        packet.emit<ipv4_base_t>(hdr.ipv4_base);
        packet.emit<ipv4_option_EOL_t[3]>(hdr.ipv4_option_EOL);
        packet.emit<ipv4_option_EOL_t[3]>(hdr.ipv4_option_NOP);
        packet.emit<ipv4_option_security_t>(hdr.ipv4_option_security);
        packet.emit<ipv4_option_timestamp_t>(hdr.ipv4_option_timestamp);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta) {
    apply {
    }
}

struct tuple_0 {
    bit<4>                  field;
    bit<4>                  field_0;
    bit<8>                  field_1;
    bit<16>                 field_2;
    bit<16>                 field_3;
    bit<3>                  field_4;
    bit<13>                 field_5;
    bit<8>                  field_6;
    bit<8>                  field_7;
    bit<32>                 field_8;
    bit<32>                 field_9;
    ipv4_option_security_t  field_10;
    ipv4_option_EOL_t       field_11;
    ipv4_option_timestamp_t field_12;
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    bit<16> tmp_2;
    @name("ipv4_checksum") Checksum16() ipv4_checksum;
    apply {
        tmp_2 = ipv4_checksum.get<tuple_0>({ hdr.ipv4_base.version, hdr.ipv4_base.ihl, hdr.ipv4_base.diffserv, hdr.ipv4_base.totalLen, hdr.ipv4_base.identification, hdr.ipv4_base.flags, hdr.ipv4_base.fragOffset, hdr.ipv4_base.ttl, hdr.ipv4_base.protocol, hdr.ipv4_base.srcAddr, hdr.ipv4_base.dstAddr, hdr.ipv4_option_security, hdr.ipv4_option_NOP[0], hdr.ipv4_option_timestamp });
        hdr.ipv4_base.hdrChecksum = tmp_2;
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
