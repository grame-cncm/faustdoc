
import("stdfaust.lib");

decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _;

sawtooth(f) = phase(f) * 2 - 1;

process = sawtooth(440);

