# delayEcho


## echo

<!-- faust-run -->

// WARNING: This a "legacy example based on a deprecated library". Check misceffects.lib
// for more accurate examples of echo functions

declare name 		"echo";
declare version 	"1.0";
declare author 		"Grame";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2006";
//-----------------------------------------------
// 				A Simple Echo
//-----------------------------------------------

import("stdfaust.lib");

process = vgroup("echo-simple", ef.echo1s);

<!-- /faust-run -->


## quadEcho

<!-- faust-run -->

// WARNING: This a "legacy example based on a deprecated library". Check misceffects.lib
// for more accurate examples of echo functions

declare name 		"quadEcho";
declare version 	"1.0";
declare author 		"Grame";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2007";

//-----------------------------------------------
// 				A 1 second quadriphonic Echo
//-----------------------------------------------

import("stdfaust.lib");

process = vgroup("stereo echo", multi(ef.echo1s, 4))
	with { 
		multi(f,1) = f;
		multi(f,n) = f,multi(f,n-1);
	};							
	

<!-- /faust-run -->


## smoothDelay

<!-- faust-run -->

declare name 	"smoothDelay";
declare author 	"Yann Orlarey";
declare copyright "Grame";
declare version "1.0";
declare license "STK-4.3";

//--------------------------process----------------------------
//
// 	A stereo smooth delay with a feedback control
//  
//	This example shows how to use sdelay, a delay that doesn't
//  click and doesn't transpose when the delay time is changed
//-------------------------------------------------------------

import("stdfaust.lib");

process = par(i, 2, voice)
	with { 
		voice 	= (+ : de.sdelay(N, interp, dtime)) ~ *(fback);
		N 		= int(2^19); 
		interp 	= hslider("interpolation[unit:ms][style:knob]",10,1,100,0.1)*ma.SR/1000.0; 
		dtime	= hslider("delay[unit:ms][style:knob]", 0, 0, 5000, 0.1)*ma.SR/1000.0;
		fback 	= hslider("feedback[style:knob]",0,0,100,0.1)/100.0; 
	};



<!-- /faust-run -->


## stereoEcho

<!-- faust-run -->

// WARNING: This a "legacy example based on a deprecated library". Check misceffects.lib
// for more accurate examples of echo functions

declare name 		"stereoEcho";
declare version 	"1.0";
declare author 		"Grame";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2007";

//-----------------------------------------------
// 				A 1 second Stereo Echo
//-----------------------------------------------

import("stdfaust.lib");

process = vgroup("stereo echo", (ef.echo1s, ef.echo1s));

<!-- /faust-run -->


## tapiir

<!-- faust-run -->

declare name 		"tapiir";
declare version 	"1.0";
declare author 		"Grame";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2006";

//======================================================
//
// 					TAPIIR
//	  (from Maarten de Boer's Tapiir)
//
//======================================================

import("stdfaust.lib");

dsize = 524288;

// user interface
//---------------
tap(n) = vslider("tap %n", 0,0,1,0.1);
in(n) = vslider("input %n", 1,0,1,0.1);
gain = vslider("gain", 1,0,1,0.1);
del = vslider("delay (sec)", 0, 0, 5, 0.01) * ma.SR;

// mixer and matrix
//-----------------------------------------------------------
mixer(taps,lines) = par(i,taps,*(tap(i))), par(i,lines,*(in(i))) :> *(gain);

matrix(taps,lines) = (si.bus(lines+taps)
                        <: tgroup("",
                        par(i, taps, hgroup("Tap %i", mixer(taps,lines) : de.delay(dsize,del))))
                    ) ~ si.bus(taps);

// tapiir
//--------
tapiir(taps,lines) = vgroup("Tapiir",
                            si.bus(lines)
                            <: (matrix(taps,lines), si.bus(lines))
                            <: vgroup("outputs", par(i, lines, hgroup("output %i", mixer(taps,lines))))
                            );

process = tapiir(6,2);



<!-- /faust-run -->

