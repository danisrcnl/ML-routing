#include <core.p4>
#include <v1model.p4>

header data_t {
    bit<32> f1;
    bit<32> f2;
    bit<16> h1;
    bit<8>  b1;
    bit<8>  b2;
}

header extra_t {
    bit<16> h;
    bit<8>  b1;
    bit<8>  b2;
}

struct metadata {
}

struct headers {
    @name("data") 
    data_t     data;
    @name("extra") 
    extra_t[4] extra;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("extra") state extra {
        packet.extract(hdr.extra.next);
        transition select(hdr.extra.last.b2) {
            8w0x80 &&& 8w0x80: extra;
            default: accept;
        }
    }
    @name("start") state start {
        packet.extract(hdr.data);
        transition extra;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".set0b1") action set0b1(bit<8> val) {
        hdr.extra[0].b1 = (bit<8>)val;
    }
    @name(".act1") action act1(bit<8> val) {
        hdr.extra[0].b1 = (bit<8>)val;
    }
    @name(".act2") action act2(bit<8> val) {
        hdr.extra[0].b1 = (bit<8>)val;
    }
    @name(".act3") action act3(bit<8> val) {
        hdr.extra[0].b1 = (bit<8>)val;
    }
    @name(".noop") action noop() {
    }
    @name(".setb2") action setb2(bit<8> val) {
        hdr.data.b2 = (bit<8>)val;
    }
    @name(".set1b1") action set1b1(bit<8> val) {
        hdr.extra[1].b1 = (bit<8>)val;
    }
    @name(".set2b2") action set2b2(bit<8> val) {
        hdr.extra[2].b2 = (bit<8>)val;
    }
    @name(".setb1") action setb1(bit<9> port, bit<8> val) {
        hdr.data.b1 = (bit<8>)val;
        standard_metadata.egress_spec = (bit<9>)port;
    }
    @name("ex1") table ex1 {
        actions = {
            set0b1;
            act1;
            act2;
            act3;
            noop;
            @default_only NoAction;
        }
        key = {
            hdr.extra[0].h: ternary;
        }
        default_action = NoAction();
    }
    @name("tbl1") table tbl1 {
        actions = {
            setb2;
            noop;
            @default_only NoAction;
        }
        key = {
            hdr.data.f2: ternary;
        }
        default_action = NoAction();
    }
    @name("tbl2") table tbl2 {
        actions = {
            set1b1;
            noop;
            @default_only NoAction;
        }
        key = {
            hdr.data.f2: ternary;
        }
        default_action = NoAction();
    }
    @name("tbl3") table tbl3 {
        actions = {
            set2b2;
            noop;
            @default_only NoAction;
        }
        key = {
            hdr.data.f2: ternary;
        }
        default_action = NoAction();
    }
    @name("test1") table test1 {
        actions = {
            setb1;
            noop;
            @default_only NoAction;
        }
        key = {
            hdr.data.f1: ternary;
        }
        default_action = NoAction();
    }
    apply {
        test1.apply();
        switch (ex1.apply().action_run) {
            act1: {
                tbl1.apply();
            }
            act2: {
                tbl2.apply();
            }
            act3: {
                tbl3.apply();
            }
        }

    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.data);
        packet.emit(hdr.extra);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
