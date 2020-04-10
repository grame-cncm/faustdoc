
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
        : fi.resonlp(
                hslider("hifreq", 400, 20, 20000, 1),
                hslider("Q", 1, 1, 100, 0.01),
                hslider("gain", 1, 0, 2, 0.01));

