
import("stdfaust.lib");
s = nentry("Selector",0,0,1,1) : int;
sig = os.osc(440),os.sawtooth(440) : select2(s);
process = sig;

