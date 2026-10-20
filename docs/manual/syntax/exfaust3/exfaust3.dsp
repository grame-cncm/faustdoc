
smooth(c) = *(1-c) : + ~ *(c);
gain = hslider("gain", 0.5, 0, 1, 0.01);
process = _ <: (smooth(0.9) * gain), (*(-1) : @(10));

