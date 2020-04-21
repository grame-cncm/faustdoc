
declare options "[midi:on][nvoices:12]";
import("stdfaust.lib");
f = hslider("freq",300,50,2000,0.01);
bend = hslider("bend[midi:pitchwheel]",1,0,10,0.01) : si.polySmooth(gate,0.999,1);
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate");
freq = f*bend; 
envelope = en.adsr(0.01,0.01,0.8,0.1,gate)*gain;
process = os.sawtooth(freq)*envelope <: _,_;
effect = dm.zita_light;

