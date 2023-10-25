
import("stdfaust.lib");
freq = hslider("freq",440,50,1000,0.1);
gain = hslider("gain",0,0,1,0.01);
process = tgroup("Oscillator",os.sawtooth(freq)*gain);

