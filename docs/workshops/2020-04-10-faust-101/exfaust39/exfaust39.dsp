
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
: fi.highpass(3, hslider("lowfreq", 400, 20, 20000, 1))
: fi.lowpass(3, hslider("hifreq", 2000, 20, 20000, 1));


