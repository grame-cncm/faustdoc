
import("stdfaust.lib");

// FM: Frequency modulation 2

FM(fc,fm,amp) = fm : os.osc : *(amp) : +(1) : *(fc) : os.osc;

process = FM( 
            hslider("freq carrier", 880, 40, 8000, 1),
            hslider("freq modulation", 200, 10, 1000, 1)*(2+envelop2)/3,
            hslider("amp modulation", 0, 0, 1, 0.01)*(0.5+envelop2)/1.5
            ) 
        : *(envelop1)
        <: dm.freeverb_demo;

envelop1 = button("gate") : upfront : en.ar(0.001, 1);
envelop2 = button("gate") : upfront : en.ar(0.5, 0.5);

upfront(x) = x>x';


