
import("stdfaust.lib");

// Approximation of a square wave using additive synthesis

squarewave(f) = 4/ma.PI*sum(k, 8, os.osc((2*k+1)*f)/(2*k+1));

process = squarewave(55);

