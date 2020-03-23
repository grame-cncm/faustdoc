
import("stdfaust.lib");

// Virtual Analog square wave with less aliasing

process = os.squareN(3,hslider("freq", 220, 20, 8000, 1))*hslider("gain", 0.5, 0, 1, 0.01);

