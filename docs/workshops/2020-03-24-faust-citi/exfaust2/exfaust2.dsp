
import("stdfaust.lib");

process = os.osc(440 /*a remplacer*/) * hslider("gain", 0.1, 0, 1, 0.01);

