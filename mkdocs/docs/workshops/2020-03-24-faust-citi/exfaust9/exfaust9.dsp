
import("stdfaust.lib");

//----------------------------------------------------------------------
// partial(f,n);
// f = fréquence en Hz
// n = numero du partiel en partant de 1
partial(n,f) = os.osc(f*n) * hslider("partial %n", 0.25, 0, 1, 0.01);

process 	= sum(i, 4, partial(i+1,hslider("freq", 440, 20, 8000, 0.001)));

