
import("stdfaust.lib");
s = nentry("Selector",0,0,1,1);
mySelect2(s) = *(s==0),*(s==1) :> _;
sig = os.osc(440),os.sawtooth(440) : mySelect2(s);
process = sig;

