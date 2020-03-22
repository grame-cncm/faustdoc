# 2018 Programmable Audio Workshop PAW: Introduction to Faust

## Building a Simple MIDI Synthesizer

We are going to build a MIDI synthesizer from scratch (without using the Faust libraries).

### Phase Generator

The first step is to build a _phase generator_ that produces a periodic sawtooth signal between 0 and 1. Here is the signal we want to generate:

<img src="img/phase-sig.png" width="80%" class="mx-auto d-block">

#### Ramp

In order to produce the above signal we need first to produce a ramp signal
<img src="img/ramp-sig.png" width="80%" class="mx-auto d-block">

using the following Faust program:

<!-- faust-run -->
```
process = 0.125 : + ~ _;
```
<!-- /faust-run -->

You can think of a Faust program as a description of an audio circuit
where `0.125`, `+` and `_` are *primitives* of the language (predefined elementary audio components), and the other two signs: `:` and `~` are used to connect together these audio components.

#### Semantics

To understand the above diagram let's annotate it with its mathematical semantics.

<img src="img/ramp-diag-math.svg" width="80%" class="mx-auto d-block">

As we can see in the diagram, the formula of the output signal is: $y(t) = y(t-1) + 0.125$

We can compute the first values of $y(t)$:

- $y(t<0)=0$
- $y(0) = y(-1) + 0.125 = 0.125$
- $y(1) = y(0) + 0.125 = 2*0.125 = 0.250$
- $y(2) = y(1) + 0.125 = 3*0.125 = 0.375$
- ...
- $y(6) = y(5) + 0.125 = 7*0.125 = 0.875$
- $y(7) = y(6) + 0.125 = 8*0.125 = 1.000$
- $y(8) = y(7) + 0.125 = 9*0.125 = 1.125$
- ...

#### Phase Signal

How can we transform the above ramp into sawtooth signal ? By removing the integer part of the samples in order to keep only the decimal (fractional) part (`3.14159` -> `0.14159`).

Let's define a function to do that:

```
decimalpart(x) = x - int(x);
```

We can now use that function to transform our ramp into a sawtooth It is then tempting to write:

```
process = 0.125 : + ~ _ : decimalpart;
```

From a mathematical point of view that would be perfectly correct, but we will accumulate rounding errors. To keep full precision it is better to place the decimal part operation inside the loop:

```
process = 0.125 : (+ : decimalpart) ~ _ ;
```

We can now listen the produced signal. Just copy and past `decimalpart` and `process` definitions into the [Faust editor](https://faust.grame.fr/tools/editor)

### Controlling the Frequency of the Phase Signal

Let's first rearrange our code

<!-- faust-run -->
```
decimalpart(x) = x-int(x);
phase = 0.125 : (+ : decimalpart) ~ _ ;
process = phase;
```
<!-- /faust-run -->

In our `phase` definition the step value, here `0.125` controls the frequency of the generated signal. We would like to compute this step value according to the desired frequency. In order to do the conversion we need to know the sampling rate. It is available from the standard library as `ma.SR`. 

Let say we would like our phase signal to have a frequency of 1 Hz, then the step should be very small `1/ma.SR` so that is will take `ma.SR` samples (i.e. 1 second) for the phase signal to reach 1.

If we want a frequency of 440 Hz, we need a step 440 times bigger for the phase signal to reach 1 440 times faster. 

```
phase = 440/ma.SR : (+ : decimalpart) ~ _ ;
```

We can generalize this definition by replacing `440` by a parameter `f`:

```
phase(f) = f/ma.SR : (+ : decimalpart) ~ _ ;
```

and by indicating the desired frequency when we use `phase`:

```
process = phase(440);
```

### Creating a Sine Wave Oscillator

The next step is to transform above phase generator into a sine wave generator. We will use the `sin` primitive that computes the sine of x (measured in radians). Therefore we start for the phase signal, we multiply it by $2\pi$ to obtain radiants, and compute the sine. The full program is the following:

<!-- faust-run -->
```
import("stdfaust.lib");
decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _ ;
osc(f) = phase(f) * 2 * ma.PI : sin;
process = osc(440);
```
<!-- /faust-run -->

### Controlling the Frequency and Gain of the Oscillator

The next step is to add some controls on the frequency and gain of the oscillator. We can replace the fixed frequency `440` by a user interface slider:

```
process = osc(hslider("freq", 440, 20, 10000, 1));
```

and add a gain to control the output level of the oscillator:

```
process = osc(hslider("freq", 440, 20, 10000, 1)) * hslider("gain", 0.5, 0, 1, 0.01);
```

### Adding a Gate Button

In order to prepare our MIDI synthesizer we need to add a gate button so that the sound is only when we press it:

```
process = osc(hslider("freq", 440, 20, 10000, 1)) * hslider("gain", 0.5, 0, 1, 0.01) * button("gate");
```

### Adding an Envelope Generator

It is a good idea to also add an envelop generator. Here we will use a predefined adsr in the Standard Faust library.

<!-- faust-run -->
```
import("stdfaust.lib");
decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _ ;
osc(f) = phase(f) * 2 * ma.PI : sin;
process = osc(hslider("freq", 440, 20, 10000, 1)) 
        * hslider("gain", 0.5, 0, 1, 0.01) 
        * (button("gate") : en.adsr(0.1,0.1,0.98,0.1));
```
<!-- /faust-run -->

### Improving the Timbre

Instead of playing pure sine waves tones, let's improve the timbre with simple additive synthesis:

```
timbre(f) = osc(f)*0.5 + osc(f*2)*0.25 + osc(f*3)*0.125;
process = timbre(hslider("freq", 440, 20, 10000, 1)) 
        * hslider("gain", 0.5, 0, 1, 0.01) 
        * (button("gate") : en.adsr(0.1,0.1,0.98,0.1));
```

### Running as a Polyphonic MIDI Synth

To control the synthesizer using MIDI you need to use Chrome. The polyphonic MIDI mode is activated using the drop down menu.

<img src="img/poly-mode.png" width="80%" class="mx-auto d-block">

### Adding a Global Effect

A global effect can be added by providing a definition for `effect`.

```
// Common effect
effect = dm.zita_light;
```

<!-- faust-run -->
```
import("stdfaust.lib");
decimalpart(x) = x-int(x);
phase(f) = f/ma.SR : (+ : decimalpart) ~ _ ;
timbre(f) = phase(f)*0.5 + phase(f*2)*0.25 + phase(f*3)*0.125;

process = timbre(hslider("freq", 440, 20, 10000, 1)) 
* hslider("gain", 0.5, 0, 1, 0.01) 
* (button("gate") : en.adsr(0.1,0.1,0.98,0.1));

effect = dm.zita_light;
```
<!-- /faust-run -->

<img src="img/poly-effect.png" width="80%" class="mx-auto d-block">

