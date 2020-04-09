
monoamp = _, hslider("volume[type:knob]", 0.1, 0, 1, 0.01) : *;
stereoamp = hgroup("amp", monoamp,monoamp);

process = stereoamp;

