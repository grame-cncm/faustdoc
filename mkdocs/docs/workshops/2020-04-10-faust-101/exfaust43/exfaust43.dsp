
import("stdfaust.lib");

// IIR, comb filter
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) :
        + ~ transformation;
        
transformation = @(hslider("delay", 0, 0, 20, 1)) : *(hslider("gain", 0, -0.98, 0.98, 0.01));

