
declare options "[midi:on]";
import("stdfaust.lib");
bend = ba.semi2ratio(hslider("frequency[midi:pitchwheel]",0,-2,2,0.01)) : si.smoo;
process = os.sawtooth(440*bend);

