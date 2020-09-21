
monoamp = _, hslider("volume", 0.1, 0, 1, 0.01) : *;
stereoamp = monoamp, monoamp;

process = stereoamp;

