
import("stdfaust.lib");
freq = 440;
process = (+(freq/ma.SR) ~ ma.frac);

