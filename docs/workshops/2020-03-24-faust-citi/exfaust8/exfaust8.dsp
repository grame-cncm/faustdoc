
import("stdfaust.lib");

// A frequency aliasing phenomenon if one goes beyond SR/2

process = os.osc(hslider("freq", 440, 20, 20000, 1)) * hslider("gain", 0.1, 0, 1, 0.01);


