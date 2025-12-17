
import("stdfaust.lib");

// freq, res and gate definitions
freq = hslider("frequency[unit:Hz]", 440, 20, 2000, 1);
res  = hslider("resonance", 0.99, 0, 0.999, 0.001);
gate = button("trigger");

// String model
string(frequency,resonance,trigger) = trigger : ba.impulsify : fi.fb_fcomb(1024,del,1,resonance)
with {
	del = ma.SR/frequency;
};

process = string(freq,res,gate);

