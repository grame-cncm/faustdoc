
bounce(d,f) = @(d) : *(f);
monoecho(d,f) = +~bounce(d,f);
stereoecho(d,f) = monoecho(d,f), monoecho(d,f);

process = stereoecho(44100/4, hslider("feedback", 0, 0, 1, 0.01)); 


