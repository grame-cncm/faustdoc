
import("stdfaust.lib");
nBands = 8;
filterBank(N) = hgroup("Filter Bank",seq(i,N,oneBand(i)))
with {
	oneBand(j) = vgroup("[%j]Band %a",fi.peak_eq(l,f,b))
	with {
		a = j+1; // just so that band numbers don't start at 0
		l = vslider("[2]Level[unit:db]",0,-70,12,0.01) : si.smoo;
		f = nentry("[1]Freq",(80+(1000*8/N*(j+1)-80)),20,20000,0.01) : si.smoo;
		b = f/hslider("[0]Q[style:knob]",1,1,50,0.01) : si.smoo;
	};
};
process = filterBank(nBands);

