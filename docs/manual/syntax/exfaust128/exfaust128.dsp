
import("stdfaust.lib");
g = hslider("gain[hidden:1][acc: 0 0 -10 0 10]",0.5,0,1,0.01):si.smoo;
process = os.osc(500)*g;

