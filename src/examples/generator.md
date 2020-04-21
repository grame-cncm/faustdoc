# generator


## filterOsc

<!-- faust-run -->

declare name "filterOSC";
declare version "0.0";
declare author "JOS, revised by RM";
declare description "Simple application demoing filter based oscillators.";

import("stdfaust.lib");

process = dm.oscrs_demo;

<!-- /faust-run -->


## noise

<!-- faust-run -->

// WARNING: This a "legacy example based on a deprecated library". Check noises.lib
// for more accurate examples of noise functions

declare name 		"Noise";
declare version 	"1.1";
declare author 		"Grame";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2009";

//-----------------------------------------------------------------
// Noise generator and demo file for the Faust math documentation
//-----------------------------------------------------------------

<mdoc>
\section{Presentation of the "noise.dsp" Faust program}
This program describes a white noise generator with an interactive volume, using a random function.

\subsection{The random function}
The \texttt{random} function describes a generator of random numbers, which equation follows. You should notice hereby the use of an integer arithmetic on 32 bits, relying on integer wrapping for big numbers.
<equation>random</equation>

\subsection{The noise function}
The white noise then corresponds to:
<equation>noise</equation>
</mdoc>

random  = +(12345)~*(1103515245);
noise   = random/2147483647.0;

<mdoc>
\subsection{Just add a user interface element to play volume!}
Endly, the sound level of this program is controlled by a user slider, which gives the following equation: 
<equation>process</equation>
</mdoc>

<mdoc>
\section{Block-diagram schema of process}
This process is illustrated on figure 1.
<diagram>process</diagram>
</mdoc>

process = noise * vslider("Volume[style:knob][acc: 0 0 -10 0 10]", 0.5, 0, 1, 0.1);

<mdoc>
\section{Notice of this documentation}
You might be careful of certain information and naming conventions used in this documentation:
<notice/>

\section{Listing of the input code}
The following listing shows the input Faust code, parsed to compile this mathematical documentation.
<listing/>
</mdoc>

<!-- /faust-run -->


## noiseMetadata

<!-- faust-run -->

// WARNING: This a "legacy example based on a deprecated library". Check noises.lib
// for more accurate examples of noise functions

<mdoc>
\title{<metadata>name</metadata>}
\author{<metadata>author</metadata>}
\date{\today}
\maketitle

\begin{tabular}{ll}
	\hline
	\textbf{name}		& <metadata>name</metadata> \\
	\textbf{version} 	& <metadata>version</metadata> \\
	\textbf{author} 	& <metadata>author</metadata> \\
	\textbf{license} 	& <metadata>license</metadata> \\
	\textbf{copyright} 	& <metadata>copyright</metadata> \\
	\hline
\end{tabular}
\bigskip
</mdoc>
//-----------------------------------------------------------------
// Noise generator and demo file for the Faust math documentation
//-----------------------------------------------------------------

declare name 		"noiseMetadata"; // avoid same name as in noise.dsp
declare version 	"1.1";
declare author 		"Grame";
declare author 		"Yghe";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2009";

<mdoc>
\section{Presentation of the "noise.dsp" Faust program}
This program describes a white noise generator with an interactive volume, using a random function.

\subsection{The random function}
</mdoc>

random  = +(12345)~*(1103515245);

<mdoc>
The \texttt{random} function describes a generator of random numbers, which equation follows. You should notice hereby the use of an integer arithmetic on 32 bits, relying on integer wrapping for big numbers.
<equation>random</equation>

\subsection{The noise function}
</mdoc>

noise   = random/2147483647.0;

<mdoc>
The white noise then corresponds to:
<equation>noise</equation>

\subsection{Just add a user interface element to play volume!}
</mdoc>

process = noise * vslider("Volume[style:knob]", 0, 0, 1, 0.1);

<mdoc>
Endly, the sound level of this program is controlled by a user slider, which gives the following equation: 
<equation>process</equation>

\section{Block-diagram schema of process}
This process is illustrated on figure 1.
<diagram>process</diagram>

\section{Notice of this documentation}
You might be careful of certain information and naming conventions used in this documentation:
<notice />

\section{Listing of the input code}
The following listing shows the input Faust code, parsed to compile this mathematical documentation.
<listing mdoctags="false" dependencies="false" distributed="false" />
</mdoc>

<!-- /faust-run -->


## osc

<!-- faust-run -->

declare name 		"osc";
declare version 	"1.0";
declare author 		"Grame";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2009";

//-----------------------------------------------
// 			Sinusoidal Oscillator
//-----------------------------------------------

import("stdfaust.lib");

vol = hslider("volume [unit:dB]", 0, -96, 0, 0.1) : ba.db2linear : si.smoo;
freq = hslider("freq [unit:Hz]", 1000, 20, 24000, 1);

process = vgroup("Oscillator", os.osc(freq) * vol);


<!-- /faust-run -->


## osci

<!-- faust-run -->

declare name 		"osci";
declare version 	"1.0";
declare author 		"Grame";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2009";

//-----------------------------------------------
// 			Sinusoidal Oscillator
//		(with linear interpolation)
//-----------------------------------------------

import("stdfaust.lib");

vol = hslider("volume [unit:dB]", 0, -96, 0, 0.1) : ba.db2linear : si.smoo ;
freq = hslider("freq [unit:Hz]", 1000, 20, 24000, 1);

process = vgroup("Oscillator", os.osci(freq) * vol);

<!-- /faust-run -->


## sawtoothLab

<!-- faust-run -->

declare name "sawtoothLab";
declare version "0.0";
declare author "JOS, revised by RM";
declare description "An application demonstrating the different sawtooth oscillators of Faust.";

import("stdfaust.lib");

process = dm.sawtooth_demo;

<!-- /faust-run -->


## virtualAnalog

<!-- faust-run -->

declare name "VirtualAnalog";
declare version "0.0";
declare author "JOS, revised by RM";
declare description "Virtual analog oscillator demo application.";

import("stdfaust.lib");

process = dm.virtual_analog_oscillator_demo;

<!-- /faust-run -->


## virtualAnalogLab

<!-- faust-run -->

declare name "virtualAnalogLab";

import("stdfaust.lib");

process = 
 vgroup("[1]", dm.virtual_analog_oscillator_demo) : 
 vgroup("[2]", dm.moog_vcf_demo) : 
 vgroup("[3]", dm.spectral_level_demo)
 // See also: vgroup("[3]", dm.fft_spectral_level_demo(32))
  <: _,_;

<!-- /faust-run -->

