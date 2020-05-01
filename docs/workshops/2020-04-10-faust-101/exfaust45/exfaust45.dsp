
import("stdfaust.lib");

// Karplus Strong (2/2)
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
        : *(envelop)
        : + ~ transformation;
        
transformation = @(hslider("delay", 0, 0, 200, 1)) : moyenne : *(hslider("gain", 0, -0.999, 0.999, 0.001));

moyenne(x) = (x+x')/2;

envelop = button("gate") : upfront : en.ar(0.002, 0.01);

upfront(x) = x>x';

