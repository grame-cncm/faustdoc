
mute = *(1-checkbox("mute"));

monoamp(c) = *(vslider("volume %c[style:knob]", 0.1, 0, 1, 0.01)) : mute;

stereoamp = hgroup("Marshall",monoamp(0),monoamp(1));

process = stereoamp;

