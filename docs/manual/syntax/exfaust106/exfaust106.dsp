
import("stdfaust.lib");
freq = vslider("freq",440,50,1000,0.1);
gain = vslider("gain",0,0,1,0.01);
process = hgroup("Oscillator",os.sawtooth(freq)*gain);

