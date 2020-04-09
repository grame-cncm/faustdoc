# phasing


## flanger

<!-- faust-run -->

declare name "flanger";
declare version "0.0";
declare author "JOS, revised by RM";
declare description "Flanger effect application.";

import("stdfaust.lib");

process = dm.flanger_demo;

<!-- /faust-run -->


## phaser

<!-- faust-run -->

declare name "phaser";
declare version "0.0";
declare author "JOS, revised by RM";
declare description "Phaser demo application.";

import("stdfaust.lib");

process = dm.phaser2_demo;

<!-- /faust-run -->


## phaserFlangerLab

<!-- faust-run -->

declare name "phaserFlangerLab";

import("stdfaust.lib");

//process = ol.sawtooth_demo <: 
//  el.flanger_demo : el.phaser2_demo :> fl.spectral_level_demo <: _,_;

fx_stack = 
 vgroup("[1]", dm.sawtooth_demo) <:
 vgroup("[2]", dm.flanger_demo) : 
 vgroup("[3]", dm.phaser2_demo);

level_viewer(x,y) = attach(x, vgroup("[4]", dm.spectral_level_demo(x+y))),y;

process = fx_stack : level_viewer;

<!-- /faust-run -->

