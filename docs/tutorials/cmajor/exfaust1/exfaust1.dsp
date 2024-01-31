
declare options "[midi:on][nvoices:8]";
import("stdfaust.lib");
process = organ <: _,_
with {
    decimalpart(x) = x-int(x);
    phasor(f) = f/ma.SR : (+ : decimalpart) ~ _;
    osc(f) = sin(2 * ma.PI * phasor(f));
    freq = nentry("freq", 100, 100, 3000, 0.01);
    gate = button("gate");
    gain = nentry("gain", 0.5, 0, 1, 0.01);
    organ = en.adsr(0.1, 0.1, 0.7, 0.25, gate) * (osc(freq) * gain + osc(2*freq)*0.5 * gain);
};


