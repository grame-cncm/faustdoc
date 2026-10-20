
import("stdfaust.lib");
freq = vslider("freq[style:knob]",440,50,1000,0.1);
process = os.sawtooth(freq);

