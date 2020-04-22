# Making a Sine Oscillator From Scratch and Additive Synthesis

## Goals

* Implementing a sine oscillator from scratch in Faust
* Understand the relation between the sine function and the generated sound
* Use multiple sine oscillator to implement an additive synthesizer
* Use [SmartKeyboard](https://github.com/grame-cncm/faust/tree/master-dev/architecture/smartKeyboard) to produce polyphonic mobile apps to control this synth

## Sine Function in Faust

* The sine function in Faust works like on a calculator:

<!-- faust-run -->
<div class="faust-run"><img src="exfaust0/exfaust0.svg" class="mx-auto d-block">
~~~

process = sin(0);

~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust0/exfaust0.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

will output 0.

> To verify this, you could click on the truck (export function) in the [Faust Online IDE](https://faustide.grame.fr) and then choose `misc/csv` to get a table containing the first *n* samples output by the program.

<!-- faust-run -->
<div class="faust-run"><img src="exfaust1/exfaust1.svg" class="mx-auto d-block">
~~~

import("stdfaust.lib");
process = sin(ma.PI);

~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust1/exfaust1.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

will output `1`.

> Note that `stdfaust.lib` is imported here in order to use `ma.pi`. 

<!-- faust-run -->
<div class="faust-run"><img src="exfaust2/exfaust2.svg" class="mx-auto d-block">
~~~

import("stdfaust.lib");
process = sin(2*ma.PI);

~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust2/exfaust2.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

will output `0`.

<!-- May be give a few more example with 3pi, 4pi, etc. -->

## Implementing a Phasor

* What is needed to "print" a full sine wave? 
    * -> We need to create a series of numbers (vector) going from 0 to 2pi, in other words, draw a line.
* First let's create a "counter" in Faust:

<!-- faust-run -->
<div class="faust-run"><img src="exfaust3/exfaust3.svg" class="mx-auto d-block">
~~~

process = +(1)~_;
 
~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust3/exfaust3.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

> Don't forget that you can always print the output of a Faust program by using the in the [Faust Online IDE](https://faustide.grame.fr) `misc/csv`

* The current counter counts one by one. Instead we'd like to count slower 0.01
by 0.01.


<!-- faust-run -->
<div class="faust-run"><img src="exfaust4/exfaust4.svg" class="mx-auto d-block">
~~~

process = +(0.01)~_;


~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust4/exfaust4.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

* Now, we want to reset the counter back to 0 when it reaches 1. This can be
done easily using the `ma.decimal` function:

<!-- faust-run -->
<div class="faust-run"><img src="exfaust5/exfaust5.svg" class="mx-auto d-block">
~~~

import("stdfaust.lib");
process = +(0.01) ~ ma.decimal;

~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust5/exfaust5.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

> Note the use of `ma.decimal` in the loop here to prevent numerical errors.

* Try to run the program (play button in the editor) and it should make sound! What are we generating here?
    * -> A [sawtooth wave](https://en.wikipedia.org/wiki/Sawtooth_wave). 
* How do we change the pitch of the sawtooth wave? -
    * > We should increment the counter faster or slower. Try different values (e.g., 0.001, 0.1, etc.).

* Instead of controlling the increment of the counter, we'd like to control the
frequency of the sawtooth wave.  <!-- What's a frequency? Show how it impacts the generated wave.-->
* To do that, we need to know the number of values of the wave processed by the
computer in one second. That's what we call the [sampling rate](https://en.wikipedia.org/wiki/Sampling_(signal_processing)). <!-- INSIST ON WHAT IT IS.--> This value changes in function of the context of the program so it can be retrieved with `ma.SR`. 
* A sampling rate of 44100 corresponds to a frequency of 44100Hz. If we want a
frequency of 440, what increment do we need to put in our counter?
    * -> `freq/ma.SR`
* In the end, we get:

<!-- faust-run -->
<div class="faust-run"><img src="exfaust6/exfaust6.svg" class="mx-auto d-block">
~~~

import("stdfaust.lib");
freq = 440;
process = (+(freq/ma.SR) ~ ma.decimal);

~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust6/exfaust6.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

* A this point feel free to plot the output of the Faust program using `misc/csv` in the export function of the online editor.
* The `freq` parameter can be controlled dynamically:

<!-- faust-run -->
<div class="faust-run"><img src="exfaust7/exfaust7.svg" class="mx-auto d-block">
~~~

import("stdfaust.lib");
freq = hslider("freq",440,50,2000,0.01);
process = (+(freq/ma.SR) ~ ma.decimal);

~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust7/exfaust7.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

* The code can be cleaned up by placing our phasor in a function:

<!-- faust-run -->
<div class="faust-run"><img src="exfaust8/exfaust8.svg" class="mx-auto d-block">
~~~

import("stdfaust.lib");
f = hslider("freq",440,50,2000,0.01);
phasor(freq) = (+(freq/ma.SR) ~ ma.decimal);
process = phasor(f);

~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust8/exfaust8.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

## Generating a Sine Wave

* Almost there! Now we want our phasor to go from 0 to 2pi so that we can plug
it to the `sin` function:

<!-- faust-run -->
<div class="faust-run"><img src="exfaust9/exfaust9.svg" class="mx-auto d-block">
~~~

import("stdfaust.lib");
f = hslider("freq",440,50,2000,0.01);
phasor(freq) = (+(freq/ma.SR) ~ ma.decimal);
osc(freq) = sin(phasor(freq)*2*ma.PI);
process = osc(f);

~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust9/exfaust9.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

> Note that we created an `osc` function in order to have a cleaner code.

## Additive Synthesis

* A sine wave generates what we call a [pure tone](https://en.wikipedia.org/wiki/Pure_tone). More complex sounds can be produced by adding multiple sine waves together to create [harmonics](https://en.wikipedia.org/wiki/Harmonic). The frequency and the gain of each harmonic will determine the [timbre of the sound](https://en.wikipedia.org/wiki/Timbre). Using this technique, it is possible to "sculpt" a sound.
* A simple organ synthesizer can be implemented using additive synthesis:

<!-- faust-run -->
<div class="faust-run"><img src="exfaust10/exfaust10.svg" class="mx-auto d-block">
~~~

import("stdfaust.lib");
f = hslider("freq",440,50,2000,0.01);
phasor(freq) = (+(freq/ma.SR) ~ ma.decimal);
osc(freq) = sin(phasor(freq)*2*ma.PI);
organ(freq) = (osc(freq) + osc(freq*2) + osc(freq*3))/3;
process = organ(f)/3;
 
~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust10/exfaust10.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

* This is what we call a [harmonic series](https://en.wikipedia.org/wiki/Harmonic_series_(mathematics)).

## Making a Synthesizer

* In order to use this synthesizer with a keyboard, we need to be able to turn the sound on and off and also to control its volume:

<!-- faust-run -->
<div class="faust-run"><img src="exfaust11/exfaust11.svg" class="mx-auto d-block">
~~~

import("stdfaust.lib");
f = hslider("freq",440,50,2000,0.01);
g = hslider("gain",1,0,1,0.01);
t = button("gate");
phasor(freq) = (+(freq/ma.SR) ~ ma.decimal);
osc(freq) = sin(phasor(freq)*2*ma.PI);
organ(freq) = (osc(freq) + osc(freq*2) + osc(freq*3))/3;
process = organ(f)*g*t/3;

~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust11/exfaust11.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

* An envelope could be added to make it sound more natural:

<!-- faust-run -->
<div class="faust-run"><img src="exfaust12/exfaust12.svg" class="mx-auto d-block">
~~~

import("stdfaust.lib");
f = hslider("freq",440,50,2000,0.01);
g = hslider("gain",1,0,1,0.01);
t = si.smoo(button("gate"));
phasor(freq) = (+(freq/ma.SR) ~ ma.decimal);
osc(freq) = sin(phasor(freq)*2*ma.PI);
organ(freq) = (osc(freq) + osc(freq*2) + osc(freq*3))/3;
process = organ(f)*g*t/3;

~~~

<a href="https://faustide.grame.fr/?code=https://faustdoc.grame.fr/tutorials/basic-osc/exfaust12/exfaust12.dsp" target="editor">
<button type="button" class="btn btn-primary">Try it Yourself >></button></a>
</div>
<!-- /faust-run -->

* This synth can be controlled with a midi keyboard.

## Turn it Into an Android App

* Use the export function of the Faust editor and choose `android/smartkeyb` install the app on the phone and have fun!
* This could also be turned into an app always making sound and controllable with accelerometers:

```
import("stdfaust.lib");
f = hslider("freq[acc: 0 0 -10 0 10]",1000,50,2000,0.01) : si.smoo;
phasor(freq) = (+(freq/ma.SR) ~ ma.decimal);
osc(freq) = sin(phasor(freq)*2*ma.PI);
organ(freq) = (osc(freq) + osc(freq*2) + osc(freq*3))/3;
process = organ(f)/3;
```

* In that case, export with `android/android`.
