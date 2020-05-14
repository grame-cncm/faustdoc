# smartKeyboard


## acGuitar

<!-- faust-run -->

//############################### acGuitar.dsp #################################
// Faust instrument specifically designed for `faust2smartkeyb` where 6 virtual
// nylon strings can be strummed and plucked using a dedicated keyboard. The
// extra "strumming keyboard" could be easily replaced by an external strumming
// interface while the touch screen could keep being used to change the pitch
// of the strings.
//
// ## `SmartKeyboard` Use Strategy
//
// The first 6 keyboards implement each individual string of the instrument. A
// seventh keybaord is used a strumming/plucking interface. As mentionned
// previously, it could be easily replaced by an external interface.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets.
// However it was specifically designed to be used with `faust2smartkeyb`. For
// best results, we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect reverb.dsp acGuitar.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Aug. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//##############################################################################

declare interface "SmartKeyboard{
	'Number of Keyboards':'7',
	'Max Keyboard Polyphony':'0',
	'Rounding Mode':'2',
	'Keyboard 0 - Number of Keys':'14',
  'Keyboard 1 - Number of Keys':'14',
	'Keyboard 2 - Number of Keys':'14',
	'Keyboard 3 - Number of Keys':'14',
	'Keyboard 4 - Number of Keys':'14',
	'Keyboard 5 - Number of Keys':'14',
	'Keyboard 6 - Number of Keys':'6',
	'Keyboard 0 - Lowest Key':'52',
	'Keyboard 1 - Lowest Key':'57',
	'Keyboard 2 - Lowest Key':'62',
	'Keyboard 3 - Lowest Key':'67',
	'Keyboard 4 - Lowest Key':'71',
	'Keyboard 5 - Lowest Key':'76',
	'Keyboard 0 - Send Keyboard Freq':'1',
	'Keyboard 1 - Send Keyboard Freq':'1',
	'Keyboard 2 - Send Keyboard Freq':'1',
	'Keyboard 3 - Send Keyboard Freq':'1',
	'Keyboard 4 - Send Keyboard Freq':'1',
	'Keyboard 5 - Send Keyboard Freq':'1',
	'Keyboard 6 - Piano Keyboard':'0',
	'Keyboard 6 - Send Key Status':'1',
	'Keyboard 6 - Key 0 - Label':'S0',
	'Keyboard 6 - Key 1 - Label':'S1',
	'Keyboard 6 - Key 2 - Label':'S2',
	'Keyboard 6 - Key 3 - Label':'S3',
	'Keyboard 6 - Key 4 - Label':'S4',
	'Keyboard 6 - Key 5 - Label':'S5'
}";

import("stdfaust.lib");

// SMARTKEYBOARD PARAMS
kbfreq(0) = hslider("kb0freq",164.8,20,10000,0.01);
kbbend(0) = hslider("kb0bend",1,0,10,0.01);
kbfreq(1) = hslider("kb1freq",220,20,10000,0.01);
kbbend(1) = hslider("kb1bend",1,0,10,0.01);
kbfreq(2) = hslider("kb2freq",293.7,20,10000,0.01);
kbbend(2) = hslider("kb2bend",1,0,10,0.01);
kbfreq(3) = hslider("kb3freq",392,20,10000,0.01);
kbbend(3) = hslider("kb3bend",1,0,10,0.01);
kbfreq(4) = hslider("kb4freq",493.9,20,10000,0.01);
kbbend(4) = hslider("kb4bend",1,0,10,0.01);
kbfreq(5) = hslider("kb5freq",659.2,20,10000,0.01);
kbbend(5) = hslider("kb5bend",1,0,10,0.01);
kb6kstatus(0) = hslider("kb6k0status",0,0,1,1) <: ==(1) | ==(4) : int;
kb6kstatus(1) = hslider("kb6k1status",0,0,1,1) <: ==(1) | ==(4) : int;
kb6kstatus(2) = hslider("kb6k2status",0,0,1,1) <: ==(1) | ==(4) : int;
kb6kstatus(3) = hslider("kb6k3status",0,0,1,1) <: ==(1) | ==(4) : int;
kb6kstatus(4) = hslider("kb6k4status",0,0,1,1) <: ==(1) | ==(4) : int;
kb6kstatus(5) = hslider("kb6k5status",0,0,1,1) <: ==(1) | ==(4) : int;

// MODEL PARAMETERS
// strings length
sl(i) = kbfreq(i)*kbbend(i) : pm.f2l : si.smoo;
// pluck position is controlled by the x axis of the accel
pluckPosition =
	hslider("pluckPosition[acc: 1 0 -10 0 10]",0.5,0,1,0.01) : si.smoo;

// ASSEMBLING MODELS
// number of strings
nStrings = 6;
guitar = par(i,nStrings,
	kb6kstatus(i) : ba.impulsify : // using "raw" impulses to drive the models
	pm.nylonGuitarModel(sl(i),pluckPosition)) :> _;

process = guitar <: _,_;

<!-- /faust-run -->


## bells

<!-- faust-run -->

//################################ bells.dsp ###################################
// Faust instrument specifically designed for `faust2smartkeyb` where the
// physical models of 4 different bells can be played using screen pads. The
// models are taken from `physmodels.lib`.
//
// ## `SmartKeyboard` Use Strategy
//
// The `SmartKeyboard` interface is used to implement percussion pads where
// the X/Y position of fingers is retrieved to control the strike position on
// the bells.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets.
// However it was specifically designed to be used with `faust2smartkeyb`. For
// best results, we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect reverb.dsp bells.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Aug. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//##############################################################################

declare interface "SmartKeyboard{
	'Number of Keyboards':'2',
	'Max Keyboard Polyphony':'0',
	'Keyboard 0 - Number of Keys':'2',
  'Keyboard 1 - Number of Keys':'2',
	'Keyboard 0 - Send Freq':'0',
  'Keyboard 1 - Send Freq':'0',
	'Keyboard 0 - Piano Keyboard':'0',
  'Keyboard 1 - Piano Keyboard':'0',
	'Keyboard 0 - Send Key Status':'1',
	'Keyboard 1 - Send Key Status':'1',
	'Keyboard 0 - Send X':'1',
	'Keyboard 0 - Send Y':'1',
	'Keyboard 1 - Send X':'1',
	'Keyboard 1 - Send Y':'1',
	'Keyboard 0 - Key 0 - Label':'English Bell',
	'Keyboard 0 - Key 1 - Label':'French Bell',
	'Keyboard 1 - Key 0 - Label':'German Bell',
	'Keyboard 1 - Key 1 - Label':'Russian Bell'
}";

import("stdfaust.lib");

// SMARTKEYBOARD PARAMS
kb0k0status = hslider("kb0k0status",0,0,1,1) : min(1) : int;
kb0k1status = hslider("kb0k1status",0,0,1,1) : min(1) : int;
kb1k0status = hslider("kb1k0status",0,0,1,1) : min(1) : int;
kb1k1status = hslider("kb1k1status",0,0,1,1) : min(1) : int;
x = hslider("x",1,0,1,0.001);
y = hslider("y",1,0,1,0.001);

// MODEL PARAMETERS
strikeCutoff = 6500;
strikeSharpness = 0.5;
strikeGain = 1;
// synthesize 10 modes out of 50
nModes = 10;
// resonance duration is 30s
t60 = 30;
// number of excitation pos (retrieved from model)
nExPos = 7;
// computing excitation position from X and Y
exPos = min((x*2-1 : abs),(y*2-1 : abs))*(nExPos-1) : int;

// ASSEMBLING MODELS
bells =
	(kb0k0status : pm.strikeModel(10,strikeCutoff,strikeSharpness,strikeGain) : pm.englishBellModel(nModes,exPos,t60,1,3)) +
	(kb0k1status : pm.strikeModel(10,strikeCutoff,strikeSharpness,strikeGain) : pm.frenchBellModel(nModes,exPos,t60,1,3)) +
	(kb1k0status : pm.strikeModel(10,strikeCutoff,strikeSharpness,strikeGain) : pm.germanBellModel(nModes,exPos,t60,1,2.5)) +
	(kb1k1status : pm.strikeModel(10,strikeCutoff,strikeSharpness,strikeGain) : pm.russianBellModel(nModes,exPos,t60,1,3)) :> *(0.2);

process = bells <: _,_;

<!-- /faust-run -->


## bowed

<!-- faust-run -->

//##################################### bowed.dsp ########################################
// Faust instrument specifically designed for `faust2smartkeyb` implementing a
// non-polyphonic synthesizer (e.g., physical model; etc.) using a combination of
// different types of UI elements.
//
// ## `SmartKeyboard` Use Strategy
//
// 5 keyboards are declared (4 actual keyboards and 1 control surface). We want to
// disable the voice allocation system and we want to activate a voice on start-up
// so that all strings are constantly running so we set `Max Keyboard Polyphony` to
// 0. Since we don't want the first 4 keyboards to send the X and Y position of
// fingers on the screen, we set `Send X` and `Send Y` to 0 for all these keyboards.
// Similarly, we don't want the fifth keyboard to send pitch information to the synth
// so we set `Send Freq` to 0 for that keyboard. Finally, we deactivate piano keyboard
// mode for the fifth keyboard to make sure that color doesn't change when the key is
// touch and that note names are not displayed.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect reverb.dsp midiOnly.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

declare interface "SmartKeyboard{
	'Number of Keyboards':'5',
	'Max Keyboard Polyphony':'0',
	'Rounding Mode':'1',
	'Keyboard 0 - Number of Keys':'19',
	'Keyboard 1 - Number of Keys':'19',
	'Keyboard 2 - Number of Keys':'19',
	'Keyboard 3 - Number of Keys':'19',
	'Keyboard 4 - Number of Keys':'1',
	'Keyboard 4 - Send Freq':'0',
	'Keyboard 0 - Send X':'0',
	'Keyboard 1 - Send X':'0',
	'Keyboard 2 - Send X':'0',
	'Keyboard 3 - Send X':'0',
	'Keyboard 0 - Send Y':'0',
	'Keyboard 1 - Send Y':'0',
	'Keyboard 2 - Send Y':'0',
	'Keyboard 3 - Send Y':'0',
	'Keyboard 0 - Lowest Key':'55',
	'Keyboard 1 - Lowest Key':'62',
	'Keyboard 2 - Lowest Key':'69',
	'Keyboard 3 - Lowest Key':'76',
	'Keyboard 4 - Piano Keyboard':'0',
	'Keyboard 4 - Key 0 - Label':'Bow'
}";

import("stdfaust.lib");

// parameters
f = hslider("freq",400,50,2000,0.01);
bend = hslider("bend",1,0,10,0.01);
keyboard = hslider("keyboard",0,0,5,1) : int;
key = hslider("key",0,0,18,1) : int;
x = hslider("x",0.5,0,1,0.01) : si.smoo;
y = hslider("y",0,0,1,0.01) : si.smoo;

// mapping
freq = f*bend;
// dirty motion tracker
velocity = x-x' : abs : an.amp_follower_ar(0.1,1) : *(8000) : min(1);

// 4 "strings"
synthSet = par(i,4,synth(localFreq(i),velocity)) :> _
with{
	localFreq(i) = freq : ba.sAndH(keyboard == i) : si.smoo;
	synth(freq,velocity) = sy.fm((freq,freq + freq*modFreqRatio),index*velocity)*velocity
	with{
		index = 1000;
		modFreqRatio = y*0.3;
	};
};

process = synthSet <: _,_;
<!-- /faust-run -->


## brass

<!-- faust-run -->

//############################### brass.dsp ###################################
// Faust instrument specifically designed for `faust2smartkeyb` where a
// trumpet physical model is controlled using some of the built-in sensors of
// the device and the touchscreen. Some of these elements could be replaced by
// external controllers (e.g., breath/mouth piece controller).
//
// ## `SmartKeyboard` Use Strategy
//
// 1 keyboard is used to implement the pistons of the trumpet (3 keys) and the
// other allows to control the lips tension.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets.
// However it was specifically designed to be used with `faust2smartkeyb`. For
// best results, we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect reverb.dsp brass.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Aug. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//##############################################################################

declare interface "SmartKeyboard{
	'Number of Keyboards':'2',
	'Max Keyboard Polyphony':'0',
	'Keyboard 0 - Number of Keys':'1',
  'Keyboard 1 - Number of Keys':'3',
	'Keyboard 0 - Send Freq':'0',
  'Keyboard 1 - Send Freq':'0',
	'Keyboard 0 - Piano Keyboard':'0',
  'Keyboard 1 - Piano Keyboard':'0',
	'Keyboard 0 - Send Key X':'1',
	'Keyboard 1 - Send Key Status':'1',
	'Keyboard 0 - Static Mode':'1',
	'Keyboard 0 - Key 0 - Label':'Lips Tension',
	'Keyboard 1 - Key 0 - Label':'P1',
	'Keyboard 1 - Key 1 - Label':'P2',
	'Keyboard 1 - Key 2 - Label':'P3'
}";

import("stdfaust.lib");

// SMARTKEYBOARD PARAMS
kb0k0x = hslider("kb0k0x",0,0,1,1);
kb1k0status = hslider("kb1k0status",0,0,1,1) : min(1) : int;
kb1k1status = hslider("kb1k1status",0,0,1,1) : min(1) : int;
kb1k2status = hslider("kb1k2status",0,0,1,1) : min(1) : int;

// MODEL PARAMETERS
// pressure is controlled by accelerometer
pressure = hslider("pressure[acc: 1 1 -10 0 10]",0,0,1,0.01) : si.smoo;
breathGain = 0.005; breathCutoff = 2000;
vibratoFreq = 5; vibratoGain = 0;
//pitch when no pistons are pushed
basePitch = 48; // C4
// calculate pitch shift in function of piston combination
pitchShift =
  ((kb1k0status == 0) & (kb1k1status == 1) & (kb1k2status == 0))*(1) +
  ((kb1k0status == 1) & (kb1k1status == 0) & (kb1k2status == 0))*(2) +
  ((kb1k0status == 1) & (kb1k1status == 1) & (kb1k2status == 0))*(3) +
  ((kb1k0status == 0) & (kb1k1status == 1) & (kb1k2status == 1))*(4) +
  ((kb1k0status == 1) & (kb1k1status == 0) & (kb1k2status == 1))*(5) +
  ((kb1k0status == 1) & (kb1k1status == 1) & (kb1k2status == 1))*(6);
// tube length is calculated based on piston combination
tubeLength = basePitch-pitchShift : ba.midikey2hz : pm.f2l : si.smoo;
// lips tension is controlled using pad on screen
lipsTension = kb0k0x : si.smoo;
// default mute value
mute = 0.5;

// ASSEMBLING MODEL
model =
	pm.blower(pressure,breathGain,breathCutoff,vibratoFreq,vibratoGain) :
  pm.brassModel(tubeLength,lipsTension,mute);

process = model <: _,_;

<!-- /faust-run -->


## clarinet

<!-- faust-run -->

//############################### clarinet.dsp #################################
// Faust instrument specifically designed for `faust2smartkeyb` where a
// clarinet physical model is controlled by an interface implementing
// fingerings similar to that of a the real instrument. The pressure of the
// breath in the mouthpiece of the clarinet is controlled by blowing on the
// built-in microphone of the device.
//
// ## `SmartKeyboard` Use Strategy
//
// The device is meant to be held with 2 hands vertically in order to put all
// fingers on the screen at the same time. Key combinations determine the
// pitch of the instrument. A single voice is constantly ran.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets.
// However it was specifically designed to be used with `faust2smartkeyb`. For
// best results, we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] clarinet.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Aug. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//##############################################################################

declare interface "SmartKeyboard{
	'Number of Keyboards':'2',
	'Max Keyboard Polyphony':'0',
	'Keyboard 0 - Number of Keys':'4',
  'Keyboard 1 - Number of Keys':'5',
	'Keyboard 0 - Send Freq':'0',
  'Keyboard 1 - Send Freq':'0',
	'Keyboard 0 - Piano Keyboard':'0',
  'Keyboard 1 - Piano Keyboard':'0',
	'Keyboard 0 - Send Key Status':'1',
	'Keyboard 1 - Send Key Status':'1',
	'Keyboard 0 - Key 3 - Label':'O+',
	'Keyboard 1 - Key 4 - Label':'O-'
}";

import("stdfaust.lib");

// SMARTKEYBOARD PARAMS
kb0k0status = hslider("kb0k0status",0,0,1,1) : min(1) : int;
kb0k1status = hslider("kb0k1status",0,0,1,1) : min(1) : int;
kb0k2status = hslider("kb0k2status",0,0,1,1) : min(1) : int;
kb0k3status = hslider("kb0k3status",0,0,1,1) : min(1) : int;
kb1k0status = hslider("kb1k0status",0,0,1,1) : min(1) : int;
kb1k1status = hslider("kb1k1status",0,0,1,1) : min(1) : int;
kb1k2status = hslider("kb1k2status",0,0,1,1) : min(1) : int;
kb1k3status = hslider("kb1k3status",0,0,1,1) : min(1) : int;
kb1k4status = hslider("kb1k4status",0,0,1,1) : min(1) : int;

// MODEL PARAMETERS
reedStiffness = hslider("reedStiffness[acc: 1 1 -10 0 10]",0,0,1,0.01) : si.smoo;
basePitch = 73; // C#4
pitchShift = // calculate pitch shfit in function of "keys" combination
  ((kb0k0status == 0) & (kb0k1status == 1) & (kb0k2status == 0) &
		(kb1k0status == 0) & (kb1k1status == 0) & (kb1k2status == 0) &
		(kb1k3status == 0))*(-1) + // C
	((kb0k0status == 1) & (kb0k1status == 0) & (kb0k2status == 0) &
		(kb1k0status == 0) & (kb1k1status == 0) & (kb1k2status == 0) &
		(kb1k3status == 0))*(-2) + // B
	((kb0k0status == 1) & (kb0k1status == 0) & (kb0k2status == 1) &
		(kb1k0status == 0) & (kb1k1status == 0) & (kb1k2status == 0) &
		(kb1k3status == 0))*(-3) + // Bb
	((kb0k0status == 1) & (kb0k1status == 1) & (kb0k2status == 0) &
		(kb1k0status == 0) & (kb1k1status == 0) & (kb1k2status == 0) &
		(kb1k3status == 0))*(-4) + // A
	((kb0k0status == 1) & (kb0k1status == 1) & (kb0k2status == 0) &
		(kb1k0status == 1) & (kb1k1status == 0) & (kb1k2status == 0) &
		(kb1k3status == 0))*(-5) + // G#
	((kb0k0status == 1) & (kb0k1status == 1) & (kb0k2status == 1) &
		(kb1k0status == 0) & (kb1k1status == 0) & (kb1k2status == 0) &
		(kb1k3status == 0))*(-6) + // G
	((kb0k0status == 1) & (kb0k1status == 1) & (kb0k2status == 1) &
		(kb1k0status == 0) & (kb1k1status == 1) & (kb1k2status == 0) &
		(kb1k3status == 0))*(-7) + // F#
	((kb0k0status == 1) & (kb0k1status == 1) & (kb0k2status == 1) &
		(kb1k0status == 1) & (kb1k1status == 0) & (kb1k2status == 0) &
		(kb1k3status == 0))*(-8) + // F
	((kb0k0status == 1) & (kb0k1status == 1) & (kb0k2status == 1) &
		(kb1k0status == 1) & (kb1k1status == 1) & (kb1k2status == 0) &
		(kb1k3status == 0))*(-9) + // E
	((kb0k0status == 1) & (kb0k1status == 1) & (kb0k2status == 1) &
		(kb1k0status == 1) & (kb1k1status == 1) & (kb1k2status == 0) &
		(kb1k3status == 1))*(-10) + // Eb
	((kb0k0status == 1) & (kb0k1status == 1) & (kb0k2status == 1) &
		(kb1k0status == 1) & (kb1k1status == 1) & (kb1k2status == 1) &
		(kb1k3status == 0))*(-11) + // D
	((kb0k0status == 0) & (kb0k1status == 0) & (kb0k2status == 0) &
		(kb1k0status == 0) & (kb1k1status == 0) & (kb1k2status == 0) &
		(kb1k3status == 1))*(-12) + // C#
	((kb0k0status == 1) & (kb0k1status == 1) & (kb0k2status == 1) &
		(kb1k0status == 1) & (kb1k1status == 1) & (kb1k2status == 1) &
		(kb1k3status == 1))*(-13); // C
octaveShiftUp = +(kb0k3status : ba.impulsify)~_; // counting up
octaveShiftDown = +(kb1k4status : ba.impulsify)~_; // counting down
octaveShift = (octaveShiftUp-octaveShiftDown)*(12);
// tube length is just smoothed: could be improved
tubeLength = basePitch+pitchShift+octaveShift : ba.midikey2hz : pm.f2l : si.smoo;
bellOpening = 0.5;

// ASSEMBLING MODEL
model(pressure) = pm.clarinetModel(tubeLength,pressure,reedStiffness,bellOpening);

// pressure is estimated from mic signal
process = an.amp_follower_ud(0.02,0.02)*0.7 : model <: _,_;

<!-- /faust-run -->


## crazyGuiro

<!-- faust-run -->

//################################### crazyGuiro.dsp #####################################
// A simple smart phone "Guiro" where the touch screen is used to drive the instrument and
// select its pitch and where the x and y axis of the accelerometer control the
// resonance properties of the instrument.
//
// ## `SmartKeyboard` Use Strategy
//
// Since the sounds generated by this synth are very short, the strategy here is to take
// advantage of the polyphony capabilities of the iOSKeyboard architecture by creating
// a new voice every time a new key is pressed. Since the `SmartKeyboard` interface has a
// large number of keys here (128), lots of sounds are generated when sliding a
// finger across the keyboard. Also, it's interesting to notice that the `freq` parameter
// is not used here. Instead `keyboard` and `key` are used which allows us to easily
// make custom mappings.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] crazyGuiro.dsp
// ```
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

<!-- /faust-run -->


## drums

<!-- faust-run -->

//##################################### drums.dsp ########################################
// Faust instrument specifically designed for `faust2smartkeyb` where 3 drums can
// be controlled using pads. The X/Y postion of fingers is detected on each key
// and use to control the strike postion on the virtual membrane.
//
// ## `SmartKeyboard` Use Strategy
//
// The drum physical model used here is implemented to be generic so that its
// fundamental frequency can be changed for each voice. `SmartKeyboard` is used
// in polyphonic mode so each new strike on the interface corresponds to a new
// new voice.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect reverb.dsp drums.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

// Interface with 2 keyboards of 2 and 1 keys (3 pads)
// Static mode is used so that keys don't change color when touched
// Note labels are hidden
// Piano Keyboard mode is deactivated so all the keys look the same
declare interface "SmartKeyboard{
	'Number of Keyboards':'2',
	'Keyboard 0 - Number of Keys':'2',
	'Keyboard 1 - Number of Keys':'1',
	'Keyboard 0 - Static Mode':'1',
	'Keyboard 1 - Static Mode':'1',
	'Keyboard 0 - Send X':'1',
	'Keyboard 0 - Send Y':'1',
	'Keyboard 1 - Send X':'1',
	'Keyboard 1 - Send Y':'1',
	'Keyboard 0 - Piano Keyboard':'0',
	'Keyboard 1 - Piano Keyboard':'0',
	'Keyboard 0 - Key 0 - Label':'High',
	'Keyboard 0 - Key 1 - Label':'Mid',
	'Keyboard 1 - Key 0 - Label':'Low'
}";

import("stdfaust.lib");

// standard parameters
gate = button("gate");
x = hslider("x",1,0,1,0.001);
y = hslider("y",1,0,1,0.001);
keyboard = hslider("keyboard",0,0,1,1) : int;
key = hslider("key",0,0,1,1) : int;

drumModel = pm.djembe(rootFreq,exPos,strikeSharpness,gain,gate)
with{
	// frequency of the lowest drum
	bFreq = 60;
	// retrieving pad ID (0-2)
	padID = 2-(keyboard*2+key);
	// drum root freq is computed in function of pad number
	rootFreq = bFreq*(padID+1);
	// excitation position
	exPos = min((x*2-1 : abs),(y*2-1 : abs));
	strikeSharpness = 0.5;
	gain = 2;
};

process = drumModel <: _,_;

<!-- /faust-run -->


## dubDub

<!-- faust-run -->

//################################### dubDub.dsp #####################################
// A simple smartphone abstract instrument than can be controlled using the touch
// screen and the accelerometers of the device.
//
// ## `SmartKeyboard` Use Strategy
//
// The idea here is to use the `SmartKeyboard` interface as an X/Y control pad by just
// creating one keyboard with on key and by retrieving the X and Y position on that single
// key using the `x` and `y` standard parameters. Keyboard mode is deactivated so that
// the color of the pad doesn't change when it is pressed.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] dubDub.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

declare name "dubDub";

import("stdfaust.lib");

//========================= Smart Keyboard Configuration =================================
// (1 keyboards with 1 key configured as a pad.
//========================================================================================

declare interface "SmartKeyboard{
	'Number of Keyboards':'1',
	'Keyboard 0 - Number of Keys':'1',
	'Keyboard 0 - Piano Keyboard':'0',
	'Keyboard 0 - Static Mode':'1',
	'Keyboard 0 - Send X':'1',
	'Keyboard 0 - Send Y':'1'
}";


//================================ Instrument Parameters =================================
// Creates the connection between the synth and the mobile device
//========================================================================================

// SmartKeyboard X parameter
x = hslider("x",0,0,1,0.01);
// SmartKeyboard Y parameter
y = hslider("y",0,0,1,0.01);
// SmartKeyboard gate parameter
gate = button("gate");
// modulation frequency is controlled with the x axis of the accelerometer
modFreq = hslider("modFeq[acc: 0 0 -10 0 10]",9,0.5,18,0.01);
// general gain is controlled with the y axis of the accelerometer
gain = hslider("gain[acc: 1 0 -10 0 10]",0.5,0,1,0.01);


//=================================== Parameters Mapping =================================
//========================================================================================

// sawtooth frequency
minFreq = 80;
maxFreq = 500;
freq = x*(maxFreq-minFreq) + minFreq : si.polySmooth(gate,0.999,1);

// filter q
q = 8;

// filter cutoff frequency is modulate with a triangle wave
minFilterCutoff = 50;
maxFilterCutoff = 5000;
filterModFreq = modFreq : si.smoo;
filterCutoff = (1-os.lf_trianglepos(modFreq)*(1-y))*(maxFilterCutoff-minFilterCutoff)+minFilterCutoff;

// general gain of the synth
generalGain = gain : ba.lin2LogGain : si.smoo;


//============================================ DSP =======================================
//========================================================================================

process = sy.dubDub(freq,filterCutoff,q,gate)*generalGain <: _,_;

<!-- /faust-run -->


## elecGuitar

<!-- faust-run -->

//################################### elecGuitar.dsp #####################################
// Faust instruments specifically designed for `faust2smartkeyb` where an electric
// guitar physical model is controlled using an isomorphic keyboard. Rock on!
//
// ## `SmartKeyboard` Use Strategy
//
// we want to create an isomorphic keyboard where each keyboard is monophonic and
// implements a "string". Keyboards should be one fourth apart from each other
// (more or less like on a guitar). We want to be able to slide between keyboards
// (strum) to trigger a new note (voice) and we want new fingers on a keyboard to
// "steal" the pitch from the previous finger (sort of hammer on).
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect elecGuitarEffecr.dsp elecGuitar.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017:
// https://ccrma.stanford.edu/~rmichon
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

// Interface with 6 monophonic keyboards one fourth apart from each other
declare interface "SmartKeyboard{
	'Number of Keyboards':'6',
	'Max Keyboard Polyphony':'1',
	'Keyboard 0 - Number of Keys':'13',
	'Keyboard 1 - Number of Keys':'13',
	'Keyboard 2 - Number of Keys':'13',
	'Keyboard 3 - Number of Keys':'13',
	'Keyboard 4 - Number of Keys':'13',
	'Keyboard 5 - Number of Keys':'13',
	'Keyboard 0 - Lowest Key':'72',
	'Keyboard 1 - Lowest Key':'67',
	'Keyboard 2 - Lowest Key':'62',
	'Keyboard 3 - Lowest Key':'57',
	'Keyboard 4 - Lowest Key':'52',
	'Keyboard 5 - Lowest Key':'47',
	'Rounding Mode':'2'
}";

import("stdfaust.lib");

// standard parameters
f = hslider("freq",300,50,2000,0.01);
bend = hslider("bend[midi:pitchwheel]",1,0,10,0.01) : si.polySmooth(gate,0.999,1);
gain = hslider("gain",1,0,1,0.01);
s = hslider("sustain[midi:ctrl 64]",0,0,1,1); // for sustain pedal
t = button("gate");

// mapping params
gate = t+s : min(1);
freq = f*bend : max(60); // min freq is 60 Hz

stringLength = freq : pm.f2l;
pluckPosition = 0.8;
mute = gate : si.polySmooth(gate,0.999,1);

process = pm.elecGuitar(stringLength,pluckPosition,mute,gain,gate) <: _,_;

<!-- /faust-run -->


## fm

<!-- faust-run -->

//###################################### fm.dsp ##########################################
// A simple smart phone percussion abstract sound toy based on an FM synth.
//
// ## `SmartKeyboard` Use Strategy
//
// The idea here is to use the `SmartKeyboard` interface as an X/Y control pad by just
// creating one keyboard with on key and by retrieving the X and Y position on that single
// key using the `x` and `y` standard parameters. Keyboard mode is deactivated so that
// the color of the pad doesn't change when it is pressed.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] crazyGuiro.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

declare name "fm";

import("stdfaust.lib");

//========================= Smart Keyboard Configuration =================================
// (1 keyboards with 1 key configured as a pad.
//========================================================================================

declare interface "SmartKeyboard{
	'Number of Keyboards':'1',
	'Keyboard 0 - Number of Keys':'1',
	'Keyboard 0 - Piano Keyboard':'0',
	'Keyboard 0 - Static Mode':'1',
	'Keyboard 0 - Send X':'1',
	'Keyboard 0 - Send Y':'1'
}";

//================================ Instrument Parameters =================================
// Creates the connection between the synth and the mobile device
//========================================================================================

// SmartKeyboard X parameter
x = hslider("x",0,0,1,0.01);
// SmartKeyboard Y parameter
y = hslider("y",0,0,1,0.01);
// SmartKeyboard gate parameter
gate = button("gate") ;
// mode resonance duration is controlled with the x axis of the accelerometer
modFreqRatio = hslider("res[acc: 0 0 -10 0 10]",1,0,2,0.01) : si.smoo;

//=================================== Parameters Mapping =================================
//========================================================================================

// carrier frequency
minFreq = 80;
maxFreq = 500;
cFreq = x*(maxFreq-minFreq) + minFreq : si.polySmooth(gate,0.999,1);

// modulator frequency
modFreq = cFreq*modFreqRatio;

// modulation index
modIndex = y*1000 : si.smoo;

//============================================ DSP =======================================
//========================================================================================

// since the generated sound is pretty chaotic, there is no need for an envelope generator
fmSynth = sy.fm((cFreq,modFreq),(modIndex))*(gate : si.smoo)*0.5;

process = fmSynth;

<!-- /faust-run -->


## frog

<!-- faust-run -->

//################################### frog.dsp #####################################
// A simple smart phone abstract instrument than can be controlled using the touch
// screen and the accelerometers of the device.
//
// ## `SmartKeyboard` Use Strategy
//
// The idea here is to use the `SmartKeyboard` interface as an X/Y control pad by just
// creating one keyboard with on key and by retrieving the X and Y position on that single
// key using the `x` and `y` standard parameters. Keyboard mode is deactivated so that
// the color of the pad doesn't change when it is pressed.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] frog.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

declare name "frog";

import("stdfaust.lib");

//========================= Smart Keyboard Configuration =================================
// (1 keyboards with 1 key configured as a pad.
//========================================================================================

declare interface "SmartKeyboard{
	'Number of Keyboards':'1',
	'Keyboard 0 - Number of Keys':'1',
	'Keyboard 0 - Piano Keyboard':'0',
	'Keyboard 0 - Static Mode':'1',
	'Keyboard 0 - Send X':'1',
	'Keyboard 0 - Send Y':'1'
}";

//================================ Instrument Parameters =================================
// Creates the connection between the synth and the mobile device
//========================================================================================

// SmartKeyboard X parameter
x = hslider("x",0,0,1,0.01);
// SmartKeyboard Y parameter
y = hslider("y",0,0,1,0.01);
// SmartKeyboard gate parameter
gate = button("gate");
// the cutoff frequency of the filter is controlled with the x axis of the accelerometer
cutoff = hslider("cutoff[acc: 0 0 -10 0 10]",2500,50,5000,0.01);

//=================================== Parameters Mapping =================================
//========================================================================================

maxFreq = 100;
minFreq = 1;
freq = x*(maxFreq-minFreq) + minFreq : si.polySmooth(gate,0.999,1);

maxQ = 40;
minQ = 1;
q = (1-y)*(maxQ-minQ) + minQ : si.smoo;
filterCutoff = cutoff : si.smoo;

//============================================ DSP =======================================
//========================================================================================

process = sy.dubDub(freq,filterCutoff,q,gate) <: _,_;

<!-- /faust-run -->


## harp

<!-- faust-run -->

//######################################## harp.dsp ######################################
// A simple smart phone based harp (if we dare to call it like that). 
//
// ## `SmartKeyboard` Use Strategy
//
// Since the sounds generated by this synth are very short, the strategy here is to take
// advantage of the polyphony capabilities of the iOSKeyboard architecture by creating
// a new voice every time a new key is pressed. Since the `SmartKeyboard` interface has a 
// large number of keys here (128), lots of sounds are generated when sliding a 
// finger across the keyboard.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] harp.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

declare name "harp";

import("stdfaust.lib");

//========================= Smart Keyboard Configuration ================================= 
// (8 keyboards with 16 keys configured as a pitch matrix.
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
	'Keyboard 0 - Lowest Key':'40',
	'Keyboard 1 - Lowest Key':'45',
	'Keyboard 2 - Lowest Key':'50',
	'Keyboard 3 - Lowest Key':'55',
	'Keyboard 4 - Lowest Key':'60',
	'Keyboard 5 - Lowest Key':'65',
	'Keyboard 6 - Lowest Key':'70',
	'Keyboard 7 - Lowest Key':'75',
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

// the string resonance in second is controlled by the x axis of the accelerometer
res = hslider("res[acc: 0 0 -10 0 10]",2,0.1,4,0.01);
// Smart Keyboard frequency parameter
freq = hslider("freq",400,50,2000,0.01);
// Smart Keyboard gate parameter
gate = button("gate");

//=================================== Parameters Mapping =================================
//========================================================================================

stringFreq = freq;

//============================================ DSP =======================================
//========================================================================================

process = sy.combString(freq,res,gate);

<!-- /faust-run -->


## midiOnly

<!-- faust-run -->

//################################### midiOnly.dsp ######################################
// Faust instrument specifically designed for `faust2smartkeyb` implementing a MIDI
// controllable app where the mobile device's touch screen is used to control
// specific parameters of the synth continuously using two separate X/Y control surfaces.
//
// ## `SmartKeyboard` Use Strategy
//
// The `SmartKeyboard` configuration for this instrument consists in a single keyboard
// with two keys. Each key implements a control surface. `Piano Keyboard` mode is
// disabled so that key names are not displayed and that keys don't change color when
// touched. Finally, `Send Freq` is set to 0 so that new voices are not allocated by
// the touch screen and that the `freq` and `bend` parameters are not computed.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect reverb.dsp midiOnly.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

// Interface with 4 polyphnic keyboards of 13 keys with the same config
declare interface "SmartKeyboard{
	'Number of Keyboards':'1',
	'Keyboard 0 - Number of Keys':'2',
	'Keyboard 0 - Send Freq':'0',
	'Keyboard 0 - Piano Keyboard':'0',
	'Keyboard 0 - Static Mode':'1',
	'Keyboard 0 - Send Key X':'1',
	'Keyboard 0 - Key 0 - Label':'Mod Index',
	'Keyboard 0 - Key 1 - Label':'Mod Freq'
}";

import("stdfaust.lib");

f = hslider("freq",300,50,2000,0.01);
bend = ba.semi2ratio(hslider("bend[midi:pitchwheel]",0,-2,2,0.001)) : si.polySmooth(gate,0.999,1);
gain = hslider("gain",1,0,1,0.01);
key = hslider("key",0,0,1,1) : int;
kb0k0x = hslider("kb0k0x[midi:ctrl 1]",0.5,0,1,0.01) : si.smoo;
kb0k1x = hslider("kb0k1x[midi:ctrl 1]",0.5,0,1,0.01) : si.smoo;
s = hslider("sustain[midi:ctrl 64]",0,0,1,1);
t = button("gate");

// fomating parameters
gate = t+s : min(1);
freq = f*bend;
index = kb0k0x*1000;
modFreqRatio = kb0k1x;

envelope = gain*gate : si.smoo;

process = sy.fm((freq,freq + freq*modFreqRatio),index*envelope)*envelope <: _,_;

<!-- /faust-run -->


## multiSynth

<!-- faust-run -->

//################################### multiSynth.dsp ######################################
// Faust instrument specifically designed for `faust2smartkeyb` where 4 keyboards
// are used to control 4 independent synths.
//
// ## `SmartKeyboard` Use Strategy
//
// The `SmartKeyboard` configuration is relatively simple for this example and
// only consists in four polyphonic keyboards in parallel. The `keyboard` standard
// parameter is used to activate specific elements of the synthesizer.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect reverb.dsp multiSynth.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

// Interface with 4 polyphnic keyboards of 13 keys with the same config
declare interface "SmartKeyboard{
	'Number of Keyboards':'4',
	'Rounding Mode':'2',
	'Inter-Keyboard Slide':'0',
	'Keyboard 0 - Number of Keys':'13',
	'Keyboard 1 - Number of Keys':'13',
	'Keyboard 2 - Number of Keys':'13',
	'Keyboard 3 - Number of Keys':'13',
	'Keyboard 0 - Lowest Key':'60',
	'Keyboard 1 - Lowest Key':'60',
	'Keyboard 2 - Lowest Key':'60',
	'Keyboard 3 - Lowest Key':'60',
	'Keyboard 0 - Send Y':'1',
	'Keyboard 1 - Send Y':'1',
	'Keyboard 2 - Send Y':'1',
	'Keyboard 3 - Send Y':'1'
}";

import("stdfaust.lib");

// standard parameters
f = hslider("freq",300,50,2000,0.01);
bend = ba.semi2ratio(hslider("bend[midi:pitchwheel]",0,-2,2,0.001)) : si.polySmooth(gate,0.999,1);
gain = hslider("gain",1,0,1,0.01);
s = hslider("sustain[midi:ctrl 64]",0,0,1,1); // for sustain pedal
t = button("gate");
y = hslider("y[midi:ctrl 1]",1,0,1,0.001) : si.smoo;
keyboard = hslider("keyboard",0,0,3,1) : int;

// fomating parameters
gate = t+s : min(1);
freq = f*bend;
cutoff = y*4000+50;

// oscillators
oscilators(0) = os.sawtooth(freq);
oscilators(1) = os.triangle(freq);
oscilators(2) = os.square(freq);
oscilators(3) = os.osc(freq);

// oscs are selected in function of the current keyboard
synths = par(i,4,select2(keyboard == i,0,oscilators(i))) :> fi.lowpass(3,cutoff) : *(envelope)
with{
	envelope = gate*gain : si.smoo;
};

process = synths <: _,_;

<!-- /faust-run -->


## toy

<!-- faust-run -->

//##################################### toy.dsp #######################################
// Faust sound toy specifically designed for `faust2smartkeyb` where a funny
// synth can be controlled using several fingers on the screen and the built-in
// accelerometer.
//
// ## `SmartKeyboard` Use Strategy
//
// We just want a blank screen where the position of the different fingers on
// the screen can be tracked and retrieved in the Faust object. For that, we
// create one keyboard with one key, that should fill the screen. We ask the
// interface to not compute the `freq` and `bend` parameters to save
// computation by setting `'Keyboard 0 - Send Freq':'0'`. We don't want the
// color of the key to change when it is touched so we deactivate the
// `Piano Keyboard` mode. Fingers should be numbered to be able to use the
// numbered `x` and `y` parameters (`x0`, `y0`, `x1`, etc.), so `Count Fingers`
// is enabled. Finally, by setting `Max Keyboard Polyphony` to 0, we deactivate
// the voice allocation system and we automatically start a voice when the app
// is launched. This means that fingers are no longer associated to specific voices.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] toy.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017:
// https://ccrma.stanford.edu/~rmichon
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

// X/Y interface: one keyboard with one key
// freq and bend are not computed
// fingers are counted
// voice is launched on startup
declare interface "SmartKeyboard{
	'Number of Keyboards':'1',
	'Max Keyboard Polyphony':'0',
	'Keyboard 0 - Number of Keys':'1',
	'Keyboard 0 - Send Freq':'0',
	'Keyboard 0 - Static Mode':'1',
	'Keyboard 0 - Piano Keyboard':'0',
	'Keyboard 0 - Send Numbered X':'1',
	'Keyboard 0 - Send Numbered Y':'1'
}";

import("stdfaust.lib");

// parameters
x0 = hslider("x0",0.5,0,1,0.01) : si.smoo;
y0 = hslider("y0",0.5,0,1,0.01) : si.smoo;
y1 = hslider("y1",0,0,1,0.01) : si.smoo;
q = hslider("q[acc: 0 0 -10 0 10]",30,10,50,0.01) : si.smoo;
del = hslider("del[acc: 0 0 -10 0 10]",0.5,0.01,1,0.01) : si.smoo;
fb = hslider("fb[acc: 1 0 -10 0 10]",0.5,0,1,0.01) : si.smoo;

// mapping
impFreq = 2 + x0*20;
resFreq = y0*3000+300;

// simple echo effect
echo = +~(de.delay(65536,del*ma.SR)*fb);

// putting it together
process = os.lf_imptrain(impFreq) : fi.resonlp(resFreq,q,1) : echo : ef.cubicnl(y1,0)*0.95 <: _,_;

<!-- /faust-run -->


## trumpet

<!-- faust-run -->

//################################### trumpet.dsp #####################################
// A simple trumpet app... (for large screens).
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect reverb.dsp trumpet.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

import("stdfaust.lib");

declare interface "SmartKeyboard{
	'Number of Keyboards':'5',
	'Max Keyboard Polyphony':'1',
	'Mono Mode':'1',
	'Keyboard 0 - Number of Keys':'13',
	'Keyboard 1 - Number of Keys':'13',
	'Keyboard 2 - Number of Keys':'13',
	'Keyboard 3 - Number of Keys':'13',
	'Keyboard 4 - Number of Keys':'13',
	'Keyboard 0 - Lowest Key':'77',
	'Keyboard 1 - Lowest Key':'72',
	'Keyboard 2 - Lowest Key':'67',
	'Keyboard 3 - Lowest Key':'62',
	'Keyboard 4 - Lowest Key':'57',
	'Rounding Mode':'2',
	'Keyboard 0 - Send Y':'1',
	'Keyboard 1 - Send Y':'1',
	'Keyboard 2 - Send Y':'1',
	'Keyboard 3 - Send Y':'1',
	'Keyboard 4 - Send Y':'1',
}";

// standard parameters
f = hslider("freq",300,50,2000,0.01);
bend = ba.semi2ratio(hslider("bend[midi:pitchwheel]",0,-2,2,0.001)) : si.polySmooth(gate,0.999,1);
gain = hslider("gain",1,0,1,0.01);
s = hslider("sustain[midi:ctrl 64]",0,0,1,1); // for sustain pedal
t = button("gate");
y = hslider("y[midi:ctrl 1]",1,0,1,0.001) : si.smoo;

// fomating parameters
gate = t+s : min(1);
freq = f*bend;
cutoff = y*4000+50;
envelope = gate*gain : si.smoo;

process = os.sawtooth(freq)*envelope : fi.lowpass(3,cutoff) <: _,_;

<!-- /faust-run -->


## turenas

<!-- faust-run -->

//################################### turenas.dsp ########################################
// A simple smart phone percussion based on an additive synthesizer.
//
// ## `SmartKeyboard` Use Strategy
//
// Since the sounds generated by this synth are very short, the strategy here is to take
// advantage of the polyphony capabilities of the iOSKeyboard architecture by creating
// a new voice every time a new key is pressed. Since the `SmartKeyboard` interface has a
// large number of keys here (180), lots of sounds are generated when sliding a
// finger across the keyboard.
//
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] turenas.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

declare name "turenas";

import("stdfaust.lib");

//========================= Smart Keyboard Configuration =================================
// (10 keyboards with 18 keys each configured as a pitch matrix.
//========================================================================================

declare interface "SmartKeyboard{
	'Number of Keyboards':'10',
	'Keyboard 0 - Number of Keys':'18',
	'Keyboard 1 - Number of Keys':'18',
	'Keyboard 2 - Number of Keys':'18',
	'Keyboard 3 - Number of Keys':'18',
	'Keyboard 4 - Number of Keys':'18',
	'Keyboard 5 - Number of Keys':'18',
	'Keyboard 6 - Number of Keys':'18',
	'Keyboard 7 - Number of Keys':'18',
	'Keyboard 8 - Number of Keys':'18',
	'Keyboard 9 - Number of Keys':'18',
	'Keyboard 0 - Lowest Key':'50',
	'Keyboard 1 - Lowest Key':'55',
	'Keyboard 2 - Lowest Key':'60',
	'Keyboard 3 - Lowest Key':'65',
	'Keyboard 4 - Lowest Key':'70',
	'Keyboard 5 - Lowest Key':'75',
	'Keyboard 6 - Lowest Key':'80',
	'Keyboard 7 - Lowest Key':'85',
	'Keyboard 8 - Lowest Key':'90',
	'Keyboard 9 - Lowest Key':'95',
	'Keyboard 0 - Piano Keyboard':'0',
	'Keyboard 1 - Piano Keyboard':'0',
	'Keyboard 2 - Piano Keyboard':'0',
	'Keyboard 3 - Piano Keyboard':'0',
	'Keyboard 4 - Piano Keyboard':'0',
	'Keyboard 5 - Piano Keyboard':'0',
	'Keyboard 6 - Piano Keyboard':'0',
	'Keyboard 7 - Piano Keyboard':'0',
	'Keyboard 8 - Piano Keyboard':'0',
	'Keyboard 9 - Piano Keyboard':'0',
	'Keyboard 0 - Send X':'0',
	'Keyboard 1 - Send X':'0',
	'Keyboard 2 - Send X':'0',
	'Keyboard 3 - Send X':'0',
	'Keyboard 4 - Send X':'0',
	'Keyboard 5 - Send X':'0',
	'Keyboard 6 - Send X':'0',
	'Keyboard 7 - Send X':'0',
	'Keyboard 8 - Send X':'0',
	'Keyboard 9 - Send X':'0'
}";

//================================ Instrument Parameters =================================
// Creates the connection between the synth and the mobile device
//========================================================================================

// SmartKeyboard Y parameter
y = hslider("y",0,0,1,0.01);
// Smart Keyboard frequency parameter
freq = hslider("freq",400,50,2000,0.01);
// SmartKeyboard gate parameter
gate = button("gate");
// mode resonance duration is controlled with the x axis of the accelerometer
res = hslider("res[acc: 0 0 -10 0 10]",2.5,0.01,5,0.01);

//=================================== Parameters Mapping =================================
//========================================================================================

// number of modes
nModes = 6;
// distance between each mode
maxModeSpread = 5;
modeSpread = y*maxModeSpread;
// computing modes frequency ratio
modeFreqRatios = par(i,nModes,1+(i+1)/nModes*modeSpread);
// computing modes gain
minModeGain = 0.3;
modeGains = par(i,nModes,1-(i+1)/(nModes*minModeGain));
// smoothed mode resonance
modeRes = res : si.smoo;

//============================================ DSP =======================================
//========================================================================================

process = sy.additiveDrum(freq,modeFreqRatios,modeGains,0.8,0.001,modeRes,gate)*0.05;

<!-- /faust-run -->


## violin2

<!-- faust-run -->

//############################### violin2.dsp ##################################
// Faust instrument specifically designed for `faust2smartkeyb` where a
// complete violin physical model can be played using the touch sceen
// interface. Bowing is carried out by constantly moving a finger on the
// y axis of a key.
//
// ## `SmartKeyboard` Use Strategy
//
// 4 keyboards are used to control the pitch of the 4 bowed strings. Strings
// are connected to the virtual bow when they are touched.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets.
// However it was specifically designed to be used with `faust2smartkeyb`. For
// best results, we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect reverb.dsp violin.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Aug. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//##############################################################################

declare interface "SmartKeyboard{
	'Number of Keyboards':'4',
	'Max Keyboard Polyphony':'0',
	'Rounding Mode':'2',
	'Send Fingers Count':'1',
	'Keyboard 0 - Number of Keys':'12',
	'Keyboard 1 - Number of Keys':'12',
	'Keyboard 2 - Number of Keys':'12',
	'Keyboard 3 - Number of Keys':'12',
	'Keyboard 0 - Lowest Key':'55',
	'Keyboard 1 - Lowest Key':'62',
	'Keyboard 2 - Lowest Key':'69',
	'Keyboard 3 - Lowest Key':'76',
	'Keyboard 0 - Send Keyboard Freq':'1',
	'Keyboard 1 - Send Keyboard Freq':'1',
	'Keyboard 2 - Send Keyboard Freq':'1',
	'Keyboard 3 - Send Keyboard Freq':'1',
	'Keyboard 0 - Send Y':'1',
	'Keyboard 1 - Send Y':'1',
	'Keyboard 2 - Send Y':'1',
	'Keyboard 3 - Send Y':'1'
}";

import("stdfaust.lib");

// SMARTKEYBOARD PARAMS
kbfreq(0) = hslider("kb0freq",220,20,10000,0.01);
kbbend(0) = hslider("kb0bend",1,0,10,0.01);
kbfreq(1) = hslider("kb1freq",330,20,10000,0.01);
kbbend(1) = hslider("kb1bend",1,0,10,0.01);
kbfreq(2) = hslider("kb2freq",440,20,10000,0.01);
kbbend(2) = hslider("kb2bend",1,0,10,0.01);
kbfreq(3) = hslider("kb3freq",550,20,10000,0.01);
kbbend(3) = hslider("kb3bend",1,0,10,0.01);
kbfingers(0) = hslider("kb0fingers",0,0,10,1) : int;
kbfingers(1) = hslider("kb1fingers",0,0,10,1) : int;
kbfingers(2) = hslider("kb2fingers",0,0,10,1) : int;
kbfingers(3) = hslider("kb3fingers",0,0,10,1) : int;
y = hslider("y",0,0,1,1) : si.smoo;

// MODEL PARAMETERS
// strings lengths
sl(i) = kbfreq(i)*kbbend(i) : pm.f2l : si.smoo;
// string active only if fingers are touching the keyboard
as(i) = kbfingers(i)>0;
// retrieving finger displacement on screen (dirt simple)
bowVel = y-y' : abs : *(3000) : min(1) : si.smoo;
// bow position is constant but could be ontrolled by an external interface
bowPos = 0.7;
bowPress = 0.5;

// ASSEMBLING MODELS
// essentially 4 parallel violin strings
model = par(i,4,pm.violinModel(sl(i),bowPress,bowVel*as(i),bowPos)) :> _;

process = model <: _,_;

<!-- /faust-run -->


## violin

<!-- faust-run -->

//############################### violin.dsp ###################################
// Faust instrument specifically designed for `faust2smartkeyb` where a
// complete violin physical model can be played using the touch sceen
// interface. While the 4 virtual strings can be bowed using a control
// surface on the screen, it could be easily substituted with an external
// interface.
//
// ## `SmartKeyboard` Use Strategy
//
// 4 keyboards are used to control the pitch of the 4 bowed strings. Strings
// are connected to the virtual bow when they are touched. A pad created from
// a keybaord with a single key can be used to control the bow velocity and
// pressure on the selected strings.
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets.
// However it was specifically designed to be used with `faust2smartkeyb`. For
// best results, we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] -effect reverb.dsp violin.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Aug. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//##############################################################################

declare interface "SmartKeyboard{
	'Number of Keyboards':'5',
	'Max Keyboard Polyphony':'0',
	'Rounding Mode':'2',
	'Send Fingers Count':'1',
	'Keyboard 0 - Number of Keys':'19',
	'Keyboard 1 - Number of Keys':'19',
	'Keyboard 2 - Number of Keys':'19',
	'Keyboard 3 - Number of Keys':'19',
	'Keyboard 4 - Number of Keys':'1',
	'Keyboard 0 - Lowest Key':'55',
	'Keyboard 1 - Lowest Key':'62',
	'Keyboard 2 - Lowest Key':'69',
	'Keyboard 3 - Lowest Key':'76',
	'Keyboard 0 - Send Keyboard Freq':'1',
	'Keyboard 1 - Send Keyboard Freq':'1',
	'Keyboard 2 - Send Keyboard Freq':'1',
	'Keyboard 3 - Send Keyboard Freq':'1',
	'Keyboard 4 - Send Freq':'0',
	'Keyboard 4 - Send Key X':'1',
	'Keyboard 4 - Send Key Y':'1',
	'Keyboard 4 - Key 0 - Label':'Bow',
	'Keyboard 4 - Static Mode':'1'
}";

import("stdfaust.lib");

// SMARTKEYBOARD PARAMS
kbfreq(0) = hslider("kb0freq",220,20,10000,0.01);
kbbend(0) = hslider("kb0bend",1,0,10,0.01);
kbfreq(1) = hslider("kb1freq",330,20,10000,0.01);
kbbend(1) = hslider("kb1bend",1,0,10,0.01);
kbfreq(2) = hslider("kb2freq",440,20,10000,0.01);
kbbend(2) = hslider("kb2bend",1,0,10,0.01);
kbfreq(3) = hslider("kb3freq",550,20,10000,0.01);
kbbend(3) = hslider("kb3bend",1,0,10,0.01);
kb4k0x = hslider("kb4k0x",0,0,1,1) : si.smoo;
kb4k0y = hslider("kb4k0y",0,0,1,1) : si.smoo;
kbfingers(0) = hslider("kb0fingers",0,0,10,1) : int;
kbfingers(1) = hslider("kb1fingers",0,0,10,1) : int;
kbfingers(2) = hslider("kb2fingers",0,0,10,1) : int;
kbfingers(3) = hslider("kb3fingers",0,0,10,1) : int;

// MODEL PARAMETERS
// strings lengths
sl(i) = kbfreq(i)*kbbend(i) : pm.f2l : si.smoo;
// string active only if fingers are touching the keyboard
as(i) = kbfingers(i)>0;
// bow pressure could also be controlled by an external parameter
bowPress = kb4k0y;
// retrieving finger displacement on screen (dirt simple)
bowVel = kb4k0x-kb4k0x' : abs : *(8000) : min(1) : si.smoo;
// bow position is constant but could be ontrolled by an external interface
bowPos = 0.7;

// ASSEMBLING MODELS
// essentially 4 parallel violin strings
model = par(i,4,pm.violinModel(sl(i),bowPress,bowVel*as(i),bowPos)) :> _;

process = model <: _,_;

<!-- /faust-run -->


## vocal

<!-- faust-run -->

//######################################## vocal.dsp #####################################
// A funny vocal synth app...
//
// ## Compilation Instructions
//
// This Faust code will compile fine with any of the standard Faust targets. However
// it was specifically designed to be used with `faust2smartkeyb`. For best results,
// we recommend to use the following parameters to compile it:
//
// ```
// faust2smartkeyb [-ios/-android] vocal.dsp
// ```
//
// ## Version/Licence
//
// Version 0.0, Feb. 2017
// Copyright Romain Michon CCRMA (Stanford University)/GRAME 2017
// MIT Licence: https://opensource.org/licenses/MIT
//########################################################################################

import("stdfaust.lib");

declare interface "SmartKeyboard{
	'Number of Keyboards':'1',
	'Max Keyboard Polyphony':'0',
	'Keyboard 0 - Number of Keys':'1',
	'Keyboard 0 - Send Freq':'0',
	'Keyboard 0 - Static Mode':'1',
	'Keyboard 0 - Send X':'1',
	'Keyboard 0 - Piano Keyboard':'0'
}";

// standard parameters
vowel = hslider("vowel[acc: 0 0 -10 0 10]",2,0,4,0.01) : si.smoo;
x = hslider("x",0.5,0,1,0.01) : si.smoo;
vibrato = hslider("vibrato[acc: 1 0 -10 0 10]",0.05,0,0.1,0.01);
gain = hslider("gain",0.25,0,1,0.01);

// fomating parameters
freq = x*200 + 50;
voiceFreq = freq*(os.osc(6)*vibrato+1);

process = pm.SFFormantModelBP(1,vowel,0,voiceFreq,gain) <: _,_;

<!-- /faust-run -->
