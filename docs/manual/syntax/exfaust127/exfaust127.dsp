
import("stdfaust.lib");

process = ["Wet": *(lfo(0.5, 0.9)) -> dm.freeverb_demo]
with {
    lfo(f,g) = 1+os.osc(f)*g;
};

