
import("stdfaust.lib");
freq = hslider("frequency[midi:key 62]",200,50,1000,0.01) : si.smoo;
process = os.sawtooth(freq);

