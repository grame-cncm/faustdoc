
import("stdfaust.lib");

process = testsource <: _, RMS(n).sliding, RMS(n).fixpoint, RMS(n).block, RMS(n).overlap(4)
    with {
        n = 10000;
        testsource = os.osc(40) * lfo(1) * hslider("level", 1, 0, 1, 0.01);
        lfo(f) = os.osc(f)/2+0.5;
    };

RMS(n) = environment {

	// The 4 implementations to test
	sliding    = horms(( _ <: _, @(n) : - : +~_ ));
	fixpoint   = horms(( float2fix(16) : _ <: _, @(n) : -: +~_ : fix2float(16) ));
	block      = horms(( + ~ *(phase != 0) : capture(phase == (n-1)) ));
	overlap(c) = horms(( + ~ *(phase%w != 0) <: par(i, c, capture( phase == (w*(i+1) - 1) )) :> _ with { w = n/c; } ));

	// high order rms with summation function as parameter
	horms(summation) = S:M:R with {
		S = ^(2);
		M = summation : /(n);
		R = sqrt;
	};
	
	// helpers
	float2fix(p) = *(2^p) : int;
	fix2float(p) = float : /(2^p);

	phase = 1 : (+,n:%)~_;
	capture(b) = select2(b)~_;

};

