
import("stdfaust.lib");
oscGroup(x) = vgroup("Oscillator",x);
freq = oscGroup(hslider("freq",440,50,1000,0.1));
gain = oscGroup(hslider("gain",0,0,1,0.01));
process = os.sawtooth(freq)*gain;

