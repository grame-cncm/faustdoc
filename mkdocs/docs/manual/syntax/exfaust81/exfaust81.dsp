
import("stdfaust.lib");
sineWave(tablesize) = float(ba.time)*(2.0*ma.PI)/float(tablesize) : sin;
tableSize = 1 << 16;
triangleOsc(f) = tableSize,sineWave(tableSize),int(os.phasor(tableSize,f)) : rdtable;
f = hslider("freq",440,50,2000,0.01);
process = triangleOsc(f);

