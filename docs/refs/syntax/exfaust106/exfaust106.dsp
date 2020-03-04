
import("stdfaust.lib");
freq = hslider("freq",440,50,1000,0.1) : si.smoo;
gain = hslider("gain",0,0,1,0.01) : si.smoo;
process = os.osc(freq)*gain;

