
import("stdfaust.lib");
freq = vslider("freq[tooltip:The frequency of the oscillator]",440,50,1000,0.1);
process = os.sawtooth(freq);

