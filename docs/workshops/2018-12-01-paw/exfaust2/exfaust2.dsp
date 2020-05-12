
import("stdfaust.lib");
decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _;
osc(f) = phase(f) * 2 * ma.PI : sin;
process = osc(440);

