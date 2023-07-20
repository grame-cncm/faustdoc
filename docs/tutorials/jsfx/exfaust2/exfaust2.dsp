
declare options "[nvoices:4]";
import("stdfaust.lib");

freq = hslider("freq", 0, 0, 10000, 0.1) : si.smoo;
gain = hslider("gain", 0, 0, 1, 0.01) : si.smoo;
gate = checkbox("gate");
env = gate : en.asr(0.1, 0.5, 0.5);

process = os.osc(freq) * env * gain * 0.1;

