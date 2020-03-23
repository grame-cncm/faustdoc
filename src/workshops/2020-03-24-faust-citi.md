# Faust workshop at CITI

L'objectif de ce workshop est de se familiariser avec le langage Faust à travers des exemples simples de synthèse sonore. Pour cela on va utiliser Faust pour décrire des _circuits audio_ qui produisent des sons suivant différentes méthodes. 

Tous les exemples seront executé dans l'IDE Faust en ligne [https://faustide.grame.fr](https://faustide.grame.fr)

## Synthèse additive

### Exemple 1 : une onde sinusoidale

Commençons par une simple onde sinusoidale. Attention à mettre le volume bas !

<!-- faust-run -->
```
import("stdfaust.lib");

process = os.osc(440);
```
<!-- /faust-run -->

### Exemple 2 : une onde sinusoidale avec controle de volume

Dans ce deuxième exemple on a utilisé un slider horizontal `hslider(...)` pour régler le niveau sonore. 

<!-- faust-run -->
```
import("stdfaust.lib");

process = os.osc(440) * hslider("gain", 0.1, 0, 1, 0.01);
```
<!-- /faust-run -->

Le premier paramètre est une chaine de caractère qui indique le nom du slider. Il est suivi de quatre paramètres numériques. Le deuxième paramètre `0.1` indique la valeur par défaut du slider, c'est à dire la valeur que va délivrer le slider quand on lance le programme. Ensuite nous avons la valeur minimale `0`, la valeur maximale `1` et le pas de variation `0.01`.

### Exemple 3 : Exercice, ajouter un contrôle de fréquence

A titre d'exercice, remplacer, dans l'exemple précédent, la fréquence 440 par un slider horizontal dont le nom sera `"freq"`, la valeur par défaut `110`, la valeur minimale `40`, la valeur maximale `8000` et le pas `1`.
<!-- faust-run -->
```
import("stdfaust.lib");

process = os.osc(440 /*a remplacer*/) * hslider("gain", 0.1, 0, 1, 0.01);
```
<!-- /faust-run -->

### Exemple 4 : Synthese additive

Un exemple de synthèse additive ou le niveau de chaque partiel peut être réglé individuellement. 
<!-- faust-run -->
```
import("stdfaust.lib");

//----------------------------------------------------------------------
// partial(f,n);
// f = fréquence en Hz
// n = numero du partiel en partant de 1
partial(n,f) = os.osc(f*n) * hslider("partial %n", 0.25, 0, 1, 0.01);

process 	= sum(i, 4, partial(i+1,hslider("freq", 440, 20, 8000, 0.001)));
```
<!-- /faust-run -->
 A noter l'utilisation de la construction `sum(i, n, foo(i))` qui est equivalente à `foo(0)+foo(1)+...+foo(n-1)`.


### Exemple 5 : Approximation d'un signal carré par synthèse additive
[wikipedia](https://fr.wikipedia.org/wiki/Signal_carré)
Blabla
<!-- faust-run -->
```
import("stdfaust.lib");

// Approximation of a square wave using additive synthesis

squarewave(f) = 4/ma.PI*sum(k, 8, os.osc((2*k+1)*f)/(2*k+1));

process = squarewave(55);
```
<!-- /faust-run -->
Blabla


### Exemple 6 : Approximation d'un signal en dent de scie par synthèse additive

Blabla
<!-- faust-run -->
```
import("stdfaust.lib");

// Approximation of a sawtooth wave using additive synthesis

sawtooth(f) = 2/ma.PI*sum(k, 8, (-1)^k * os.osc((k+1)*f)/(k+1));

process = sawtooth(55);
```
<!-- /faust-run -->
Blabla


### Exemple 7 : Phénomène de repliement de fréquence si l'on va au-delà de SR/2

Blabla
<!-- faust-run -->
```
import("stdfaust.lib");

// Phénomène de repliement de fréquence si l'on va au-delà de SR/2

process = os.osc(hslider("freq", 440, 20, 20000, 1));

```
<!-- /faust-run -->
Blabla


### Exemple 8 : Mathematical square wave doesn't sound great because of aliasing

Blabla
<!-- faust-run -->
```
import("stdfaust.lib");

// Mathematical square wave doesn't sound great because of aliasing
phasor(f) = f/ma.SR : (+,1:fmod)~_;
exactsquarewave(f) = (os.phasor(1,f)>0.5)*2.0-1.0;
process = exactsquarewave(hslider("freq", 440, 20, 8000, 1))*hslider("gain", 0.5, 0, 1, 0.01);
```
<!-- /faust-run -->
Blabla


### Exemple 9 : Virtual Analog square wave with less aliasing

Blabla
<!-- faust-run -->
```
import("stdfaust.lib");

// Virtual Analog square wave with less aliasing

process = os.squareN(3,hslider("freq", 220, 20, 8000, 1))*hslider("gain", 0.5, 0, 1, 0.01);
```
<!-- /faust-run -->
Blabla



## Synthèse soustractive

### Exemple 1 : un bruit blanc

Commençons par une simple onde sinusoidale. Attention à mettre le volume bas !

<!-- faust-run -->
```
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01);
```
<!-- /faust-run -->

### Exemple 2 : lowpass

Commençons par une simple onde sinusoidale. Attention à mettre le volume bas !

<!-- faust-run -->
```
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) : fi.lowpass(3, hslider("hifreq", 2000, 20, 20000, 1));

```
<!-- /faust-run -->

### Exemple 3 : high pass

Commençons par une simple onde sinusoidale. Attention à mettre le volume bas !

<!-- faust-run -->
```
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) : fi.highpass(3, hslider("lowfreq", 400, 20, 20000, 1));

```
<!-- /faust-run -->

### Exemple 4 : bandpass

Commençons par une simple onde sinusoidale. Attention à mettre le volume bas !

<!-- faust-run -->
```
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
: fi.highpass(3, hslider("lowfreq", 400, 20, 20000, 1))
: fi.lowpass(3, hslider("hifreq", 2000, 20, 20000, 1));

```
<!-- /faust-run -->

### Exemple 5 : resonnant

Commençons par une simple onde sinusoidale. Attention à mettre le volume bas !

<!-- faust-run -->
```
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
        : fi.resonlp(
                hslider("hifreq", 400, 20, 20000, 1),
                hslider("Q", 1, 1, 100, 0.01),
                hslider("gain", 1, 0, 2, 0.01));
```
<!-- /faust-run -->


### Exemple 6 : fir

bla bla
<!-- faust-run -->
```
import("stdfaust.lib");

// FIR
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
        <: _ , transformation :> _;

transformation = @(1) : *(hslider("gain", 0, -1, 1, 0.1));
```
<!-- /faust-run -->


### Exemple 7 : iir

bla bla
<!-- faust-run -->
```
import("stdfaust.lib");

// IIR
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) :
        + ~ transformation;
        
transformation = @(0) : *(hslider("gain", 0, -0.95, 0.95, 0.01));
```
<!-- /faust-run -->


### Exemple 8 : filtre en peigne

bla bla
<!-- faust-run -->
```
import("stdfaust.lib");

// IIR, Filtre en peigne
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) :
        + ~ transformation;
        
transformation = @(hslider("delay", 0, 0, 20, 1)) : *(hslider("gain", 0, -0.98, 0.98, 0.01));
```
<!-- /faust-run -->


### Exemple 9 : Karplus Strong (1/2)

bla bla
<!-- faust-run -->
```
import("stdfaust.lib");

// Karplus Strong (1/2)
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) :
        + ~ transformation;
        
transformation = @(hslider("delay", 0, 0, 200, 1)) : moyenne : *(hslider("gain", 0, -0.98, 0.98, 0.01));

moyenne(x) = (x+x')/2;
```
<!-- /faust-run -->


### Exemple 10 : Karplus Strong (2/2)

bla bla
<!-- faust-run -->
```
import("stdfaust.lib");

// Karplus Strong (2/2)
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
        : *(envelop)
        : + ~ transformation;
        
transformation = @(hslider("delay", 0, 0, 200, 1)) : moyenne : *(hslider("gain", 0, -0.999, 0.999, 0.001));

moyenne(x) = (x+x')/2;

envelop = button("gate") : upfront : en.ar(0.002, 0.01);

upfront(x) = x>x';

```
<!-- /faust-run -->


### Exemple 11 : Kisana

bla bla
<!-- faust-run -->
```
declare name  	"myKisana";
declare author  "Yann Orlarey";

//Modifications GRAME July 2015

/* ========= DESCRITPION =============

- Kisana : 3-loops string instrument (based on Karplus-Strong)
- Head = Silence
- Tilt = High frequencies 
- Front = High + Medium frequencies
- Bottom = High + Medium + Low frequencies
- Left = Minimum brightness
- Right = Maximum birghtness
- Front = Long notes
- Back = Short notes

*/

import("stdfaust.lib");

KEY = 60;	// basic midi key
NCY = 15; 	// note cycle length
CCY = 15;	// control cycle length
BPS = 360;	// general tempo (ba.beat per sec)

process = kisana;    

//-------------------------------kisana----------------------------------
// USAGE:  kisana : _,_;
// 		3-loops string instrument
//-----------------------------------------------------------------------

kisana = vgroup("MyKisana", harpe(C,11,48), harpe(C,11,60), (harpe(C,11,72) : *(1.5), *(1.5)) 
	:> *(l), *(l))
	with {
		l = -20 : ba.db2linear;//hslider("[1]Volume",-20, -60, 0, 0.01) : ba.db2linear;
		C = hslider("[2]Brightness[acc:0 1 -10 0 10]", 0.2, 0, 1, 0.01) : ba.automat(BPS, CCY, 0.0);
	};

//----------------------------------Harpe--------------------------------
// USAGE:  harpe(C,10,60) : _,_;
//		C is the filter coefficient 0..1
// 		Build a N (10) strings harpe using a pentatonic scale 
//		based on midi key b (60)
//		Each string is triggered by a specific
//		position of the "hand"
//-----------------------------------------------------------------------
harpe(C,N,b) = 	hand(b) <: par(i, N, position(i+1)
							: string(C,Penta(b).degree2Hz(i), att, lvl)
							: pan((i+0.5)/N) )
				 	:> _,_
	with {
		att  = hslider("[3]Resonance[acc:2 1 -10 0 12]", 4, 0.1, 10, 0.01); 
		hand(48) = vslider("h:[1]Instrument Hands/1 (Note %b)[unit:pk]", 0, 0, N, 1) : int : ba.automat(120, CCY, 0.0);
		hand(60) = vslider("h:[1]Instrument Hands/2 (Note %b)[unit:pk]", 2, 0, N, 1) : int : ba.automat(240, CCY, 0.0);
		hand(72) = vslider("h:[1]Instrument Hands/3 (Note %b)[unit:pk]", 4, 0, N, 1) : int : ba.automat(480, CCY, 0.0);
		//lvl  = vslider("h:loop/level", 0, 0, 6, 1) : int : ba.automat(BPS, CCY, 0.0) : -(6) : ba.db2linear; 
		lvl = 1;
		pan(p) = _ <: *(sqrt(1-p)), *(sqrt(p));
		position(a,x) = abs(x - a) < 0.5;
	};

//----------------------------------Penta-------------------------------
// Pentatonic scale with degree to midi and degree to Hz conversion
// USAGE: Penta(60).degree2midi(3) ==> 67 midikey
//        Penta(60).degree2Hz(4)   ==> 440 Hz
//-----------------------------------------------------------------------

Penta(key) = environment {

	A4Hz = 440; 
	
	degree2midi(0) = key+0;
	degree2midi(1) = key+2;
	degree2midi(2) = key+4;
	degree2midi(3) = key+7;
	degree2midi(4) = key+9;
	degree2midi(d) = degree2midi(d-5)+12;
	
	degree2Hz(d) = A4Hz*semiton(degree2midi(d)-69) with { semiton(n) = 2.0^(n/12.0); };

}; 
 
//----------------------------------String-------------------------------
// A karplus-strong string.
//
// USAGE: string(440Hz, 4s, 1.0, button("play"))
// or	  button("play") : string(440Hz, 4s, 1.0)
//-----------------------------------------------------------------------

string(coef, freq, t60, level, trig) = no.noise*level
							: *(trig : trigger(freq2samples(freq)))
							: resonator(freq2samples(freq), att)
	with {
		resonator(d,a)	= (+ : @(d-1)) ~ (average : *(a));
		average(x)		= (x*(1+coef)+x'*(1-coef))/2;
		trigger(n) 		= upfront : + ~ decay(n) : >(0.0);
		upfront(x) 		= (x-x') > 0.0;
		decay(n,x)		= x - (x>0.0)/n;
		freq2samples(f) = 44100.0/f;
		att 			= pow(0.001,1.0/(freq*t60)); // attenuation coefficient
		random  		= +(12345)~*(1103515245);
		noise   		= random/2147483647.0;
	};

```
<!-- /faust-run -->

## Synthèse par modulation de fréquence

### Exemple 1 : fm1

Bla bla

<!-- faust-run -->
```
import("stdfaust.lib");

// FM: Frequency moulation

FM(fc,fm,amp) = fm : os.osc : *(amp) : +(1) : *(fc) : os.osc;

process = FM( 
            hslider("freq carrier", 880, 40, 8000, 1),
            hslider("freq modulation", 200, 10, 1000, 1),
            hslider("amp modulation", 0, 0, 1, 0.01)
            ) 
        <: _,_;

```
<!-- /faust-run -->


### Exemple 2 : fm2

Bla bla

<!-- faust-run -->
```
import("stdfaust.lib");

// FM: Frequency moulation 2

FM(fc,fm,amp) = fm : os.osc : *(amp) : +(1) : *(fc) : os.osc;

process = FM( 
            hslider("freq carrier", 880, 40, 8000, 1),
            hslider("freq modulation", 200, 10, 1000, 1)*(2+envelop2)/3,
            hslider("amp modulation", 0, 0, 1, 0.01)*(0.5+envelop2)/1.5
            ) 
        : *(envelop1)
        <: dm.freeverb_demo;

envelop1 = button("gate") : upfront : en.ar(0.001, 1);
envelop2 = button("gate") : upfront : en.ar(0.5, 0.5);

upfront(x) = x>x';

```
<!-- /faust-run -->
