
bounce = @(44100/4) : *(0.75);
monoecho = +~bounce;
stereoecho = monoecho, monoecho;

process = stereoecho; 


