
declare options "[midi:on][nvoices:12]";
import("stdfaust.lib");
freq = hslider("freq",200,50,1000,0.01);
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate");
process = os.sawtooth(freq)*gain*gate;

