
import("stdfaust.lib");

declare options "[midi:on]";

vol = hslider("volume [unit:dB] [midi: ctrl 7]", 0, -96, 0, 0.1) : ba.db2linear : si.smoo;
freq1 = hslider("freq1 [unit:Hz][midi: ctrl 1]", 1000, 20, 3000, 0.1);
freq2 = hslider("freq2 [unit:Hz][midi: ctrl 2]", 200, 20, 3000, 0.1);

process = vgroup("Oscillator", os.osc(freq1) * vol, os.osc(freq2) * vol);

