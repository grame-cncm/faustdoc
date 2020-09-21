
import("stdfaust.lib");

// FIR
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
        <: _, transformation :> _;

transformation = @(1) : *(hslider("gain", 0, -1, 1, 0.1));

