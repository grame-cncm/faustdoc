
import("stdfaust.lib");
freq = hslider("[0]freq",440,50,3000,0.01);
gain = hslider("[1]gain",1,0,1,0.01);
shift = hslider("[2]shift",0,0,1,0.01);
gate = button("[3]gate");
envelope = gain*gate : si.smoo;
nOscs = 4;
process = prod(i,nOscs,os.osc(freq*(i+1+shift)))*envelope;

