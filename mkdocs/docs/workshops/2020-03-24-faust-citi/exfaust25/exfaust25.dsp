
import("stdfaust.lib");

// FM: Frequency moulation

FM(fc,fm,amp) = fm : os.osc : *(amp) : +(1) : *(fc) : os.osc;

process = FM( 
            hslider("freq carrier", 880, 40, 8000, 1),
            hslider("freq modulation", 200, 10, 1000, 1),
            hslider("amp modulation", 0, 0, 1, 0.01)
            ) 
        <: _,_;


