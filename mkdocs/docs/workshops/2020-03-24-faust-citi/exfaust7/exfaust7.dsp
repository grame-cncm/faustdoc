
import("stdfaust.lib");

// Mathematical square wave doesn't sound great because of aliasing
phasor(f) = f/ma.SR : (+,1:fmod)~_;
exactsquarewave(f) = (os.phasor(1,f)>0.5)*2.0-1.0;
process = exactsquarewave(hslider("freq", 440, 20, 8000, 1))*hslider("gain", 0.5, 0, 1, 0.01);

