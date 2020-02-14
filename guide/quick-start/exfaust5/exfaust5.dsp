
import("stdfaust.lib");
ctFreq = 500;
q = 5;
gain = 1;
filter = fi.resonlp(ctFreq,q,gain);
process = no.noise <: filter,filter;

