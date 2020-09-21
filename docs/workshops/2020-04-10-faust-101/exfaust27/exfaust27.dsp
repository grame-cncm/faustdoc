
import("stdfaust.lib");

decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _;
osc(f) = sin(phase(f) * 2 * ma.PI);

process = osc(440);

