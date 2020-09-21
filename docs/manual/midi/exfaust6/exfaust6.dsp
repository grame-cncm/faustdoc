
import("stdfaust.lib");
inst = nentry("Instrument[midi:pgm]",0,0,3,1) : int;
process = (os.sawtooth(400),os.osc(400),os.sawtooth(600),os.osc(600)) : ba.selectn(4,inst);

