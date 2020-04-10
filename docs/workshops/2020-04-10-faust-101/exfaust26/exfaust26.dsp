
import("stdfaust.lib");

decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _;

squarewave(f) = (phase(f) > 0.5) * 2 - 1;

process = squarewave(440);

