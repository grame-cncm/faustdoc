
import("stdfaust.lib");
freqS = vslider("[0]freq",440,50,1000,0.1);
gainS = vslider("[1]gain",0,0,1,0.01);
freqT = vslider("[0]freq",440,50,1000,0.1);
gainT = vslider("[1]gain",0,0,1,0.01);
process = hgroup("Oscillators",
  hgroup("[0]Sawtooth",os.sawtooth(freqS)*gainS) + 
  hgroup("[1]Triangle",os.triangle(freqT)*gainT)
);

