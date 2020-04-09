
mute = *(1-checkbox("mute"));

monoamp(c) = *(vslider("volume %c[style:knob]", 0.1, 0, 1, 0.01)) : mute;

multiamp(N) = hgroup("Marshall", par(i, N, monoamp(i)));

process = multiamp(2); // try multiamp(4)

