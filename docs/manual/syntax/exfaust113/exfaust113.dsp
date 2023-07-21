
import("stdfaust.lib");
freqS = vslider("h:Oscillators/h:[0]Sawtooth/[0]freq",440,50,1000,0.1);
gainS = vslider("h:Oscillators/h:[0]Sawtooth/[1]gain",0,0,1,0.01);
freqT = vslider("h:Oscillators/h:[1]Triangle/[0]freq",440,50,1000,0.1);
gainT = vslider("h:Oscillators/h:[1]Triangle/[1]gain",0,0,1,0.01);
process = os.sawtooth(freqS)*gainS + os.triangle(freqT)*gainT;

