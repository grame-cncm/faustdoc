
import("stdfaust.lib");
ctFreq = 500;
q = 5;
gain = 1;
process = fi.resonlp(ctFreq,q,gain,no.noise);

