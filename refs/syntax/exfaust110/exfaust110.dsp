
import("stdfaust.lib");
s = vslider("Signal[style:menu{'Noise':0;'Sawtooth':1}]",0,0,1,1);
process = select2(s,no.noise,os.sawtooth(440));

