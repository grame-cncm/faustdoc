
monoamp = *(vslider("volume[style:knob]", 0.1, 0, 1, 0.01));

stereoamp = monoamp,monoamp;

process = stereoamp;

