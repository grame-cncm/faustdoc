
import("stdfaust.lib");
triangleWave = waveform{0,0.5,1,0.5,0,-0.5,-1,-.5};
triangleOsc(f) = triangleWave,int(os.phasor(8,f)) : rdtable;
f = hslider("freq",440,50,2000,0.01);
process = triangleOsc(f);

