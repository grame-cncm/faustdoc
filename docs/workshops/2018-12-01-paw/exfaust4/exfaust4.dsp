
declare options "[midi:on][nvoices:4]";
import("stdfaust.lib");
decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _;
osc(f) = phase(f) * 2 * ma.PI : sin;
timbre(f) = osc(f)*0.5 + osc(f*2)*0.25 + osc(f*3)*0.125;
process = timbre(hslider("freq", 440, 20, 10000, 1)) 
        * hslider("gain", 0.5, 0, 1, 0.01) 
        * (button("gate") : en.adsr(0.1,0.1,0.98,0.1));

