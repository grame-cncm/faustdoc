
import("stdfaust.lib");

// Approximation of a sawtooth wave using additive synthesis

sawtooth(f) = 2/ma.PI*sum(k, 8, (-1)^k * os.osc((k+1)*f)/(k+1));

process = sawtooth(55);

