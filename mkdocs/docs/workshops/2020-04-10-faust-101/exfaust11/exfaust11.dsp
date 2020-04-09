
mute = *(1-checkbox("mute"));

monoamp = *(vslider("volume[style:knob]", 0.1, 0, 1, 0.01)) : mute;

stereoamp = monoamp,monoamp;

process = stereoamp;

