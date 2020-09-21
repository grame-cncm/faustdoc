
import("stdfaust.lib");
freq = hslider("key",60,36,96,1) : midikey2hz 
with {
    // quarter tone tuning
    midikey2hz(mk) = 440.0*pow(2.0, (mk-69.0)/48.0); 
}; 
gain = hslider("gain",0.5,0,1,0.01);
gate = button("gate");
process = os.sawtooth(freq)*gain*gate;

