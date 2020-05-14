# dynamic


## compressor

<!-- faust-run -->

declare name "compressor";
declare version "0.0";
declare author "JOS, revised by RM";
declare description "Compressor demo application";

import("stdfaust.lib");

process = dm.compressor_demo;

<!-- /faust-run -->


## distortion

<!-- faust-run -->

declare name "distortion";
declare version "0.0";
declare author "JOS, revised by RM";
declare description "Distortion demo application.";

import("stdfaust.lib");

process = dm.cubicnl_demo;

<!-- /faust-run -->


## gateCompressor

<!-- faust-run -->

declare name "gateCompressor";

import("stdfaust.lib");

process = 
// ol.sawtooth_demo <: 
//      el.gate_demo : ef.compressor_demo :> fi.spectral_level_demo <: _,_;
   vgroup("[1]", dm.sawtooth_demo) <:
   vgroup("[2]", dm.gate_demo) : 
   vgroup("[3]", dm.compressor_demo) :>
   vgroup("[4]", dm.spectral_level_demo) <:
    _,_;

<!-- /faust-run -->


## noiseGate

<!-- faust-run -->

declare name "noiseGate";
declare version "0.0";
declare author "JOS, revised by RM";
declare description "Gate demo application.";

import("stdfaust.lib");

process = dm.gate_demo;

<!-- /faust-run -->


## volume

<!-- faust-run -->

declare name 		"volume";
declare version 	"1.0";
declare author 		"Grame";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2006";

//-----------------------------------------------
// 			Volume control in dB
//-----------------------------------------------

import("stdfaust.lib");

gain		= vslider("[1]", 0, -70, +4, 0.1) : ba.db2linear : si.smoo;

process		= *(gain);

<!-- /faust-run -->

