
import("stdfaust.lib");
freq = hslider("freq",440,50,3000,0.01);
gain = hslider("gain",1,0,1,0.01);
gate = button("gate");
envelope = gain*gate : si.smoo;
process = (os.osc(freq) + os.osc(freq*2) + os.osc(freq*3))/(3)*envelope;

