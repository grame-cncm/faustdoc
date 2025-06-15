
import("stdfaust.lib");
tableSize = 1 << 16;
sineWave(tablesize) = float(ba.time)*(2.0*ma.PI)/float(tablesize) : sin;
sineOsc(f) = tableSize,sineWave(tableSize),int(os.phasor(tableSize,f)) : rdtable;
f = hslider("freq",440,50,2000,0.01);
process = sineOsc(f);

