
import("stdfaust.lib");
f = hslider("freq",440,50,2000,0.01);
phasor(freq) = (+(freq/ma.SR) ~ ma.decimal);
osc(freq) = sin(phasor(freq)*2*ma.PI);
process = osc(f);

