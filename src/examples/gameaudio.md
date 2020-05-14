# gameaudio


## bubble

<!-- faust-run -->

declare name "bubble";
declare description "Production of a water drop bubble sound.";
declare license "MIT";
declare copyright "(c) 2017: Yann Orlarey, GRAME";

import("stdfaust.lib");


//---------------------------`bubble`--------------------------
// bubble(f0, trig) : produces a water drop bubble sound
//
// #### Usage
//
// ```
// bubble(f0, trig) : _
// ```
//
// Where:
//
// * ` f0 `: base frequency of bubble sound
// * `trig`: trigs the bubble sound on the rising front
//
// #### Example
//
// ```
// button("drop") : bubble(600) : _
// ```
//
// #### Reference:
//
// <http://www.cs.ubc.ca/~kvdoel/publications/tap05.pdf>
//------------------------------------------------------------

bubble(f0,trig) = os.osc(f) * (exp(-damp*time) : si.smooth(0.99))
	with {
		damp = 0.043*f0 + 0.0014*f0^(3/2);
		f = f0*(1+sigma*time);
		sigma = eta * damp;
		eta = 0.075;
		time = 0 : (select2(trig>trig'):+(1)) ~ _ : ba.samp2sec;
	};

process = button("drop") : bubble(hslider("v:bubble/freq", 600, 150, 2000, 1)) <: dm.freeverb_demo;

<!-- /faust-run -->


## rain

<!-- faust-run -->

//----------------------`rain`--------------------------
// A very simple rain simulator
//
// #### Usage
//
// ```
//  rain(d,l) : _,_
// ```
//
// Where:
//
// * `d`: is the density of the rain: between 0 and 1
// * `l`: is the level (volume) of the rain: between 0 and 1
//
//----------------------------------------------------------

import("stdfaust.lib");

rain(density,level) = no.multinoise(2) : par(i, 2, drop) : par(i, 2, *(level))
	with {
		drop = _ <: @(1), (abs < density) : *;
	};

process  = 	rain (
				hslider("v:rain/density", 300, 0, 1000, 1) / 1000,
				hslider("v:rain/volume", 0.5, 0, 1, 0.01)
			);

<!-- /faust-run -->


## wind

<!-- faust-run -->

//----------------------`wind`--------------------------
// A very simple wind simulator, based on a filtered white noise
//
// #### Usage
//
// ```
//  wind(f) : _
// ```
//
// Where:
//
// * `f`: is the force of the wind: between 0 and 1
//
//----------------------------------------------------------

import("stdfaust.lib");

wind(force) = no.multinoise(2) : par(i, 2, ve.moog_vcf_2bn(force,freq)) : par(i, 2, *(force))
	with {
		freq = (force*87)+1 : ba.pianokey2hz;
	};

process = wind ( hslider("v:wind/force",0.66,0,1,0.01) : si.smooth (0.997) );

<!-- /faust-run -->

