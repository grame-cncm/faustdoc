
//################################### crazyGuiro.dsp #####################################
// A simple smart phone "Guiro" where the touch screen is used to drive the instrument and
// select its pitch and where the x and y axis of the accelerometer control the
// resonance properties of the instrument.
//
// ## SmartKeyboard Use Strategy
//
// Since the sounds generated by this synth are very short, the strategy here is to take
// advantage of the polyphony capabilities of the iOSKeyboard architecture by creating
// a new voice every time a new key is pressed. Since the SmartKeyboard interface has a
// large number of keys here (128), lots of sounds are generated when sliding a
// finger across the keyboard. Also, it's interesting to notice that the freq parameter
// is not used here. Instead keyboard and key are used which allows us to easily
// make custom mappings.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with faust2smartkeyb. For best results,
// we recommend to use the following parameters to compile it:
//
// 
// faust2smartkeyb [-ios/-android] crazyGuiro.dsp
// 
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

import("stdfaust.lib");


//========================= Smart Keyboard Configuration =================================
// 8 keyboards, each has 16 keys, none of them display key names.
//========================================================================================

declare interface "SmartKeyboard{
	'Number of Keyboards':'8',
	'Keyboard 0 - Number of Keys':'16',
	'Keyboard 1 - Number of Keys':'16',
	'Keyboard 2 - Number of Keys':'16',
	'Keyboard 3 - Number of Keys':'16',
	'Keyboard 4 - Number of Keys':'16',
	'Keyboard 5 - Number of Keys':'16',
	'Keyboard 6 - Number of Keys':'16',
	'Keyboard 7 - Number of Keys':'16',
	'Keyboard 0 - Piano Keyboard':'0',
	'Keyboard 1 - Piano Keyboard':'0',
	'Keyboard 2 - Piano Keyboard':'0',
	'Keyboard 3 - Piano Keyboard':'0',
	'Keyboard 4 - Piano Keyboard':'0',
	'Keyboard 5 - Piano Keyboard':'0',
	'Keyboard 6 - Piano Keyboard':'0',
	'Keyboard 7 - Piano Keyboard':'0'
}";


//================================ Instrument Parameters =================================
// Creates the connection between the synth and the mobile device
//========================================================================================

// the current keyboard
keyboard = hslider("keyboard",0,0,2,1);
// the current key of the current keyboard
key = hslider("key",0,0,2,1);
// the wet factor of the reverb
wet = hslider("wet[acc: 0 0 -10 0 10]",0,0,1,0.01);
// the resonance factor of the reverb
res = hslider("res[acc: 1 0 -10 0 10]",0.5,0,1,0.01);
// smart keyboard gate parameter
gate = button("gate");


//=================================== Parameters Mapping =================================
//========================================================================================

// the resonance frequency of each click of the Guiro changes in function of
// the selected keyboard and key on it
minKey = 50; // min key of lowest keyboard
keySkipKeyboard = 8; // key skip per keyboard
drumResFreq = (key+minKey)+(keyboard*keySkipKeyboard) : ba.midikey2hz;
reverbWet = wet : si.smoo;
reverbRes = wet : si.smoo;

// filter q
q = 8;

//============================================ DSP =======================================
//========================================================================================

reverb(wet,res)  =  _ <: *(1-wet),(*(wet) : re.mono_freeverb(res, 0.5, 0.5, 0)) :> _;

process = sy.popFilterDrum(drumResFreq,q,gate) : reverb(wet,res) <: _,_;

