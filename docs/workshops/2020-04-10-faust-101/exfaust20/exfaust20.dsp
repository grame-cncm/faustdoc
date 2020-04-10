
bounce(d,f) = @(d) : *(f);
monoecho(d,f) = +~bounce(d,f);
stereoecho(d,f) = monoecho(d,f),monoecho(d,f);

process = stereoecho(44100/4,0.75); 

