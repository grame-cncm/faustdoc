
import("stdfaust.lib");
process = par(i,3,os.osc(hslider("Freq%i", 200+i*400, 200, 2000, 1)));

