
import("stdfaust.lib");

// Karplus-Strong (1/2)
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) :
        + ~ transformation;
        
transformation = @(hslider("delay", 0, 0, 200, 1)) : mean : *(hslider("gain", 0, -0.98, 0.98, 0.01));

mean(x) = (x+x')/2;

