
import("stdfaust.lib");

process = os.osc(440 /*to replace*/) * hslider("gain", 0.1, 0, 1, 0.01);

