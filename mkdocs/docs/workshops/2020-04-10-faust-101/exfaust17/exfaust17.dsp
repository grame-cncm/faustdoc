
monoecho(d,f) = *(g) : + ~  (@(d):*(f)) 
    with {
        l = 0.95;
        g = 1 - max(0, f-l)/(1-l);
    };

stereoecho(d,f) = monoecho(d,f),monoecho(d,f);

stereoecho_demo = stereoecho(44100/4, hslider("feedback", 0, 0, 1, 0.01));

process = stereoecho_demo; 

