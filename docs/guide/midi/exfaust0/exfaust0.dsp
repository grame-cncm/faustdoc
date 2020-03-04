
import("stdfaust.lib");
freq = hslider("frequency[midi:ctrl 11]",200,50,1000,0.01) : si.smoo;
process = os.sawtooth(freq);

