
import("stdfaust.lib");
echo(d,f) = +~de.delay(48000,del)*f
with {
  del = d*ma.SR;
};
delay = nentry("delay",0.25,0,1,0.01) : si.smoo;
feedback = nentry("feedback",0.5,0,1,0.01) : si.smoo;
process = par(i,2,echo(delay,feedback));

