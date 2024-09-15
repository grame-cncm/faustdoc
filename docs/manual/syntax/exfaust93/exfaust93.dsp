
import("stdfaust.lib");
s = nentry("Selector",0,0,2,1);
sig = os.osc(440),os.sawtooth(440),os.triangle(440) : select3(s);
process = sig;

