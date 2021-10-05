
import("stdfaust.lib");
process = osc(f1), osc(f2)
with {
    decimalpart(x) = x-int(x);
    phasor(f) = f/ma.SR : (+ : decimalpart) ~ _;
    osc(f) = sin(2 * ma.PI * phasor(f));
    f1 = vslider("Freq1", 300, 100, 2000, 0.01);
    f2 = vslider("Freq2", 500, 100, 2000, 0.01);
};

