
mute = *(1-checkbox("mute"));
monoamp = *(vslider("volume[style:knob]", 0.1, 0, 1, 0.01)) : mute;
stereoamp = hgroup("Marshall", monoamp, monoamp);

process = stereoamp;

