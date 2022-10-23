
import("stdfaust.lib");
process = organ, organ
with {
    decimalpart(x) = x-int(x);
    phasor(f) = f/ma.SR : (+ : decimalpart) ~ _;
    osc(f) = sin(2 * ma.PI * phasor(f));
    freq = nentry("freq", 100, 100, 3000, 0.01);
    gate = button("gate");
    gain = nentry("gain", 0.5, 0, 1, 0.01);
    organ = gate * (osc(freq) * gain + osc(2 * freq) * gain);
};

