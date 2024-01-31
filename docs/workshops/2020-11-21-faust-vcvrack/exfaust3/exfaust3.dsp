
declare options "[midi:on][nvoices:4]";
import("stdfaust.lib");

freq = hslider("freq", 200, 50, 5000, 0.01);
gain = hslider("gain", 0.5, 0, 1, 0.01);
gate = button("gate");
check = checkbox("check");

// DSP processor
process = os.osc(freq) * gain * gate, os.sawtooth(freq) * gain * check;

