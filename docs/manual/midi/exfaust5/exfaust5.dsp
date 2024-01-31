
declare options "[midi:on]";
import("stdfaust.lib");
vol = hslider("volume[midi:chanpress]",0.5,0,1,0.01) : si.smoo;
process = os.sawtooth(440) * vol;

