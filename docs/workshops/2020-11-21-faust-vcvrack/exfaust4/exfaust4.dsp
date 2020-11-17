
import("stdfaust.lib");

// control variables
master = hslider("master", 0.3, 0, 2, 0.01);    
pan = hslider("pan", 0.5, 0, 1, 0.01);    

freq = nentry("freq [CV:1]", 440, 20, 20000, 1);    
gain = nentry("gain [CV:3]", 0.3, 0, 10, 0.01);    
gate = button("gate [CV:2]");            

// relative amplitudes of the different partials
amp(1) = hslider("amp1", 1.0, 0, 3, 0.01);
amp(2) = hslider("amp2", 0.5, 0, 3, 0.01);
amp(3) = hslider("amp3", 0.25, 0, 3, 0.01);

// panner function
panner(pan, x) = x*sqrt(1-pan), x*sqrt(pan);

// additive synth: 3 sine oscillators with adsr envelop
partial(i) = amp(i+1)*os.osc((i+1)*freq);

process = sum(i, 3, partial(i))
* (gate : vgroup("1-adsr", en.adsr(0.05, 0.1, 0.1, 0.1)))
* gain : vgroup("2-master", *(master) : panner(pan));

