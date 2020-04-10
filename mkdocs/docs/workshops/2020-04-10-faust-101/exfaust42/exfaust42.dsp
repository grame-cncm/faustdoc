
import("stdfaust.lib");

// IIR
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) :
        + ~ transformation;
        
transformation = @(0) : *(hslider("gain", 0, -0.95, 0.95, 0.01));

