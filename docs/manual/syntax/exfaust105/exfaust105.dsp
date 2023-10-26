
import("stdfaust.lib");
oscGroup(x) = hgroup("Oscillator",x);
freq = oscGroup(vslider("freq",440,50,1000,0.1));
gain = oscGroup(vslider("gain",0,0,1,0.01));
process = os.sawtooth(freq)*gain;

