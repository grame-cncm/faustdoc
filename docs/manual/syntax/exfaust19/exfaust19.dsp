
import("stdfaust.lib");
freq = hslider("freq",440,50,3000,0.01);
gain = hslider("gain",1,0,1,0.01);
gate = button("gate");
envelope = gain*gate : si.smoo;
nHarmonics = 4;
process = par(i,nHarmonics,os.osc(freq*(i+1))) :> /(nHarmonics)*envelope;

