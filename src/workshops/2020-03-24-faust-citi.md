# Faust workshop at CITI

L'objectif de ce workshop est de se familiariser avec le langage Faust à travers des exemples simples de synthèse sonore. Tous les exemples seront executé dans l'IDE Faust en ligne [https://faustide.grame.fr](https://faustide.grame.fr). Si jamais les sons produits avec l'IDE sont de mauvaise qualité, avec des clics, on peut utiliser l'éditeur en ligne, plus rustique, mais aussi plus léger [https://fausteditor.grame.fr](https://fausteditor.grame.fr)

## Signal en dent de scie

Par convention, en Faust, un signal audio à pleine échelle varie entre -1 et +1. Mais dans un premier temps nous allons commencer par un signal en dent de scie entre 0 et 1 qui nous servira par la suite de _générateur de phase_ pour produire différentes formes d'onde.

### Générateur de Phase

La première étape consiste à construire un _générateur de phase_ qui produit un signal périodique en dents de scie entre 0 et 1. Voici le signal que nous voulons générer :

<img src="img/phase-sig.png" width="80%" class="mx-auto d-block">

### Rampe

Pour cela nous allons produire une rampe "infinie", que nous transformerons ensuite en un signal périodique grâce à une opération _partie-decimale_ :

<img src="img/ramp-sig.png" width="80%" class="mx-auto d-block">

La rampe est produite par le programme suivant :

<!-- faust-run -->
```
process = 0.125 : + ~ _;
```
<!-- /faust-run -->


### Sémantique

Dans l'exemple précédent, `0,125`, `+` et `_` sont des *primitives* du langage. Les deux autres signes : `:` et `~` sont des opérateurs de cablage. Ils sont utilisés pour relier entre elles les expressions du langage.

Pour comprendre le diagramme ci-dessus, nous allons l'annoter avec sa sémantique mathématique :

<img src="img/ramp-diag-math.svg" width="80%" class="mx-auto d-block">

Comme on peut le voir dans le diagramme, la formule du signal de sortie est : \(y(t) = y(t-1) + 0.125\)

On peut calculer les premières valeurs de \(y(t)\) :

- \(y(t<0)=0\)
- \(y(0) = y(-1) + 0.125 = 0.125\)
- \(y(1) = y(0) + 0.125 = 2*0.125 = 0.250\)
- \(y(2) = y(1) + 0.125 = 3*0.125 = 0.375\)
- ...
- \(y(6) = y(5) + 0.125 = 7*0.125 = 0.875\)
- \(y(7) = y(6) + 0.125 = 8*0.125 = 1.000\)
- \(y(8) = y(7) + 0.125 = 9*0.125 = 1.125\)
- ...

### Signal de phase

Comment transformer la rampe ci-dessus en signal en dents de scie ? En supprimant la partie entière des échantillons afin de ne garder que la partie décimale (fractionnaire) (`3.14159` -> `0.14159`).

Définissons une fonction pour faire cela :

```
decimalpart(x) = x - int(x);
```

Nous pouvons maintenant utiliser cette fonction pour transformer notre rampe en dents de scie. Il est alors tentant d'écrire :

```
process = 0.125 : + ~ _ : decimalpart;
```

D'un point de vue mathématique, ce serait parfaitement correct, mais nous allons accumuler les erreurs d'arrondi. Pour conserver une précision totale, il est préférable de placer l'opération de la partie décimale à l'intérieur de la boucle comme ceci :

```
process = 0.125 : (+ : decimalpart) ~ _;
```

On peut maintenant essayer l'ensemble du code (**pensez à baisser le volume**) :

<!-- faust-run -->
```
decimalpart(x) = x-int(x);
phase = 0.125 : (+ : decimalpart) ~ _;
process = phase;
```
<!-- /faust-run -->

Dans notre définition de la `phase`, la valeur du pas, ici `0,125`, contrôle la fréquence du signal généré. Nous aimerions calculer cette valeur de pas en fonction de la fréquence souhaitée. Afin de faire la conversion, nous devons connaître la fréquence d'échantillonnage. Elle est disponible dans la bibliothèque standard sous le nom de `ma.SR`. Pour utiliser cette bibliothèque standard nous ajoutons au programme la ligne suivante : `import("stdfaust.lib");`

Supposons que nous voulions que notre signal de phase ait une fréquence de 1 Hz, alors le pas devrait être très petit `1/ma.SR`, afin qu'il faille  `ma.SR` échantillons (c'est à dire 1 seconde) pour que le signal de phase passe de 0 à 1.

Si nous voulons une fréquence de 440 Hz, nous avons besoin d'un pas 440 fois plus grand pour que le signal de phase passe de 0 à 1 440 fois plus vite :

```
phase = 440/ma.SR : (+ : decimalpart) ~ _;
```

On peut généraliser cette définition en remplaçant `440` par un paramètre `f`:

```
phase(f) = f/ma.SR : (+ : decimalpart) ~ _;
```

et en passant la fréquence souhaitée à `phase`:

```
process = phase(440);
```

### Generateur de signal en dent de scie

Nous pouvons maintenant nous servir du générateur de phase pour produire un signal en dent de scie :


<!-- faust-run -->
```
import("stdfaust.lib");

decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _;

sawtooth(f) = phase(f) * 2 - 1;

process = sawtooth(440);
```
<!-- /faust-run -->

### Generateur de signal carré

Nous pouvons également nous servir du générateurr de phase pour produire un signal carré :


<!-- faust-run -->
```
import("stdfaust.lib");

decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _;

squarewave(f) = (phase(f) > 0.5) * 2 - 1;

process = squarewave(440);
```
<!-- /faust-run -->


## Synthèse additive

### Exemple 1 : générateur sinusoidal

Le générateur de phase est également à la base de l'oscillateur sinusoidal :


<!-- faust-run -->
```
import("stdfaust.lib");

decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _;

osc(f) = sin(phase(f) * 2 * ma.PI);

process = osc(440);
```
<!-- /faust-run -->


Mais maintenant que nous avons vu comment créer de toutes pièces un oscillateur sinusoidal, nous allons utiliser celui qui est défini dans la libraries standard de Faust :

<!-- faust-run -->
```
import("stdfaust.lib");

process = os.osc(440);
```
<!-- /faust-run -->

### Exemple 2 : une onde sinusoidale avec controle de volume

Dans ce deuxième exemple on a utilisé un slider horizontal `hslider(...)` pour régler le niveau sonore :

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



### Exemple 4 : Phénomène de repliement de fréquence au-delà de SR/2

Un problème bien connu dans le domaine de la synthèse numérique du son est celui du repliement de fréquence : toute fréquence au dela de la moitié de la fréquence d'échatillonnage se retrouve _repliée_ dans le spectre audible : 

<!-- faust-run -->
```
import("stdfaust.lib");

// A frequency aliasing phenomenon if one goes beyond SR/2

process = os.osc(hslider("freq", 440, 20, 20000, 1)) * hslider("gain", 0.1, 0, 1, 0.01);

```
<!-- /faust-run -->


### Exemple 5 : Synthèse additive

Un exemple de synthèse additive ou le niveau de chaque partiel peut être réglé individuellement : 
<!-- faust-run -->
```
import("stdfaust.lib");

//----------------------------------------------------------------------
// partial(f,n);
// f = fréquence en Hz
// n = numero du partiel en partant de 1
partial(n,f) = os.osc(f*n) * hslider("partial %n", 0.25, 0, 1, 0.01);

process = sum(i, 4, partial(i+1,hslider("freq", 440, 20, 8000, 0.001)));
```
<!-- /faust-run -->
 A noter l'utilisation de la construction `sum(i, n, foo(i))` qui est equivalente à `foo(0)+foo(1)+...+foo(n-1)`.


### Exemple 6 : Approximation d'un signal carré par synthèse additive
Nous avons vu précédemment comment produire une signal carré parfait. Ce signal carré parfait comporte une infinité d'harmoniques qui, du fait de l'échantillonnage, vont se replier sur le spectre audible, ce qui va donner un son bruité moins fidèle ! On peut approximer un signal carré par synthèse additive, en additionnant une serie infinie d'harmoniques impaires (voir [https://fr.wikipedia.org/wiki/Signal_carré](https://fr.wikipedia.org/wiki/Signal_carré)) :

<!-- faust-run -->
```
import("stdfaust.lib");

// Approximation of a square wave using additive synthesis

squarewave(f) = 4/ma.PI*sum(k, 4, os.osc((2*k+1)*f)/(2*k+1));

process = squarewave(55);
```
<!-- /faust-run -->
A titre d'excercice, faire varier le nombre d'harmoniques pour voir l'approximation s'améliorer (mais sans dépasser SR/2).


### Exemple 7 : Approximation d'un signal en dent de scie par synthèse additive

De même on peut approximer un signal en dent de scie par synthèse additive, en additionnant une serie infinie d'harmoniques (voir [https://fr.wikipedia.org/wiki/Signal_en_dents_de_scie](https://fr.wikipedia.org/wiki/Signal_en_dents_de_scie)) :

<!-- faust-run -->
```
import("stdfaust.lib");

// Approximation of a sawtooth wave using additive synthesis

sawtooth(f) = 2/ma.PI*sum(k, 4, (-1)^k * os.osc((k+1)*f)/(k+1));

process = sawtooth(55);
```
<!-- /faust-run -->


## Synthèse soustractive
La synthèse soustractive procède à l'inverse de la synthèse additive. Elle consiste à partir d'un son riche, par exemple un bruit blanc, et à sculpter son spectre.

### Exemple 1 : un bruit blanc

Un bruit blanc : 

<!-- faust-run -->
```
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01);
```
<!-- /faust-run -->

### Exemple 2 : lowpass


<!-- faust-run -->
```
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) : fi.lowpass(3, hslider("hifreq", 2000, 20, 20000, 1));

```
<!-- /faust-run -->

### Exemple 3 : high pass


<!-- faust-run -->
```
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) : fi.highpass(3, hslider("lowfreq", 400, 20, 20000, 1));

```
<!-- /faust-run -->

### Exemple 4 : bandpass


<!-- faust-run -->
```
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
: fi.highpass(3, hslider("lowfreq", 400, 20, 20000, 1))
: fi.lowpass(3, hslider("hifreq", 2000, 20, 20000, 1));

```
<!-- /faust-run -->

### Exemple 5 : resonnant


<!-- faust-run -->
```
import("stdfaust.lib");

process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
        : fi.resonlp(hslider("hifreq", 400, 20, 20000, 1),
                    hslider("Q", 1, 1, 100, 0.01),
                    hslider("gain", 1, 0, 2, 0.01));
```
<!-- /faust-run -->


### Exemple 6 : fir


<!-- faust-run -->
```
import("stdfaust.lib");

// FIR
process = no.noise * hslider("noise", 0.5, 0, 1, 0.01) 
        <: _,transformation :> _;

transformation = @(1) : *(hslider("gain", 0, -1, 1, 0.1));
```
<!-- /faust-run -->


### Exemple 7 : iir


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
