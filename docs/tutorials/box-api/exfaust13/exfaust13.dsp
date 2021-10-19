
 import("stdfaust.lib");
 process = osc(440), osc(440)
 with {
    decimalpart(x) = x-int(x);
    phasor(f) = f/ma.SR : (+ : decimalpart) ~ _;
    osc(f) = sin(2 * ma.PI * phasor(f));
 };

