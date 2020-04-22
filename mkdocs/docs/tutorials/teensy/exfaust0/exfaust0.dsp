
import("stdfaust.lib");
freq = nentry("freq",440,20,20000,0.01) : si.smoo;
gain = nentry("gain",1,0,1,0.01) : si.smoo;
process = os.sawtooth(freq)*gain;

