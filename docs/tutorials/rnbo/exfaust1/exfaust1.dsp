
import("stdfaust.lib");

process = vmeter,hmeter
with {
    vmeter(x) = attach(x, envelop(x) : vbargraph("vmeter dB [midi:ctrl 1]", -96, 10));
    hmeter(x) = attach(x, envelop(x) : hbargraph("hmeter dB [midi:ctrl 2]", -96, 10));

    envelop = abs : max(ba.db2linear(-96)) : ba.linear2db : min(10) : max ~ -(96.0/ma.SR);
};

