# bela


## AdditiveSynth_Analog

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Additive synthesizer, must be used with OSC message to program sound.
// It as 8 harmonics. Each have it's own volume envelope.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_0	: vol0 (volum of fundamental)
// ANALOG_1	: vol1
// ...
// ANALOG_7	: vol7
//
// OSC messages (see BELA console for precise adress)
// For each harmonics (%rang indicate harmonic number, starting at 0) :
// A%rang : Attack
// D%rang : Decay
// S%rang : Sustain
// R%rang : Release
//
///////////////////////////////////////////////////////////////////////////////////////////////////

// GENERAL
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 0.5, 0, 10, 0.01);

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

gFreq = midifreq * bend;

partiel(rang) = os.oscrs(gFreq*(rang+1))*volume
    with {
        // UI
        vol	= hslider("vol%rang[BELA: ANALOG_%rang]", 1, 0, 1, 0.001);
     
        a = 0.01 * hslider("A%rang", 1, 0, 400, 0.001);
        d = 0.01 * hslider("D%rang", 1, 0, 400, 0.001);
        s = hslider("S%rang", 1, 0, 1, 0.001);
        r = 0.01 * hslider("R%rang", 1, 0, 800, 0.001);

        volume = ((en.adsr(a,d,s,r,midigate))*vol) : max (0) : min (1);
    };

process = par(i, 8, partiel(i)) :> / (8);

<!-- /faust-run -->


## AdditiveSynth

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Additive synthesizer, must be used with OSC message to program sound.
// It as 8 harmonics. Each have it's own volume envelop.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// OSC messages (see BELA console for precise adress)
// For each harmonics (%rang indicate harmonic number, starting at 0) :
// vol%rang	: General Volume (vol0 control the volume of the fundamental)
// A%rang : Attack
// D%rang : Decay
// S%rang : Sustain
// R%rang : Release
//
///////////////////////////////////////////////////////////////////////////////////////////////////

// GENERAL
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 0.5, 0, 10, 0.01);

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

gFreq = midifreq * bend;

partiel(rang) = os.oscrs(gFreq*(rang+1))*volume
    with {
        // UI
        vol	= hslider("vol%rang", 1, 0, 1, 0.001);
     
        a = 0.01 * hslider("A%rang", 1, 0, 400, 0.001);
        d = 0.01 * hslider("D%rang", 1, 0, 400, 0.001);
        s = hslider("S%rang", 1, 0, 1, 0.001);
        r = 0.01 * hslider("R%rang", 1, 0, 800, 0.001);

        volume = ((en.adsr(a,d,s,r,midigate))*vol) : max (0) : min (1);
    };

process = par(i, 8, partiel(i)) :> / (8);

<!-- /faust-run -->


## crossDelay2

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Stereo Delay with feedback and crossfeedback (L to R and R to L feedback).
// And pitch shifting on feedback.
// A pre-delay without feedback is added for a wider stereo effect.
//
// Designed to use the Analog Input for parameters controls.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// ANALOG IN:
// ANALOG 0	: Pre-Delay L
// ANALOG 1	: Pre-Delay R
// ANALOG 2	: Delay L
// ANALOG 3	: Delay R
// ANALOG 4	: Cross feedback
// ANALOG 5	: Feedback
// ANALOG 6	: Pitchshifter L
// ANALOG 7	: Pitchshifter R
//
// Available by OSC : (see BELA console for precise adress)
// Feedback filter:
// crossLF : Crossfeedback Lowpass
// crossHF : Crossfeedback Highpass
// feedbLF : Feedback Lowpass
// feedbHF : Feedback Highpass
//
///////////////////////////////////////////////////////////////////////////////////////////////////

preDelL	= ba.sec2samp(hslider("preDelL[BELA: ANALOG_0]", 1,0,2,0.001)):si.smoo;
preDelR	= ba.sec2samp(hslider("preDelR[BELA: ANALOG_1]", 1,0,2,0.001)):si.smoo;
delL	= ba.sec2samp(hslider("delL[BELA: ANALOG_2]", 1,0,2,0.001)):si.smoo;
delR	= ba.sec2samp(hslider("delR[BELA: ANALOG_3]", 1,0,2,0.001)):si.smoo;

crossLF	= hslider("crossLF", 12000, 20, 20000, 0.001);
crossHF	= hslider("crossHF", 60, 20, 20000, 0.001);
feedbLF	= hslider("feedbLF", 12000, 20, 20000, 0.001);
feedbHF	= hslider("feedbHF", 60, 20, 20000, 0.001);

CrossFeedb = hslider("CrossFeedb[BELA: ANALOG_4]", 0.0, 0., 1, 0.001):si.smoo;
feedback = hslider("feedback[BELA: ANALOG_5]", 0.0, 0., 1, 0.001):si.smoo;

pitchL = hslider("shiftL[BELA: ANALOG_6]", 0,-12,12,0.001):si.smoo;
pitchR = hslider("shiftR[BELA: ANALOG_7]", 0,-12,12,0.001):si.smoo;

routeur(a,b,c,d) = ((a*CrossFeedb):fi.lowpass(2,crossLF):fi.highpass(2,crossHF))+((b*feedback):fi.lowpass(2,feedbLF):fi.highpass(2,feedbHF))+c,
					((b*CrossFeedb):fi.lowpass(2,crossLF):fi.highpass(2,crossHF))+((a*feedback):fi.lowpass(2,feedbLF):fi.highpass(2,feedbHF))+d;

process = (de.sdelay(65536, 512,preDelL),de.sdelay(65536, 512,preDelR)):(routeur : de.sdelay(65536, 512,delL), de.sdelay(65536, 512,delR))~(ef.transpose(512, 256, pitchL), ef.transpose(512, 256, pitchR));

<!-- /faust-run -->


## FMSynth2_Analog

<!-- faust-run -->

import("all.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Simple FM synthesizer.

///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_0	: Modulator frequency ratio
// ANALOG_1	: Attack
// ANALOG_2	: Decay/Release
// ANALOG_3	: Sustain
//
// MIDI:
// CC 1 : FM feedback on modulant oscillator.
//
///////////////////////////////////////////////////////////////////////////////////////////////////

// GENERAL, Keyboard
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 1, 0, 1, 0.01);

// modwheel:
feedb = (gFreq-1) * (hslider("feedb[midi:ctrl 1]", 0, 0, 1, 0.001) : si.smoo);
modFreqRatio = hslider("ratio[BELA: ANALOG_0]",2,0,20,0.01) : si.smoo;

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

gFreq = midifreq * bend;

//=================================== Parameters Mapping =================================
//========================================================================================
// Same for volume & modulation:
volA = hslider("A[BELA: ANALOG_1]",0.01,0.01,4,0.01);
volDR = hslider("DR[BELA: ANALOG_2]",0.6,0.01,8,0.01);
volS = hslider("S[BELA: ANALOG_3]",0.2,0,1,0.01);
envelop = en.adsre(volA,volDR,volS,volDR,midigate);

// modulator frequency
modFreq = gFreq * modFreqRatio;

// modulation index
FMdepth = envelop * 1000 * midigain;

// Out amplitude
vol = envelop;

//============================================ DSP =======================================
//========================================================================================

FMfeedback(frq) = (+(_,frq):os.osci) ~ (*(feedb));
FMall(f) = os.osci(f + (FMdepth*FMfeedback(f*modFreqRatio)));

process = FMall(gFreq) * vol;

<!-- /faust-run -->


## FMSynth2

<!-- faust-run -->

import("all.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Simple FM synthesizer.
// 2 oscillators and FM feedback on modulant oscillator
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// MIDI IMPLEMENTATION:
//
// CC 1 : FM feedback on modulant oscillator.
// CC 14 : Modulator frequency ratio.
//
// CC 73 : Attack
// CC 76 : Decay
// CC 77 : Sustain
// CC 72 : Release
//
///////////////////////////////////////////////////////////////////////////////////////////////////

// GENERAL, Keyboard
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 1, 0, 1, 0.01);

// modwheel:
feedb = (gFreq-1) * (hslider("feedb[midi:ctrl 1]", 0, 0, 1, 0.001) : si.smoo);
modFreqRatio = hslider("ratio[midi:ctrl 14]",2,0,20,0.01) : si.smoo;

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

gFreq = midifreq * bend;

//=================================== Parameters Mapping =================================
//========================================================================================
// Same for volum & modulation:
volA = hslider("A[midi:ctrl 73]",0.01,0.01,4,0.01);
volD = hslider("D[midi:ctrl 76]",0.6,0.01,8,0.01);
volS = hslider("S[midi:ctrl 77]",0.2,0,1,0.01);
volR = hslider("R[midi:ctrl 72]",0.8,0.01,8,0.01);
envelop = en.adsre(volA,volD,volS,volR,midigate);

// modulator frequency
modFreq = gFreq*modFreqRatio;

// modulation index
FMdepth = envelop * 1000 * midigain;

// Out amplitude
vol = envelop;

//============================================ DSP =======================================
//========================================================================================

FMfeedback(frq) = (+(_,frq):os.osci ) ~ (* (feedb));
FMall(f) = os.osci(f + (FMdepth*FMfeedback(f*modFreqRatio)));

process = FMall(gFreq) * vol;

<!-- /faust-run -->


## FMSynth2_FX_Analog

<!-- faust-run -->

import("all.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Simple FM synthesizer.
// 2 oscillators and FM feedback on modulant oscillator
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_0	: Modulator frequency ratio
// ANALOG_1	: Attack
// ANALOG_2	: Decay/Release
// ANALOG_3	: Sustain
//
// MIDI:
// CC 1 : FM feedback on modulant oscillator.
//
///////////////////////////////////////////////////////////////////////////////////////////////////

// GENERAL, Keyboard
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 1, 0, 1, 0.01);

// modwheel:
feedb = (gFreq-1) * (hslider("feedb[midi:ctrl 1]", 0, 0, 1, 0.001) : si.smoo);
modFreqRatio = hslider("ratio[BELA: ANALOG_0]",2,0,20,0.01) : si.smoo;

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

gFreq = midifreq * bend;

//=================================== Parameters Mapping =================================
//========================================================================================
// Same for volume & modulation:
volA = hslider("A[BELA: ANALOG_1]",0.01,0.01,4,0.01);
volDR = hslider("DR[BELA: ANALOG_2]",0.6,0.01,8,0.01);
volS = hslider("S[BELA: ANALOG_3]",0.2,0,1,0.01);
envelop = en.adsre(volA,volDR,volS,volDR,midigate);

// modulator frequency
modFreq = gFreq * modFreqRatio;

// modulation index
FMdepth = envelop * 1000 * midigain;

// Out amplitude
vol = envelop;

//============================================ DSP =======================================
//========================================================================================

FMfeedback(frq) = (+(_,frq):os.osci) ~ (* (feedb));
FMall(f) = os.osci(f + (FMdepth*FMfeedback(f*modFreqRatio)));

//#################################################################################################//
//##################################### EFFECT SECTION ############################################//
//#################################################################################################//
//
// Simple FX chaine build for a mono synthesizer.
// It controle general volume and pan.
// FX Chaine is:
//		Drive
//		Flanger
//		Reverberation
//
// This version use ANALOG IN to controle some of the parameters.
// Other parameters continue to be available by MIDI or OSC.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_4	: Distortion Drive
// ANALOG_5	: Flanger Dry/Wet
// ANALOG_6	: Reverberation Dry/Wet
// ANALOG_7	: Reverberation Room size
//
// MIDI:
// CC 7	: Volume
// CC 10 : Pan
//
// CC 13 : Flanger Delay
// CC 13 : Flanger Delay
// CC 94 : Flanger Feedback
//
// CC 95 : Reverberation Damp
// CC 90 : Reverberation Stereo Width
// 
///////////////////////////////////////////////////////////////////////////////////////////////////

// VOLUME:
volFX = hslider("volume[midi:ctrl 7]",1,0,1,0.001);	// Should be 7 according to MIDI CC norm.

// EFFECTS /////////////////////////////////////////////
drive = hslider("drive[BELA: ANALOG_4]",0.3,0,1,0.001);

// Flanger
curdel = hslider("flangDel[midi:ctrl 13]",4,0.001,10,0.001);
fb = hslider("flangFeedback[midi:ctrl 94]",0.7,0,1,0.001);
fldw = hslider("dryWetFlang[BELA: ANALOG_5]",0.5,0,1,0.001);
flanger = efx
	with {
		fldel = (curdel + (os.lf_triangle(1) * 2) ) : min(10);
		efx = _ <: _, pf.flanger_mono(10,fldel,1,fb,0) : dry_wet(fldw);
	};

// Pannoramique:
panno = _ : sp.panner(hslider("pan[midi:ctrl 10]",0.5,0,1,0.001)) : _,_;

// REVERB (from freeverb_demo)
reverb = _,_ <: (*(g)*fixedgain, *(g)*fixedgain :
	re.stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)),
	*(1-g), *(1-g) :> _,_
    with {
        scaleroom   = 0.28;
        offsetroom  = 0.7;
        allpassfeed = 0.5;
        scaledamp   = 0.4;
        fixedgain   = 0.1;
        origSR = 44100;

        damping = vslider("Damp[midi:ctrl 95]",0.5, 0, 1, 0.025)*scaledamp*origSR/ma.SR;
        combfeed = vslider("RoomSize[BELA: ANALOG_7]", 0.7, 0, 1, 0.025)*scaleroom*origSR/ma.SR + offsetroom;
        spatSpread = vslider("Stereo[midi:ctrl 90]",0.6,0,1,0.01)*46*ma.SR/origSR;
        g = vslider("dryWetReverb[BELA: ANALOG_6]", 0.4, 0, 1, 0.001);
        // (g = Dry/Wet)
    };

// Dry-Wet (from C. LEBRETON)
dry_wet(dw,x,y) = wet*y + dry*x
    with {
        wet = 0.5*(dw+1.0);
        dry = 1.0-wet;
    };

// ALL
effect = _ *(volFX) : ef.cubicnl_nodc(drive, 0.1) : flanger : panno : reverb;

process = FMall(gFreq) * vol;


<!-- /faust-run -->


## FMSynth2_FX

<!-- faust-run -->

import("all.lib");


///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Simple FM synthesizer.
// 2 oscillators and FM feedback on modulant oscillator
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// MIDI IMPLEMENTATION:
//
// CC 1		: FM feedback on modulant oscillator.
// CC 14	: Modulator frequency ratio.
//
// CC 73	: Attack
// CC 76	: Decay
// CC 77	: Sustain
// CC 72	: Release
//
///////////////////////////////////////////////////////////////////////////////////////////////////

// GENERAL, Keyboard
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 1, 0, 1, 0.01);

// modwheel:
feedb = (gFreq-1) * (hslider("feedb[midi:ctrl 1]", 0, 0, 1, 0.001) : si.smoo);
modFreqRatio = hslider("ratio[midi:ctrl 14]",2,0,20,0.01) : si.smoo;

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

gFreq = midifreq * bend;

//=================================== Parameters Mapping =================================
//========================================================================================
// Same for volum & modulation:
volA = hslider("A[midi:ctrl 73]",0.01,0.01,4,0.01);
volD = hslider("D[midi:ctrl 76]",0.6,0.01,8,0.01);
volS = hslider("S[midi:ctrl 77]",0.2,0,1,0.01);
volR = hslider("R[midi:ctrl 72]",0.8,0.01,8,0.01);
envelop = en.adsre(volA,volD,volS,volR,midigate);

// modulator frequency
modFreq = gFreq*modFreqRatio;

// modulation index
FMdepth = envelop * 1000 * midigain;

// Out amplitude
vol = envelop;

//============================================ DSP =======================================
//========================================================================================

FMfeedback(frq) = (+(_,frq):os.osci) ~ (* (feedb));
FMall(f) = os.osci(f + (FMdepth*FMfeedback(f*modFreqRatio)));

//#################################################################################################//
//##################################### EFFECT SECTION ############################################//
//#################################################################################################//
// Simple FX chain build for a mono synthesizer.
// It control general volume and pan.
// FX Chaine is:
//		Drive
//		Flanger
//		Reverberation
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// MIDI IMPLEMENTATION:
// (All are available by OSC)
//
// CC 7	: Volume
// CC 10 : Pan
//
// CC 92 : Distortion Drive
//
// CC 13 : Flanger Delay
// CC 93 : Flanger Dry/Wet
// CC 94 : Flanger Feedback
//
// CC 12 : Reverberation Room size
// CC 91 : Reverberation Dry/Wet
// CC 95 : Reverberation Damp
// CC 90 : Reverberation Stereo Width
//
///////////////////////////////////////////////////////////////////////////////////////////////////

// VOLUME:
volFX = hslider("volume[midi:ctrl 7]",1,0,1,0.001);	// Should be 7 according to MIDI CC norm.

// EFFECTS /////////////////////////////////////////////
drive = hslider("drive[midi:ctrl 92]",0.3,0,1,0.001);

// Flanger
curdel = hslider("flangDel[midi:ctrl 13]",4,0.001,10,0.001);
fb = hslider("flangFeedback[midi:ctrl 94]",0.7,0,1,0.001);
fldw = hslider("dryWetFlang[midi:ctrl 93]",0.5,0,1,0.001);
flanger = efx
	with {
		fldel = (curdel + (os.lf_triangle(1) * 2) ) : min(10);
		efx = _ <: _, pf.flanger_mono(10,fldel,1,fb,0) : dry_wet(fldw);
	};

// Pannoramique:
panno = _ : sp.panner(hslider("pan[midi:ctrl 10]",0.5,0,1,0.001)) : _,_;

// REVERB (from freeverb_demo)
reverb = _,_ <: (*(g)*fixedgain,*(g)*fixedgain :
	re.stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)),
	*(1-g), *(1-g) :> _,_
    with {
        scaleroom   = 0.28;
        offsetroom  = 0.7;
        allpassfeed = 0.5;
        scaledamp   = 0.4;
        fixedgain   = 0.1;
        origSR = 44100;

        damping = vslider("Damp[midi:ctrl 95]",0.5, 0, 1, 0.025)*scaledamp*origSR/ma.SR;
        combfeed = vslider("RoomSize[midi:ctrl 12]", 0.7, 0, 1, 0.025)*scaleroom*origSR/ma.SR + offsetroom;
        spatSpread = vslider("Stereo[midi:ctrl 90]",0.6,0,1,0.01)*46*ma.SR/origSR;
        g = vslider("dryWetReverb[midi:ctrl 91]", 0.4, 0, 1, 0.001);
        // (g = Dry/Wet)
    };

// Dry-Wet (from C. LEBRETON)
dry_wet(dw,x,y) = wet*y + dry*x
    with {
        wet = 0.5*(dw+1.0);
        dry = 1.0-wet;
    };

// ALL
effect = _ *(volFX) : ef.cubicnl_nodc(drive, 0.1) : flanger : panno : reverb;

process = FMall(gFreq) * vol;

<!-- /faust-run -->


## FXChaine2

<!-- faust-run -->

import("stdfaust.lib");

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// A complete Stereo FX chain with:
//		CHORUS
//		PHASER
//		DELAY
//		REVERB
//
// Designed to use the Analog Input for parameters controls.
//
// CONTROLES ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// ANALOG IN:
// ANALOG 0	: Chorus Depth
// ANALOG 1	: Chorus Delay
// ANALOG 2	: Phaser Dry/Wet
// ANALOG 3	: Phaser Frequency ratio
// ANALOG 4	: Delay Dry/Wet
// ANALOG 5	: Delay Time
// ANALOG 6	: Reverberation Dry/Wet
// ANALOG 7	: Reverberation Room size
//
// Available by OSC : (see BELA console for precise adress)
// Rate			: Chorus LFO modulation rate (Hz)
// Deviation	: Chorus delay time deviation.
//
// InvertSum	: Phaser inversion of phaser in sum. (On/Off)
// VibratoMode	: Phaser vibrato Mode. (On/Off)
// Speed		: Phaser LFO frequency
// NotchDepth	: Phaser LFO depth
// Feedback		: Phaser Feedback
// NotchWidth	: Phaser Notch Width
// MinNotch1	: Phaser Minimal frequency
// MaxNotch1	: Phaser Maximal Frequency
//
// Damp			: Reverberation Damp
// Stereo		: Reverberation Stereo Width
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

process = chorus_stereo(dmax,curdel,rate,sigma,do2,voices) : phaserSt : xdelay : reverb;

// CHORUS (from SAM demo lib) //////////////////////////////////////////////////////////////////////////////////////////////////////////
voices = 8; // MUST BE EVEN

pi = 4.0*atan(1.0);
periodic  = 1;

dmax = 8192;
curdel = dmax * vslider("Delay[BELA: ANALOG_1]", 0.5, 0, 1, 1) : si.smooth(0.999);
rateMax = 7.0; // Hz
rateMin = 0.01;
rateT60 = 0.15661;

rate = vslider("Rate", 0.5, rateMin, rateMax, 0.0001): si.smooth(ba.tau2pole(rateT60/6.91));
depth = vslider("Depth [BELA: ANALOG_0]", 0.5, 0, 1, 0.001) : si.smooth(ba.tau2pole(depthT60/6.91));
// (dept = dry/wet)

depthT60 = 0.15661;
delayPerVoice = 0.5*curdel/voices;
sigma = delayPerVoice * vslider("Deviation",0.5,0,1,0.001) : si.smooth(0.999);

do2 = depth;   // use when depth=1 means "multivibrato" effect (no original => all are modulated)

chorus_stereo(dmax,curdel,rate,sigma,do2,voices) =
      _,_ <: *(1-do2),*(1-do2),(*(do2),*(do2) <: par(i,voices,voice(i)):>_,_) : ro.interleave(2,2) : +,+;
      voice(i) = de.fdelay(dmax,min(dmax,del(i)))/(i+1)
    with {
       angle(i) = 2*pi*(i/2)/voices + (i%2)*pi/2;
       voice(i) = de.fdelay(dmax,min(dmax,del(i))) * cos(angle(i));

         del(i) = curdel*(i+1)/voices + dev(i);
         rates(i) = rate/float(i+1);
         dev(i) = sigma *
             os.oscp(rates(i),i*2*pi/voices);
    };

// PHASER (from demo lib.) /////////////////////////////////////////////////////////////////////////////////////////////////////////////
phaserSt = _,_ <: _, _, phaser2_stereo : dry_wetST(dwPhaz)
    with {

        invert = checkbox("InvertSum");
        vibr = checkbox("VibratoMode"); // In this mode you can hear any "Doppler"

        phaser2_stereo = pf.phaser2_stereo(Notches,width,frqmin,fratio,frqmax,speed,mdepth,fb,invert);

        Notches = 4; // Compile-time parameter: 2 is typical for analog phaser stomp-boxes

        speed  = hslider("Speed", 0.5, 0, 10, 0.001);
        depth  = hslider("NotchDepth", 1, 0, 1, 0.001);
        fb     = hslider("Feedback", 0.7, -0.999, 0.999, 0.001);

        width  = hslider("NotchWidth",1000, 10, 5000, 1);
        frqmin = hslider("MinNotch1",100, 20, 5000, 1);
        frqmax = hslider("MaxNotch1",800, 20, 10000, 1) : max(frqmin);
        fratio = hslider("NotchFreqRatio[BELA: ANALOG_3]",1.5, 1.1, 4, 0.001);
        dwPhaz = vslider("dryWetPhaser[BELA: ANALOG_2]", 0.5, 0, 1, 0.001); 

        mdepth = select2(vibr,depth,2); // Improve "ease of use"
    };

// DELAY (with feedback and crossfeeback) //////////////////////////////////////////////////////////////////////////////////////////////
delay = ba.sec2samp(hslider("delay[BELA: ANALOG_5]", 1,0,2,0.001));
preDelL	= delay/2;
delL	= delay;
delR	= delay;

crossLF	= 1200;

CrossFeedb = 0.6;
dwDel = vslider("dryWetDelay[BELA: ANALOG_4]", 0.5, 0, 1, 0.001);

routeur(a,b,c,d) = ((a*CrossFeedb):fi.lowpass(2,crossLF))+c,
					((b*CrossFeedb):fi.lowpass(2,crossLF))+d;

xdelay = _,_ <: _,_,((de.sdelay(65536, 512,preDelL),_):
		(routeur : de.sdelay(65536, 512,delL) ,de.sdelay(65536, 512,delR) ) ~ (_,_)) : dry_wetST(dwDel);

// REVERB (from freeverb_demo) /////////////////////////////////////////////////////////////////////////////////////////////////////////
reverb = _,_ <: (*(g)*fixedgain, *(g)*fixedgain :
	re.stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)),
	*(1-g), *(1-g) :> _,_
    with {
        scaleroom   = 0.28;
        offsetroom  = 0.7;
        allpassfeed = 0.5;
        scaledamp   = 0.4;
        fixedgain   = 0.1;
        origSR = 44100;

        damping = vslider("Damp",0.5, 0, 1, 0.025)*scaledamp*origSR/ma.SR;
        combfeed = vslider("RoomSize[BELA: ANALOG_7]", 0.5, 0, 1, 0.001)*scaleroom*origSR/ma.SR + offsetroom;
        spatSpread = vslider("Stereo",0.5,0,1,0.01)*46*ma.SR/origSR;
        g = vslider("dryWetReverb[BELA: ANALOG_6]", 0.2, 0, 1, 0.001);
        // (g = Dry/Wet)
    };

// Dry-Wet (from C. LEBRETON)
dry_wetST(dw,x1,x2,y1,y2) = (wet*y1 + dry*x1),(wet*y2 + dry*x2)
    with {
        wet = 0.5*(dw+1.0);
        dry = 1.0-wet;
    };

<!-- /faust-run -->


## GrainGenerator

<!-- faust-run -->

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Grain Generator.
// Another granular synthesis example.
// This one is not finished, but ready for more features and improvements...
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// ANALOG IN:
// ANALOG 0	: Population: 0 = almost nothing. 1 = Full grain
// ANALOG 1	: Depth of each grain, in ms.
// ANALOG 2	: Position in the table = delay 
// ANALOG 3	: Speed = pitch change of the grains
// ANALOG 4	: Feedback
//
///////////////////////////////////////////////////////////////////////////////////////////////////

import("all.lib");

// FOR 4 grains - MONO

// UI //////////////////////////////////////////
popul = 1 - hslider("population[BELA: ANALOG_0]", 1, 0, 1, 0.001);	// Coef 1 = maximum; 0 = almost nothing (0.95)
taille = hslider("taille[BELA: ANALOG_1]", 100, 4, 200, 0.001 );	// Size in milliseconds
decal = 1 - hslider("decal[BELA: ANALOG_2]",0,0,1,0.001);			// Read position compared to table write position

speed = hslider("speed[BELA: ANALOG_3]", 1, 0.125, 4, 0.001);

feedback = hslider("feedback[BELA: ANALOG_4]",0,0,2,0.001);	

freq = 1000/taille;
tmpTaille = taille*ma.SR/ 1000;
clocSize = int(tmpTaille + (tmpTaille*popul*10)); // duration between 2 clicks

// CLK GENERAL /////////////////////////////////
// 4 clicks for 4 grains generators.
// (idem clk freq/4 and a counter...)
detect1(x) = select2 (x < 10, 0, 1);
detect2(x) = select2 (x > clocSize*1/3, 0, 1) : select2 (x < (clocSize*1/3)+10, 0, _);
detect3(x) = select2 (x > clocSize*2/3, 0, 1) : select2 (x < (clocSize*2/3)+10, 0, _);
detect4(x) = select2 (x > clocSize-10, 0, 1);
cloc = (%(_,clocSize))~(+(1)) <: (detect1: trig),(detect2: trig),(detect3: trig),(detect4: trig);

// SIGNAUX Ctrls Player ////////////////////////
trig = _<:_,mem: >;
envelop = *(2*PI):+(PI):cos:*(0.5):+(0.5);

rampe(f, t) = delta : (+ : select2(t,_,delta<0) : max(0)) ~ _ : raz
	with {
		raz(x) = select2 (x > 1, x, 0);
		delta = sh(f,t)/ma.SR;
		sh(x,t) = ba.sAndH(t,x);
	};

rampe2(speed, t) = delta : (+ : select2(t,_,delta<0) : max(0)) ~ _ 
	with {
		delta = sh(speed,t);
		sh(x,t) = ba.sAndH(t,x);
	};

// RWTable //////////////////////////////////////
unGrain(input, clk) = (linrwtable(wf , rindex) : *(0.2 * EnvGrain))
	with {
        SR = 44100;
        buffer_sec = 1;
        size = int(SR * buffer_sec);
        init = 0.;

        EnvGrain = clk : (rampe(freq) : envelop);	

        windex = (%(_,size) ) ~ (+(1));
        posTabl = int(ba.sAndH(clk, windex));
        rindex = %(int(rampe2(speed, clk)) + posTabl + int(size * decal), size);

        wf = size, init, int(windex), input;
    };

// LINEAR_INTERPOLATION_RWTABLE //////////////////////////////////
// read rwtable with linear interpolation
// wf : waveform to read (wf is defined by (size_buffer,init, windex, input))
// x  : position to read (0 <= x < size(wf)) and float
// nota: rwtable(size, init, windex, input, rindex)

linrwtable(wf,x) = linterpolation(y0,y1,d)
    with {
        x0 = int(x);                //
        x1 = int(x+1);				//
        d  = x-x0;
        y0 = rwtable(wf,x0);		//
        y1 = rwtable(wf,x1);		//
        linterpolation(v0,v1,c) = v0*(1-c)+v1*c;
    };

// FINALISATION /////////////////////////////////////////////////////////////////////////////////////
routeur(a, b, c, d, e) = a, b, a, c, a, d, a, e;

processus = _, cloc : routeur : (unGrain, unGrain, unGrain, unGrain) :> fi.dcblockerat(20);
process = _,_: ((+(_,_) :processus) ~ (*(feedback))),((+(_,_) :processus) ~ (*(feedback)));

<!-- /faust-run -->


## granulator

<!-- faust-run -->

// FROM FAUST DEMO
// Designed to use the Analog Input for parameter controls.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// ANALOG IN:
// ANALOG 0	: Grain Size
// ANALOG 1	: Speed
// ANALOG 2	: Probability
// (others analog inputs are not used)
//
///////////////////////////////////////////////////////////////////////////////////////////////////

process = vgroup("Granulator", environment {
    declare name "Granulator";
    declare author "Adapted from sfIter by Christophe Lebreton";

    /* =========== DESCRIPTION =============

    - The granulator takes very small parts of a sound, called GRAINS, and plays them at a varying speed
    - Front = Medium size grains
    - Back = short grains
    - Left Slow rhythm
    - Right = Fast rhythm
    - Bottom = Regular occurrences
    - Head = Irregular occurrences 
    */

    import("stdfaust.lib");

    process = hgroup("Granulator", *(excitation : ampf));

    excitation = noiseburst(gate,P) * (gain);
    ampf = an.amp_follower_ud(duree_env,duree_env);

    //----------------------- NOISEBURST ------------------------- 

    noiseburst(gate,P) = no.noise : *(gate : trigger(P))
        with { 
            upfront(x) = (x-x') > 0;
            decay(n,x) = x - (x>0)/n; 
            release(n) = + ~ decay(n); 
            trigger(n) = upfront : release(n) : > (0.0);
        };

    //-------------------------------------------------------------

    P = freq; // fundamental period in samples
    freq = hslider("[1]GrainSize[BELA: ANALOG_0]", 200,5,2205,1);
    // the frequency gives the white noise band width
    Pmax = 4096; // maximum P (for de.delay-line allocation)

    // PHASOR_BIN //////////////////////////////
    phasor_bin(init) = (+(float(speed)/float(ma.SR)) : fmod(_,1.0)) ~ *(init);
    gate = phasor_bin(1) :-(0.001):pulsar;
    gain = 1;
                            
    // PULSAR //////////////////////////////
    // Pulsar allows to create a more or less random 'pulse'(proba).

    pulsar = _<:((_<(ratio_env)):@(100))*(proba>(_,abs(no.noise):ba.latch)); 
    speed = hslider ("[2]Speed[BELA: ANALOG_1]", 10,1,20,0.0001):fi.lowpass(1,1);

    ratio_env = 0.5;
    fade = (0.5); // min > 0 to avoid division by 0

    proba = hslider ("[3]Probability[BELA: ANALOG_2]", 70,50,100,1) * (0.01):fi.lowpass(1,1);
    duree_env = 1/(speed: / (ratio_env*(0.25)*fade));
}.process);

<!-- /faust-run -->


## repeater

<!-- faust-run -->

// REPEATER:
// Freeze and repeat a small part of input signal 'n' time'
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// ANALOG IN:
// ANALOG 0	: Duration (ms) between 2 repeat series (500 to 2000 ms)
// ANALOG 1	: Duration of one repeat (2 to 200 ms)
// ANALOG 2	: Number of repeat
//
///////////////////////////////////////////////////////////////////////////////////////////////////

import("all.lib");

process = _,_,(pathClock : compteurUpReset2(nbRepet): rampePlayer, _) : routageIO : rec_play_table , rec_play_table;

///////////////////////////////////////////////////////////////////////////////////////////////////

// General loop duration
MasterTaille = hslider("MasterTaille[BELA: ANALOG_0]", 500, 200, 2000,0.01);
MasterClocSize = int(MasterTaille*ma.SR/ 1000);

// Depth of repeat fragments
taille = hslider("taille[BELA: ANALOG_1]", 50, 2, 200,0.01);
clocSize = int(taille*ma.SR/ 1000);

// Number of repeat fragments
nbRepet = int (hslider("nbRepet[BELA: ANALOG_2]",4,1,16,1) );

trig = _<:_,mem: >;

routageIO (a, b, c, d) = a, c, d, b, c, d;
rec_play_table(input, inReadIndex, reset) = (rwtable(wf , rindex):fi.dcblockerat(20))
    with {
        SR = 44100;
        buffer_sec = 2;
        size = int(SR * buffer_sec);
        init = 0.;

        windex = (%(_,size))~(+(1):*(1-reset));	
        rindex = (%( int(inReadIndex),size));

        wf = size, init, int(windex), input;
	};

MasterClock = (%(_,MasterClocSize))~(+(1)) : detect
    with {
        detect(x) = select2 (x < 100, 0, 1);
    };

SlaveClock(reset) = (%(_,clocSize))~(+(1):*(1-reset));
detect1(x) = select2 (x < clocSize/2, 0, 1);

pathClock = MasterClock <: trig, _ : SlaveClock, _ : detect1, _;

compteurUpReset2(nb, in, reset) = ((in:trig), reset : (routage : memo2)~_), reset
    with {
        memo2(a, b)		= (ba.if(b>0.5, 0, _) )~(+(a));
        compare(value)	= ba.if(value>nb, 1, 0); // :trig;
        routage(d,e,f)	= e, (f, compare(d) : RSLatch <: +(f));
    };

RSLatch(R, S) = latch(S,R)
    with {
        trig = _<:_,mem: >;
        latch(S,R) = _ ~ (ba.if(R>0.5, 0, _) : ba.if(S>0.5,1,_));
    };

rampePlayer(reset) = rampe
    with {
        rst = reset : trig;
        rampe = _ ~ (+(1):*(1-rst));
        toZero = _ : ba.if(reset<0.5,0,_);
    };

<!-- /faust-run -->


## simpleFX_Analog

<!-- faust-run -->

import("stdfaust.lib");
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Simple FX chain build for a mono synthesizer.
// It control general volume and pan.
// FX Chaine is:
//		Drive
//		Flanger
//		Reverberation
//
// This version use ANALOG IN to controle some of the parameters.
// Other parameters continue to be available by MIDI or OSC.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_4	: Distortion Drive
// ANALOG_5	: Flanger Dry/Wet
// ANALOG_6	: Reverberation Dry/Wet
// ANALOG_7	: Reverberation Room size
//
// MIDI:
// CC 7  : Volume
// CC 10 : Pan
//
// CC 13 : Flanger Delay
// CC 13 : Flanger Delay
// CC 94 : Flanger Feedback
//
// CC 95 : Reverberation Damp
// CC 90: Reverberation Stereo Width
// 
///////////////////////////////////////////////////////////////////////////////////////////////////

// VOLUME:
vol	= hslider("volume[midi:ctrl 7]",1,0,1,0.001);// Should be 7 according to MIDI CC norm.

// EFFECTS /////////////////////////////////////////////
drive = hslider("drive[BELA: ANALOG_4]",0.3,0,1,0.001);

// Flanger
curdel = hslider("flangDel[midi:ctrl 13]",4,0.001,10,0.001);
fb = hslider("flangFeedback[midi:ctrl 94]",0.7,0,1,0.001);
fldw = hslider("dryWetFlang[BELA: ANALOG_5]",0.5,0,1,0.001);
flanger = efx
	with {
		fldel = (curdel + (os.lf_triangle(1) * 2) ) : min(10);
		efx = _ <: _, pf.flanger_mono(10,fldel,1,fb,0) : dry_wet(fldw);
	};

// Panoramic:
panno = _ : sp.panner(hslider ("pan[midi:ctrl 10]",0.5,0,1,0.001)) : _,_;

// REVERB (from freeverb_demo)
reverb = _,_ <: (*(g)*fixedgain, *(g)*fixedgain :
	re.stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)),
	*(1-g), *(1-g) :> _,_
    with {
        scaleroom   = 0.28;
        offsetroom  = 0.7;
        allpassfeed = 0.5;
        scaledamp   = 0.4;
        fixedgain   = 0.1;
        origSR = 44100;

        damping = vslider("Damp[midi:ctrl 95]",0.5, 0, 1, 0.025)*scaledamp*origSR/ma.SR;
        combfeed = vslider("RoomSize[BELA: ANALOG_7]", 0.7, 0, 1, 0.025)*scaleroom*origSR/ma.SR + offsetroom;
        spatSpread = vslider("Stereo[midi:ctrl 90]",0.6,0,1,0.01)*46*ma.SR/origSR;
        g = vslider("dryWetReverb[BELA: ANALOG_6]", 0.4, 0, 1, 0.001);
        // (g = Dry/Wet)
    };

// Dry-Wet (from C. LEBRETON)
dry_wet(dw,x,y) = wet*y + dry*x
    with {
        wet = 0.5*(dw+1.0);
        dry = 1.0-wet;
    };

// ALL
effets = _ *(vol) : ef.cubicnl_nodc(drive, 0.1) : flanger : panno : reverb;

process = effets;

<!-- /faust-run -->


## simpleFX

<!-- faust-run -->

import("stdfaust.lib");
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Simple FX chaine build for a mono synthesizer.
// It controle general volume and pan.
// FX Chaine is:
//		Drive
//		Flanger
//		Reverberation
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// MIDI IMPLEMENTATION:
// (All are available by OSC)
//
// CC 7  : Volume
// CC 10 : Pan
//
// CC 92 : Distortion Drive
//
// CC 13 : Flanger Delay
// CC 93 : Flanger Dry/Wet
// CC 94 : Flanger Feedback
//
// CC 12 : Reverberation Room size
// CC 91 : Reverberation Dry/Wet
// CC 95 : Reverberation Damp
// CC 90 : Reverberation Stereo Width
//
///////////////////////////////////////////////////////////////////////////////////////////////////

// VOLUME:
vol = hslider("volume[midi:ctrl 7]",1,0,1,0.001);// Should be 7 according to MIDI CC norm.

// EFFECTS /////////////////////////////////////////////
drive = hslider("drive[midi:ctrl 92]",0.3,0,1,0.001);

// Flanger
curdel = hslider("flangDel[midi:ctrl 13]",4,0.001,10,0.001);
fb = hslider("flangFeedback[midi:ctrl 94]",0.7,0,1,0.001);
fldw = hslider("dryWetFlang[midi:ctrl 93]",0.5,0,1,0.001);
flanger = efx
	with {
		fldel = (curdel + (os.lf_triangle(1) * 2) ) : min(10);
		efx = _ <: _, pf.flanger_mono(10,fldel,1,fb,0) : dry_wet(fldw);
	};

// Panoramique:
panno = _ : sp.panner(hslider ("pan[midi:ctrl 10]",0.5,0,1,0.001)) : _,_;

// REVERB (from freeverb_demo)
reverb = _,_ <: (*(g)*fixedgain,*(g)*fixedgain :
	re.stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)),
	*(1-g), *(1-g) :> _,_
    with {
        scaleroom   = 0.28;
        offsetroom  = 0.7;
        allpassfeed = 0.5;
        scaledamp   = 0.4;
        fixedgain   = 0.1;
        origSR = 44100;

        damping = vslider("Damp[midi:ctrl 95]",0.5, 0, 1, 0.025)*scaledamp*origSR/ma.SR;
        combfeed = vslider("RoomSize[midi:ctrl 12]", 0.7, 0, 1, 0.025)*scaleroom*origSR/ma.SR + offsetroom;
        spatSpread = vslider("Stereo[midi:ctrl 90]",0.6,0,1,0.01)*46*ma.SR/origSR;
        g = vslider("dryWetReverb[midi:ctrl 91]", 0.4, 0, 1, 0.001);
        // (g = Dry/Wet)
    };

// Dry-Wet (from C. LEBRETON)
dry_wet(dw,x,y) = wet*y + dry*x
    with {
        wet = 0.5*(dw+1.0);
        dry = 1.0-wet;
    };

// ALL
effets = _ *(vol) : ef.cubicnl_nodc(drive, 0.1) : flanger : panno : reverb;

process = effets;

<!-- /faust-run -->


## simpleSynth_Analog

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// A very simple subtractive synthesizer with 1 VCO 1 VCF.
// The VCO Waveform is variable between Saw and Square
// The frequency is modulated by an LFO
// The envelope control volum and filter frequency
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_0	: waveform (Saw to square)
// ANALOG_1	: Filter Cutoff frequency
// ANALOG_2	: Filter resonance (Q)
// ANALOG_3	: Filter Envelope Modulation
//
// MIDI:
// CC 79 : Filter keyboard tracking (0 to X2, default 1)
//
// Envelope
// CC 73 : Attack
// CC 76 : Decay
// CC 77 : Sustain
// CC 72 : Release
//
// CC 78 : LFO frequency (0.001Hz to 10Hz)
// CC 1  : LFO Amplitude (Modulation)
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// HUI //////////////////////////////////////////////////
// Keyboard
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 0.5, 0, 0.5, 0.01);// MIDI KEYBOARD

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

// VCO
wfFade = hslider("waveform[BELA: ANALOG_0]",0.5,0,1,0.001):si.smoo;

// VCF
res = hslider("resonnance[BELA: ANALOG_2]",0.5,0,1,0.001):si.smoo;
fr = hslider("fc[BELA: ANALOG_1]", 15, 15, 12000, 0.001):si.smoo;
track = hslider("tracking[midi:ctrl 79]", 1, 0, 2, 0.001);
envMod = hslider("envMod[BELA: ANALOG_3]",50,0,100,0.01):si.smoo;

// ENV
att = 0.01 * (hslider("attack[midi:ctrl 73]",0.1,0.1,400,0.001));
dec = 0.01 * (hslider("decay[midi:ctrl 76]",60,0.1,400,0.001));
sust = hslider("sustain[midi:ctrl 77]",0.2,0,1,0.001);
rel = 0.01 * (hslider("release[midi:ctrl 72]",100,0.1,400,0.001));

// LFO
lfoFreq = hslider("lfoFreq[midi:ctrl 78]",6,0.001,10,0.001):si.smoo;
modwheel = hslider("modwheel[midi:ctrl 1]",0,0,0.5,0.001):si.smoo;

// PROCESS /////////////////////////////////////////////
allfreq = (midifreq * bend) + LFO;
// VCF
cutoff = ((allfreq * track) + fr + (envMod * midigain * env)) : min(ma.SR/8);

// VCO
oscillo(f) = (os.sawtooth(f)*(1-wfFade))+(os.square(f)*wfFade);

// VCA
volume = midigain * env;

// Enveloppe
env = en.adsre(att, dec, sust, rel, midigate);

// LFO
LFO = os.lf_triangle(lfoFreq)*modwheel*10;

// SYNTH ////////////////////////////////////////////////
synth = (oscillo(allfreq) : ve.moog_vcf(res,cutoff)) * volume;

// PROCESS /////////////////////////////////////////////
process = synth;

<!-- /faust-run -->


## simpleSynth

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// A very simple subtractive synthesizer with 1 VCO 1 VCF.
// The VCO Waveform is variable between Saw and Square
// The frequency is modulated by an LFO
// The envelope control volum and filter frequency
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// MIDI IMPLEMENTATION:
//
// CC 70 : waveform (Saw to square)
// CC 71 : Filter resonance (Q)
// CC 74 : Filter Cutoff frequency
// CC 79 : Filter keyboard tracking (0 to X2, default 1)
// CC 75 : Filter Envelope Modulation
//
// Envelope
// CC 73 : Attack
// CC 76 : Decay
// CC 77 : Sustain
// CC 72 : Release
//
// CC 78 : LFO frequency (0.001Hz to 10Hz)
// CC 1 : LFO Amplitude (Modulation)
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// HUI //////////////////////////////////////////////////
// Keyboard
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 0.5, 0, 0.5, 0.01);// MIDI KEYBOARD

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

// VCO
wfFade = hslider("waveform[midi:ctrl 70]",0.5,0,1,0.001):si.smoo;

// VCF
res = hslider("resonnance[midi:ctrl 71]",0.5,0,1,0.001):si.smoo;
fr = hslider("fc[midi:ctrl 74]", 15, 15, 12000, 0.001):si.smoo;
track = hslider("tracking[midi:ctrl 79]", 1, 0, 2, 0.001);
envMod = hslider("envMod[midi:ctrl 75]",50,0,100,0.01):si.smoo; 

// ENV
att = 0.01 * (hslider("attack[midi:ctrl 73]",0.1,0.1,400,0.001));
dec = 0.01 * (hslider("decay[midi:ctrl 76]",60,0.1,400,0.001));
sust = hslider("sustain[midi:ctrl 77]",0.1,0,1,0.001);
rel = 0.01 * (hslider("release[midi:ctrl 72]",100,0.1,400,0.001));

// LFO
lfoFreq = hslider("lfoFreq[midi:ctrl 78]",6,0.001,10,0.001):si.smoo;
modwheel = hslider("modwheel[midi:ctrl 1]",0,0,0.5,0.001):si.smoo;

// PROCESS /////////////////////////////////////////////
allfreq = (midifreq * bend) + LFO;
// VCF
cutoff = ((allfreq * track) + fr + (envMod * midigain * env)) : min(ma.SR/8);

// VCO
oscillo(f) = (os.sawtooth(f)*(1-wfFade))+(os.square(f)*wfFade);

// VCA
volume = midigain * env;

// Enveloppe
env = en.adsre(att,dec,sust,rel,midigate);

// LFO
LFO = os.lf_triangle(lfoFreq)*modwheel*10;

// SYNTH ////////////////////////////////////////////////
synth = (oscillo(allfreq) : ve.moog_vcf(res,cutoff)) * volume;

// PROCESS /////////////////////////////////////////////
process = synth;

<!-- /faust-run -->


## simpleSynth_FX_Analog

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// A very simple subtractive synthesizer with 1 VCO 1 VCF.
// The VCO Waveform is variable between Saw and Square
// The frequency is modulated by an LFO
// The envelope control volum and filter frequency
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_0	: waveform (Saw to square)
// ANALOG_1	: Filter Cutoff frequency
// ANALOG_2	: Filter resonance (Q)
// ANALOG_3	: Filter Envelope Modulation
//
// MIDI:
// CC 79	: Filter keyboard tracking (0 to X2, default 1)
//
// Envelope
// CC 73	: Attack
// CC 76	: Decay
// CC 77	: Sustain
// CC 72	: Release
//
// CC 78	: LFO frequency (0.001Hz to 10Hz)
// CC 1		: LFO Amplitude (Modulation)
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// HUI //////////////////////////////////////////////////
// Keyboard
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 0.5, 0, 0.5, 0.01);// MIDI KEYBOARD

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

// VCO
wfFade = hslider("waveform[BELA: ANALOG_0]",0.5,0,1,0.001):si.smoo;

// VCF
res = hslider("resonnance[BELA: ANALOG_2]",0.5,0,1,0.001):si.smoo;
fr = hslider("fc[BELA: ANALOG_1]", 15, 15, 12000, 0.001):si.smoo;
track = hslider("tracking[midi:ctrl 79]", 1, 0, 2, 0.001);
envMod = hslider("envMod[BELA: ANALOG_3]",50,0,100,0.01):si.smoo; 

// ENV
att = 0.01 * (hslider("attack[midi:ctrl 73]",0.1,0.1,400,0.001));
dec = 0.01 * (hslider("decay[midi:ctrl 76]",60,0.1,400,0.001));
sust = hslider ("sustain[midi:ctrl 77]",0.2,0,1,0.001);
rel = 0.01 * (hslider("release[midi:ctrl 72]",100,0.1,400,0.001));

// LFO
lfoFreq = hslider("lfoFreq[midi:ctrl 78]",6,0.001,10,0.001):si.smoo;
modwheel = hslider("modwheel[midi:ctrl 1]",0,0,0.5,0.001):si.smoo;

// PROCESS /////////////////////////////////////////////
allfreq = (midifreq * bend) + LFO;
// VCF
cutoff = ((allfreq * track) + fr + (envMod * midigain * env)) : min(ma.SR/8);

// VCO
oscillo(f) = (os.sawtooth(f)*(1-wfFade))+(os.square(f)*wfFade);

// VCA
volume = midigain * env;

// Enveloppe
env	= en.adsre(att,dec,sust,rel,midigate);

// LFO
LFO = os.lf_triangle(lfoFreq)*modwheel*10;

// SYNTH ////////////////////////////////////////////////
synth = (oscillo(allfreq) :ve.moog_vcf(res,cutoff)) * volume;

//#################################################################################################//
//##################################### EFFECT SECTION ############################################//
//#################################################################################################//
//
// Simple FX chaine build for a mono synthesizer.
// It controle general volume and pan.
// FX Chaine is:
//		Drive
//		Flanger
//		Reverberation
//
// This version use ANALOG IN to controle some of the parameters.
// Other parameters continue to be available by MIDI or OSC.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_4	: Distortion Drive
// ANALOG_5	: Flanger Dry/Wet
// ANALOG_6	: Reverberation Dry/Wet
// ANALOG_7	: Reverberation Room size
//
// MIDI:
// CC 7		: Volume
// CC 10	: Pan
//
// CC 13	: Flanger Delay
// CC 13	: Flanger Delay
// CC 94	: Flanger Feedback
//
// CC 95	: Reverberation Damp
// CC 90	: Reverberation Stereo Width
// 
///////////////////////////////////////////////////////////////////////////////////////////////////

// VOLUME:
volFX = hslider("volume[midi:ctrl 7]",1,0,1,0.001);// Should be 7 according to MIDI CC norm.

// EFFECTS /////////////////////////////////////////////
drive = hslider("drive[BELA: ANALOG_4]",0.3,0,1,0.001);


// Flanger
curdel = hslider("flangDel[midi:ctrl 13]",4,0.001,10,0.001);
fb = hslider("flangFeedback[midi:ctrl 94]",0.7,0,1,0.001);
fldw = hslider("dryWetFlang[BELA: ANALOG_5]",0.5,0,1,0.001);
flanger = efx
	with {
		fldel = (curdel + (os.lf_triangle(1) * 2) ) : min(10);
		efx = _ <: _, pf.flanger_mono(10,fldel,1,fb,0) : dry_wet(fldw);
	};

// Pannoramique:
panno = _ : sp.panner(hslider("pan[midi:ctrl 10]",0.5,0,1,0.001)) : _,_;

// REVERB (from freeverb_demo)
reverb = _,_ <: (*(g)*fixedgain, *(g)*fixedgain :
	re.stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)),
	*(1-g), *(1-g) :> _,_
    with {
        scaleroom   = 0.28;
        offsetroom  = 0.7;
        allpassfeed = 0.5;
        scaledamp   = 0.4;
        fixedgain   = 0.1;
        origSR = 44100;

        damping = vslider("Damp[midi:ctrl 95]",0.5, 0, 1, 0.025)*scaledamp*origSR/ma.SR;
        combfeed = vslider("RoomSize[BELA: ANALOG_7]", 0.7, 0, 1, 0.025)*scaleroom*origSR/ma.SR + offsetroom;
        spatSpread = vslider("Stereo[midi:ctrl 90]",0.6,0,1,0.01)*46*ma.SR/origSR;
        g = vslider("dryWetReverb[BELA: ANALOG_6]", 0.4, 0, 1, 0.001);
        // (g = Dry/Wet)
    };

// Dry-Wet (from C. LEBRETON)
dry_wet(dw,x,y) = wet*y + dry*x
    with {
        wet = 0.5*(dw+1.0);
        dry = 1.0-wet;
    };

// ALL
effect = _ *(volFX) : ef.cubicnl_nodc(drive, 0.1) : flanger : panno : reverb;

// PROCESS /////////////////////////////////////////////
process = synth;

<!-- /faust-run -->


## simpleSynth_FX

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// A very simple subtractive synthesizer with 1 VCO 1 VCF.
// The VCO Waveform is variable between Saw and Square
// The frequency is modulated by an LFO
// The envelope control volum and filter frequency
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// MIDI IMPLEMENTATION:
//
// CC 70 : waveform (Saw to square)
// CC 71 : Filter resonance (Q)
// CC 74 : Filter Cutoff frequency
// CC 79 : Filter keyboard tracking (0 to X2, default 1)
// CC 75 : Filter Envelope Modulation
//
// Envelope
// CC 73 : Attack
// CC 76 : Decay
// CC 77 : Sustain
// CC 72 : Release
//
// CC 78 : LFO frequency (0.001Hz to 10Hz)
// CC 1	: LFO Amplitude (Modulation)
//
///////////////////////////////////////////////////////////////////////////////////////////////////
//
// HUI //////////////////////////////////////////////////
// Keyboard
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 0.5, 0, 0.5, 0.01);// MIDI KEYBOARD

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

// VCO
wfFade = hslider("waveform[midi:ctrl 70]",0.5,0,1,0.001):si.smoo;

// VCF
res = hslider("resonnance[midi:ctrl 71]",0.5,0,1,0.001):si.smoo;
fr = hslider("fc[midi:ctrl 74]", 15, 15, 12000, 0.001):si.smoo;
track = hslider("tracking[midi:ctrl 79]", 1, 0, 2, 0.001);
envMod = hslider("envMod[midi:ctrl 75]",50,0,100,0.01):si.smoo; 

// ENV
att	= 0.01 * (hslider("attack[midi:ctrl 73]",0.1,0.1,400,0.001));
dec	= 0.01 * (hslider("decay[midi:ctrl 76]",60,0.1,400,0.001));
sust = hslider("sustain[midi:ctrl 77]",0.1,0,1,0.001);
rel	= 0.01 * (hslider("release[midi:ctrl 72]",100,0.1,400,0.001));

// LFO
lfoFreq = hslider("lfoFreq[midi:ctrl 78]",6,0.001,10,0.001):si.smoo;
modwheel = hslider("modwheel[midi:ctrl 1]",0,0,0.5,0.001):si.smoo;

// PROCESS /////////////////////////////////////////////
allfreq = (midifreq * bend) + LFO;

// VCF
cutoff = ((allfreq * track) + fr + (envMod * midigain * env)) : min(ma.SR/8);

// VCO
oscillo(f) = (os.sawtooth(f)*(1-wfFade))+(os.square(f)*wfFade);

// VCA
volume = midigain * env;

// Enveloppe
env	= en.adsre(att,dec,sust,rel,midigate);

// LFO
LFO = os.lf_triangle(lfoFreq)*modwheel*10;

// SYNTH ////////////////////////////////////////////////
synth = (oscillo(allfreq) :ve.moog_vcf(res,cutoff)) * volume;

//#################################################################################################//
//##################################### EFFECT SECTION ############################################//
//#################################################################################################//
// Simple FX chaine build for a mono synthesizer.
// It controle general volume and pan.
// FX Chaine is:
//		Drive
//		Flanger
//		Reverberation
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// MIDI IMPLEMENTATION:
// (All are available by OSC)
//
// CC 7	: Volume
// CC 10 : Pan
//
// CC 92 : Distortion Drive
//
// CC 13 : Flanger Delay
// CC 93 : Flanger Dry/Wet
// CC 94 : Flanger Feedback
//
// CC 12 : Reverberation Room size
// CC 91 : Reverberation Dry/Wet
// CC 95 : Reverberation Damp
// CC 90 : Reverberation Stereo Width
//
///////////////////////////////////////////////////////////////////////////////////////////////////

// VOLUME:
volFX = hslider("volume[midi:ctrl 7]",1,0,1,0.001);// Should be 7 according to MIDI CC norm.

// EFFECTS /////////////////////////////////////////////
drive = hslider("drive[midi:ctrl 92]",0.3,0,1,0.001);

// Flanger
curdel = hslider("flangDel[midi:ctrl 13]",4,0.001,10,0.001);
fb = hslider("flangFeedback[midi:ctrl 94]",0.7,0,1,0.001);
fldw = hslider("dryWetFlang[midi:ctrl 93]",0.5,0,1,0.001);
flanger = efx
	with {
		fldel = (curdel + (os.lf_triangle(1) * 2) ) : min(10);
		efx = _ <: _, pf.flanger_mono(10,fldel,1,fb,0) : dry_wet(fldw);
	};

// Pannoramique:
panno = _ : sp.panner(hslider("pan[midi:ctrl 10]",0.5,0,1,0.001)) : _,_;

// REVERB (from freeverb_demo)
reverb = _,_ <: (*(g)*fixedgain,*(g)*fixedgain :
	re.stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)),
	*(1-g), *(1-g) :> _,_
    with {
        scaleroom   = 0.28;
        offsetroom  = 0.7;
        allpassfeed = 0.5;
        scaledamp   = 0.4;
        fixedgain   = 0.1;
        origSR = 44100;

        damping = vslider("Damp[midi:ctrl 95]",0.5, 0, 1, 0.025)*scaledamp*origSR/ma.SR;
        combfeed = vslider("RoomSize[midi:ctrl 12]", 0.7, 0, 1, 0.025)*scaleroom*origSR/ma.SR + offsetroom;
        spatSpread = vslider("Stereo[midi:ctrl 90]",0.6,0,1,0.01)*46*ma.SR/origSR;
        g = vslider("dryWetReverb[midi:ctrl 91]", 0.4, 0, 1, 0.001);
        // (g = Dry/Wet)
    };

// Dry-Wet (from C. LEBRETON)
dry_wet(dw,x,y) = wet*y + dry*x
    with {
        wet = 0.5*(dw+1.0);
        dry = 1.0-wet;
    };

// ALL
effect = _ *(volFX) : ef.cubicnl_nodc(drive, 0.1) : flanger : panno : reverb;

// PROCESS /////////////////////////////////////////////
process = synth;

<!-- /faust-run -->


## WaveSynth_Analog

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Simple demo of wavetable synthesis. A LFO modulate the interpolation between 4 tables.
// It's possible to add more tables step.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_0	: Wave travelling
// ANALOG_1	: LFO Frequency
// ANALOG_2	: LFO Depth (wave travel modulation)
// ANALOG_3	: Release
//
// MIDI:
// CC 73 : Attack
// CC 76 : Decay
// CC 77 : Sustain
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// GENERAL
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 0.5, 0, 1, 0.01);

waveTravel = hslider("waveTravel[BELA: ANALOG_0]",0,0,1,0.01);

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

gFreq = midifreq * bend;

// LFO
lfoDepth = hslider("lfoDepth[BELA: ANALOG_2]",0,0.,1,0.001):si.smoo;
lfoFreq = hslider("lfoFreq[BELA: ANALOG_1]",0.1,0.01,10,0.001):si.smoo;
moov = ((os.lf_trianglepos(lfoFreq) * lfoDepth) + waveTravel) : min(1) : max(0);

volA = hslider("A[midi:ctrl 73]",0.01,0.01,4,0.01);
volD = hslider("D[midi:ctrl 76]",0.6,0.01,8,0.01);
volS = hslider("S[midi:ctrl 77]",0.2,0,1,0.01);
volR = hslider("R[BELA: ANALOG_3]",0.8,0.01,8,0.01);
envelop = en.adsre(volA,volD,volS,volR,midigate);

// Out amplitude
vol = envelop * midigain;

WF(tablesize, rang) = abs((fmod((1+(float(ba.time)*rang)/float(tablesize)), 4.0))-2) -1.;

// 4 WF maxi with this version:
scanner(nb, position) = -(_,soustraction) : *(_,coef) : cos : max(0)
    with {
        coef = 3.14159 * ((nb-1)*0.5);
        soustraction = select2( position>0, 0, (position/(nb-1)) );
    };

wfosc(freq) = (rdtable(tablesize, wt1, faze)*(moov : scanner(4,0)))+(rdtable(tablesize, wt2, faze)*(moov : scanner(4,1)))
            + (rdtable(tablesize, wt3, faze)*(moov : scanner(4,2)))+(rdtable(tablesize, wt4, faze)*(moov : scanner(4,3)))
    with {
        tablesize = 1024;
        wt1 = WF(tablesize, 16);
        wt2 = WF(tablesize, 8);
        wt3 = WF(tablesize, 6);
        wt4 = WF(tablesize, 4);
        faze = int(os.phasor(tablesize,freq));
    };

process = wfosc(gFreq) * vol;


<!-- /faust-run -->


## WaveSynth

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Simple demo of wavetable synthesis. A LFO modulate the interpolation between 4 tables.
// It's possible to add more tables step.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// MIDI IMPLEMENTATION:
//
// CC 1 : LFO Depth (wave travel modulation)
// CC 14 : LFO Frequency
// CC 70 : Wave travelling
//
// CC 73 : Attack
// CC 76 : Decay
// CC 77 : Sustain
// CC 72 : Release
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// GENERAL
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 0.5, 0, 1, 0.01);

waveTravel = hslider("waveTravel [midi:ctrl]",0,0,1,0.01);

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

gFreq = midifreq * bend;

// LFO
lfoDepth = hslider("lfoDepth[midi:ctrl 1]",0,0.,1,0.001):si.smoo;
lfoFreq  = hslider("lfoFreq[midi:ctrl 14]",0.1,0.01,10,0.001):si.smoo;
moov = ((os.lf_trianglepos(lfoFreq) * lfoDepth) + waveTravel) : min(1) : max(0);

volA = hslider("A[midi:ctrl 73]",0.01,0.01,4,0.01);
volD = hslider("D[midi:ctrl 76]",0.6,0.01,8,0.01);
volS = hslider("S[midi:ctrl 77]",0.2,0,1,0.01);
volR = hslider("R[midi:ctrl 72]",0.8,0.01,8,0.01);
envelop = en.adsre(volA,volD,volS,volR,midigate);

// Out Amplitude
vol = envelop * midigain;

WF(tablesize, rang) = abs((fmod ((1+(float(ba.time)*rang)/float(tablesize)), 4.0))-2) -1.;

// 4 WF maxi with this version:
scanner(nb, position) = -(_,soustraction) : *(_,coef) : cos : max(0)
with{
	coef = 3.14159 * ((nb-1)*0.5);
	soustraction = select2( position>0, 0, (position/(nb-1)) );
};

wfosc(freq) = (rdtable(tablesize, wt1, faze)*(moov : scanner(4,0)))+(rdtable(tablesize, wt2, faze)*(moov : scanner(4,1)))
				+ (rdtable(tablesize, wt3, faze)*(moov : scanner(4,2)))+(rdtable(tablesize, wt4, faze)*(moov : scanner(4,3)))
with {
	tablesize = 1024;
	wt1 = WF(tablesize, 16);
	wt2 = WF(tablesize, 8);
	wt3 = WF(tablesize, 6);
	wt4 = WF(tablesize, 4);
	faze = int(os.phasor(tablesize,freq));
};

process = wfosc(gFreq) * vol;

<!-- /faust-run -->


## WaveSynth_FX_Analog

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Simple demo of wavetable synthesis. A LFO modulate the interpolation between 4 tables.
// It's possible to add more tables step.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_0	: Wave travelling
// ANALOG_1	: LFO Frequency
// ANALOG_2	: LFO Depth (wave travel modulation)
// ANALOG_3	: Release
//
// MIDI:
// CC 73	: Attack
// CC 76	: Decay
// CC 77	: Sustain
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// GENERAL
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 0.5, 0, 1, 0.01);

waveTravel = hslider("waveTravel[BELA: ANALOG_0]",0,0,1,0.01);

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

gFreq = midifreq * bend;

// LFO
lfoDepth = hslider("lfoDepth[BELA: ANALOG_2]",0,0.,1,0.001):si.smoo;
lfoFreq = hslider("lfoFreq[BELA: ANALOG_1]",0.1,0.01,10,0.001):si.smoo;
moov = ((os.lf_trianglepos(lfoFreq) * lfoDepth) + waveTravel) : min(1) : max(0);

volA = hslider("A[midi:ctrl 73]",0.01,0.01,4,0.01);
volD = hslider("D[midi:ctrl 76]",0.6,0.01,8,0.01);
volS = hslider("S[midi:ctrl 77]",0.2,0,1,0.01);
volR = hslider("R[BELA: ANALOG_3]",0.8,0.01,8,0.01);
envelop = en.adsre(volA,volD,volS,volR,midigate);

// Out amplitude
vol = envelop * midigain;

WF(tablesize, rang) = abs((fmod ((1+(float(ba.time)*rang)/float(tablesize)), 4.0 ))-2) -1.;

// 4 WF maxi with this version:
scanner(nb, position) = -(_,soustraction) : *(_,coef) : cos : max(0)
    with {
        coef = 3.14159 * ((nb-1)*0.5);
        soustraction = select2( position>0, 0, (position/(nb-1)) );
    };

wfosc(freq) = (rdtable(tablesize, wt1, faze)*(moov : scanner(4,0)))+(rdtable(tablesize, wt2, faze)*(moov : scanner(4,1)))
				+ (rdtable(tablesize, wt3, faze)*(moov : scanner(4,2)))+(rdtable(tablesize, wt4, faze)*(moov : scanner(4,3)))
    with {
        tablesize = 1024;
        wt1 = WF(tablesize, 16);
        wt2 = WF(tablesize, 8);
        wt3 = WF(tablesize, 6);
        wt4 = WF(tablesize, 4);
        faze = int(os.phasor(tablesize,freq));
    };

//#################################################################################################//
//##################################### EFFECT SECTION ############################################//
//#################################################################################################//
//
// Simple FX chaine build for a mono synthesizer.
// It control general volume and pan.
// FX Chaine is:
//		Drive
//		Flanger
//		Reverberation
//
// This version use ANALOG IN to controle some of the parameters.
// Other parameters continue to be available by MIDI or OSC.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// ANALOG IMPLEMENTATION:
//
// ANALOG_4	: Distortion Drive
// ANALOG_5	: Flanger Dry/Wet
// ANALOG_6	: Reverberation Dry/Wet
// ANALOG_7	: Reverberation Room size
//
// MIDI:
// CC 7	: Volume
// CC 10 : Pan
//
// CC 13 : Flanger Delay
// CC 13 : Flanger Delay
// CC 94 : Flanger Feedback
//
// CC 95 : Reverberation Damp
// CC 90 : Reverberation Stereo Width
// 
///////////////////////////////////////////////////////////////////////////////////////////////////

// VOLUME:
volFX = hslider("volume[midi:ctrl 7]",1,0,1,0.001);// Should be 7 according to MIDI CC norm.

// EFFECTS /////////////////////////////////////////////
drive = hslider("drive[BELA: ANALOG_4]",0.3,0,1,0.001);

// Flanger
curdel	= hslider("flangDel[midi:ctrl 13]",4,0.001,10,0.001);
fb = hslider("flangFeedback[midi:ctrl 94]",0.7,0,1,0.001);
fldw = hslider("dryWetFlang[BELA: ANALOG_5]",0.5,0,1,0.001);
flanger = efx
	with {
		fldel = (curdel + (os.lf_triangle(1) * 2) ) : min(10);
		efx = _ <: _, pf.flanger_mono(10,fldel,1,fb,0) : dry_wet(fldw);
	};

// Panoramic:
panno = _ : sp.panner(hslider("pan[midi:ctrl 10]",0.5,0,1,0.001)) : _,_;

// REVERB (from freeverb_demo)
reverb = _,_ <: (*(g)*fixedgain, *(g)*fixedgain :
	re.stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)),
	*(1-g), *(1-g) :> _,_
    with {
        scaleroom   = 0.28;
        offsetroom  = 0.7;
        allpassfeed = 0.5;
        scaledamp   = 0.4;
        fixedgain   = 0.1;
        origSR = 44100;

        damping = vslider("Damp[midi:ctrl 95]",0.5, 0, 1, 0.025)*scaledamp*origSR/ma.SR;
        combfeed = vslider("RoomSize[BELA: ANALOG_7]", 0.7, 0, 1, 0.025)*scaleroom*origSR/ma.SR + offsetroom;
        spatSpread = vslider("Stereo[midi:ctrl 90]",0.6,0,1,0.01)*46*ma.SR/origSR;
        g = vslider("dryWetReverb[BELA: ANALOG_6]", 0.4, 0, 1, 0.001);
        // (g = Dry/Wet)
    };

// Dry-Wet (from C. LEBRETON)
dry_wet(dw,x,y) = wet*y + dry*x
    with {
        wet = 0.5*(dw+1.0);
        dry = 1.0-wet;
    };

// ALL
effect = _ *(volFX) : ef.cubicnl_nodc(drive, 0.1) : flanger : panno : reverb;

process = wfosc(gFreq) * vol;

<!-- /faust-run -->


## WaveSynth_FX

<!-- faust-run -->

import("stdfaust.lib");

///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Simple demo of wavetable synthesis. A LFO modulate the interpolation between 4 tables.
// It's possible to add more tables step.
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// MIDI IMPLEMENTATION:
//
// CC 1     : LFO Depth (wave travel modulation)
// CC 14	: LFO Frequency
// CC 70	: Wave travelling
//
// CC 73	: Attack
// CC 76	: Decay
// CC 77	: Sustain
// CC 72	: Release
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// GENERAL
midigate = button("gate");
midifreq = nentry("freq[unit:Hz]", 440, 20, 20000, 1);
midigain = nentry("gain", 0.5, 0, 1, 0.01);

waveTravel = hslider("waveTravel [midi:ctrl ]",0,0,1,0.01);

// pitchwheel
bend = ba.semi2ratio(hslider("bend [midi:pitchwheel]",0,-2,2,0.01));

gFreq = midifreq * bend;

// LFO
lfoDepth = hslider("lfoDepth[midi:ctrl 1]",0,0.,1,0.001):si.smoo;
lfoFreq = hslider("lfoFreq[midi:ctrl 14]",0.1,0.01,10,0.001):si.smoo;
moov = ((os.lf_trianglepos(lfoFreq) * lfoDepth) + waveTravel) : min(1) : max(0);

volA = hslider("A[midi:ctrl 73]",0.01,0.01,4,0.01);
volD = hslider("D[midi:ctrl 76]",0.6,0.01,8,0.01);
volS = hslider("S[midi:ctrl 77]",0.2,0,1,0.01);
volR = hslider("R[midi:ctrl 72]",0.8,0.01,8,0.01);
envelop = en.adsre(volA,volD,volS,volR,midigate);

// Out Amplitude
vol = envelop * midigain;

WF(tablesize, rang) = abs((fmod ((1+(float(ba.time)*rang)/float(tablesize)), 4.0 ))-2) -1.;

// 4 WF maxi with this version:
scanner(nb, position) = -(_,soustraction) : *(_,coef) : cos : max(0)
    with {
        coef = 3.14159 * ((nb-1)*0.5);
        soustraction = select2(position>0, 0, (position/(nb-1)));
    };

wfosc(freq) = (rdtable(tablesize, wt1, faze)*(moov : scanner(4,0)))+(rdtable(tablesize, wt2, faze)*(moov : scanner(4,1)))
				+ (rdtable(tablesize, wt3, faze)*(moov : scanner(4,2)))+(rdtable(tablesize, wt4, faze)*(moov : scanner(4,3)))
    with {
        tablesize = 1024;
        wt1 = WF(tablesize, 16);
        wt2 = WF(tablesize, 8);
        wt3 = WF(tablesize, 6);
        wt4 = WF(tablesize, 4);
        faze = int(os.phasor(tablesize,freq));
    };

//#################################################################################################//
//##################################### EFFECT SECTION ############################################//
//#################################################################################################//
// Simple FX chaine build for a mono synthesizer.
// It control general volume and pan.
// FX Chaine is:
//		Drive
//		Flanger
//		Reverberation
//
///////////////////////////////////////////////////////////////////////////////////////////////////
// MIDI IMPLEMENTATION:
// (All are available by OSC)
//
// CC 7	: Volume
// CC 10 : Pan
//
// CC 92 : Distortion Drive
//
// CC 13 : Flanger Delay
// CC 93 : Flanger Dry/Wet
// CC 94 : Flanger Feedback
//
// CC 12 : Reverberation Room size
// CC 91 : Reverberation Dry/Wet
// CC 95 : Reverberation Damp
// CC 90 : Reverberation Stereo Width
//
///////////////////////////////////////////////////////////////////////////////////////////////////

// VOLUME:
volFX = hslider("volume[midi:ctrl 7]",1,0,1,0.001);// Should be 7 according to MIDI CC norm.

// EFFECTS /////////////////////////////////////////////
drive = hslider("drive[midi:ctrl 92]",0.3,0,1,0.001);

// Flanger
curdel = hslider("flangDel[midi:ctrl 13]",4,0.001,10,0.001);
fb = hslider("flangFeedback[midi:ctrl 94]",0.7,0,1,0.001);
fldw = hslider("dryWetFlang[midi:ctrl 93]",0.5,0,1,0.001);
flanger = efx
	with {
		fldel = (curdel + (os.lf_triangle(1) * 2) ) : min(10);
		efx = _ <: _, pf.flanger_mono(10,fldel,1,fb,0) : dry_wet(fldw);
	};

// Pannoramique:
panno = _ : sp.panner(hslider("pan[midi:ctrl 10]",0.5,0,1,0.001)) : _,_;

// REVERB (from freeverb_demo)
reverb = _,_ <: (*(g)*fixedgain, *(g)*fixedgain :
	re.stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)),
	*(1-g), *(1-g) :> _,_
    with {
        scaleroom   = 0.28;
        offsetroom  = 0.7;
        allpassfeed = 0.5;
        scaledamp   = 0.4;
        fixedgain   = 0.1;
        origSR = 44100;

        damping = vslider("Damp[midi:ctrl 95]",0.5, 0, 1, 0.025)*scaledamp*origSR/ma.SR;
        combfeed = vslider("RoomSize[midi:ctrl 12]", 0.7, 0, 1, 0.025)*scaleroom*origSR/ma.SR + offsetroom;
        spatSpread = vslider("Stereo[midi:ctrl 90]",0.6,0,1,0.01)*46*ma.SR/origSR;
        g = vslider("dryWetReverb[midi:ctrl 91]", 0.4, 0, 1, 0.001);
        // (g = Dry/Wet)
    };

// Dry-Wet (from C. LEBRETON)
dry_wet(dw,x,y) = wet*y + dry*x
    with {
        wet = 0.5*(dw+1.0);
        dry = 1.0-wet;
    };

// ALL
effect = _ *(volFX) : ef.cubicnl_nodc(drive, 0.1) : flanger : panno : reverb;

process = wfosc(gFreq) * vol;

<!-- /faust-run -->

