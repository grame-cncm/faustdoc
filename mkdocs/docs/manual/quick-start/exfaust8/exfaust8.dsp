
import("stdfaust.lib");
ctFreq = hslider("cutoffFrequency",500,50,10000,0.01);
q = hslider("q",5,1,30,0.1);
gain = hslider("gain",1,0,1,0.01);
process = no.noise : fi.resonlp(ctFreq,q,gain);

