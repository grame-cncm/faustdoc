
import("stdfaust.lib");
s = nentry("Selector",0,0,2,1);
mySelect3(s) = *(s==0),*(s==1),*(s==2) :> _;
sig = os.osc(440),os.sawtooth(440),os.triangle(440) : mySelect3(s);
process = sig;

