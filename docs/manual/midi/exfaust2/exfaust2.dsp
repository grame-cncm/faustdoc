
import("stdfaust.lib");
freq = hslider("frequency[midi:keyoff 62]",200,50,1000,0.01) : si.smoo;
process = os.sawtooth(freq);

