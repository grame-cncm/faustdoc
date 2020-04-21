
import("stdfaust.lib");
ctFreq = 500;
q = 5;
gain = 1;
process = no.noise : fi.resonlp(ctFreq,q,gain);

