
import("stdfaust.lib");
freq = vslider("h:Oscillator/freq",440,50,1000,0.1);
gain = vslider("h:Oscillator/gain",0,0,1,0.01);
process = os.sawtooth(freq)*gain;

