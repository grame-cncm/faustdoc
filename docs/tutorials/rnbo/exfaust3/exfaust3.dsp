
import("stdfaust.lib");

process = vgroup("Organ", voice(freq) * gain * en.adsr(0.1, 0.1, 0.8, 0.3, button("gate"))) * master <: (_,_)
with {
master = hslider("master [midi:ctrl 7]", 0.5, 0, 1, 0.01);
    gain = hslider("gain", 0.5, 0, 1, 0.01);
    freq = hslider("freq", 500, 200, 3000, 0.1);
    voice(freq) = os.osc(freq) + os.osc(freq*2)*0.5 + os.osc(freq*3)*0.25;
};

effect = dm.freeverb_demo;

