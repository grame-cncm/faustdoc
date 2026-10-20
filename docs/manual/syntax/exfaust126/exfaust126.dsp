
import("stdfaust.lib");
freq = vslider("freq[unit:Hz]",440,50,1000,0.1);
process = os.sawtooth(freq);

