
import("stdfaust.lib");
decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _;
timbre(f) = phase(f)*0.5 + phase(f*2)*0.25 + phase(f*3)*0.125;

process = timbre(hslider("freq", 440, 20, 10000, 1)) 
* hslider("gain", 0.5, 0, 1, 0.01) 
* (button("gate") : en.adsr(0.1,0.1,0.98,0.1));

effect = dm.zita_light;

