# Quick Start

The goal of this section is to teach you how to use the basic elements of the 
Faust programming language in approximately two hours! While DSP algorithms can 
be easily written from scratch in Faust, we'll just show you here how to use 
existing elements implemented in the [Faust libraries](../libraries), connect them to 
each other, and implement basic user interfaces (UI) to control them.

One of the strength of Faust lies in its libraries that implement hundreds of 
functions. So you should be able to go a long way after reading this section, 
simply by using what's already out here.

This tutorial was written assuming that the reader is already familiar with 
basic concepts of computer music and programming.

More generally, at the end of this section: 

* your Faust development environment should be up and running, <!-- TODO: true? -->
* you should know enough to write basic Faust programs,
* you should be able to use them on different platforms.

This tutorial was designed to be carried out in the 
[Faust online editor](../../tools/editor). If you wish to do it locally, you'll
have to [install Faust on your system](#compiling-and-installing-the-faust-compiler)
but this step is absolutely not required,

## Making Sound

Write the following code in the [Faust online editor](../../tools/editor):

<!-- faust-run -->
```
import("stdfaust.lib");
process = no.noise;
```
<!-- /faust-run -->

and then click on the "run" button on the top left corner. Alternatively, you
can also click on the "Try it Yourself" button of the window above if you're
reading the online version of this documentation. You should now hear white 
noise, of course... ;)

`stdfaust.lib` gives access to all the Faust libraries from a single point 
through a series of environments. For instance, we're using here the `no` 
environment which stands for `noise.lib` and the `noise` function (which is the 
standard white noise generator of Faust). The Faust 
[libraries documentation](../libraries/index.html#using-the-faust-libraries) 
provides more details about this system.

The most fundamental element of any Faust code is the `process` line, which 
gives access to the audio inputs and outputs of the target. This system is
completely dynamic and since `no.noise` has only one output and no input, the 
corresponding program will have a single output. 

Let's statically change the gain of the output of `no.noise` simply by 
multiplying it by a number between 0 and 1:

```
process = no.noise*0.5;
```

Thus, standard mathematical operations can be used in Faust just like in any 
other language. 

We'll now connect the noise generator to a resonant lowpass filter 
([`fi.resonlp`](../libraries/index.html#fi.resonlp)) by using the Faust 
[sequential composition operator](#sequential-composition): `:`

<!-- faust-run -->
```
import("stdfaust.lib");
ctFreq = 500;
q = 5;
gain = 1;
process = no.noise : fi.resonlp(ctFreq,q,gain);
```
<!-- /faust-run -->

[`fi.resonlp`](../libraries/index.html#fi.resonlp) has four arguments (in 
order): *cut-off frequency*, *q*, *gain* and its *input*. Here, we're setting 
the first three arguments with fixed variables. Variables don't have a type in 
Faust and everything is considered as a signal. The Faust compiler takes care 
of making the right optimizations by choosing which variable is ran at audio 
rate, what their types are, etc. Thus, `ctFreq`, `q` and `gain` could well be 
controlled by oscillators (i.e., signals running at audio rate) here. 

Since the input of the filter is not specified as an argument here (but it 
could, of course), it automatically becomes an "implicit" input/argument of 
`fi.resonlp`. The `:` [sequential composition operator](#sequential-composition) 
can be used to connect two elements that have the same number of outputs and 
inputs. Since `no.noise` has one output and `fi.resonlp(ctFreq,q,gain)` has one 
implicit input, we can connect them together. This is essentially the same as 
writing something like:

<!-- faust-run -->
```
import("stdfaust.lib");
ctFreq = 500;
q = 5;
gain = 1;
process = fi.resonlp(ctFreq,q,gain,no.noise);
```
<!-- /faust-run -->

While this would work, it's kind of ugly and not very "Faustian", so we don't do 
it... ;)

At this point, you should be able to use and plug various elements of the Faust 
libraries together. The Faust libraries implement hundreds of functions and 
some of them have a very specialized use. Fortunately, the Faust libraries 
documentation contains a section on 
[Standard Faust Libraries](../libraries/index.html#standard-functions-1) listing 
all the high level "standard" Faust functions organized by types. 
**We recommend you to have a look at it now**. As you do this, be aware that 
implicit signals in Faust can be explicitly represented with the `_` character. 
Thus, when you see something like this in the libraries documentation:

```
_ : aFunction(a,b) : _
```

it means that this function has one implicit input, one implicit output and two 
parameters (`a` and `b`). On the other hand:

```
anotherFunction(a,b,c) : _,_
```

is a function that has three parameters, no implicit input and two outputs.

Just for "fun," try to rewrite the previous example running in the Faust 
online editor so that the `process` line looks like this:

<!-- faust-run -->
```
import("stdfaust.lib");
ctFreq = 500;
q = 5;
gain = 1;
process = no.noise : _ : fi.resonlp(ctFreq,q,gain) : _;
```
<!-- /faust-run -->

Of course, this should not affect the result.

You probably noticed that we used the 
[`,` Faust composition operator to express two signals in parallel](#parallel-composition). 
We can easily turn our filtered noise example into a stereo object using it:

<!-- faust-run -->
```
import("stdfaust.lib");
ctFreq = 500;
q = 5;
gain = 1;
process = no.noise : _ <: fi.resonlp(ctFreq,q,gain),fi.resonlp(ctFreq,q,gain);
```
<!-- /faust-run -->

or we could even write this in a cleaner way:

<!-- faust-run -->
```
import("stdfaust.lib");
ctFreq = 500;
q = 5;
gain = 1;
filter = fi.resonlp(ctFreq,q,gain);
process = no.noise <: filter,filter;
```
<!-- /faust-run -->

> Note that this example allows us to have 2 separate filters for each channel.
Since both filters currently have the same parameters, another way of
writing this could be: `process = no.noise : filter <: _,_;`.

Since `filter,filter` is considered here as a full expression, we cannot use the 
`:` operator to connect `no.noise` to the two filters in parallel because 
`filter,filter` has two inputs (`_,_ : filter,filter : _,_`) and `no.noise` only 
has one output. 

The `<:` [split composition operator](#split-composition) used here takes `n` 
signals and splits them into `m` signals. The only rule is that `m` has to be a 
multiple of `n`.

The [merge `:>` composition operator](#merge-composition) can be used exactly 
the same way:

```
import("stdfaust.lib");
process = no.noise <: filter,filter :> _;
```

Here we split the signal of `no.noise` into two signals that are connected to 
two filters in parallel. Finally, we merge the outputs of the filters into one 
signal. Note, that the previous expression could have been written as such too:

```
import("stdfaust.lib");
process = no.noise <: filter+filter;
```

Keep in mind that splitting a signal doesn't mean that its energy get spread in 
each copy, for example, in the expression:

<!-- faust-run -->
```
process = 1 <: _,_;
```
<!-- /faust-run -->

the two `_` both contain 1...

All right, it's now time to add a basic user interface to our Faust program to 
make things a bit more interactive.

## Building a Simple User Interface

In this section, we'll add a simple user interface to the code that we wrote in 
the previous section:

<!-- faust-run -->
```
import("stdfaust.lib");
ctFreq = 500;
q = 5;
gain = 1;
process = no.noise : fi.resonlp(ctFreq,q,gain) ;
```
<!-- /faust-run -->

Faust allows us to declare basic 
[user interface (UI) elements](#user-interface-primitives-and-configuration) to 
control the parameters of a Faust object. Since Faust can be used to make a wide 
range of elements ranging from standalone applications to audio plug-ins or API, 
the role of UI declarations differs a little in function of the target. For 
example, in the Faust Online Editor, a UI is a window with various kind of 
controllers (sliders, buttons, etc.). On the other hand, if you're using Faust 
to generate an audio engine using [`faust2api`](#faust2api), then UI elements
declared in your Faust code will be the parameters visible to "the rest of the 
world" and controllable through the API.

An exhaustive list of the standard Faust UI elements is given in the 
[corresponding section](#user-interface-primitives-and-configuration). Be aware 
that they not all supported by all the Faust targets. For example, you wont be 
able to declare vertical sliders if you're using the 
[Faust Playground](../../tool/playground/index.html), etc. 

In the current case, we'd like to control the `ctFreq`, `q` and `gain` 
parameters of the previous program with horizontal sliders. To do this, we can 
write something like:

<!-- faust-run -->
```
import("stdfaust.lib");
ctFreq = hslider("cutoffFrequency",500,50,10000,0.01);
q = hslider("q",5,1,30,0.1);
gain = hslider("gain",1,0,1,0.01);
process = no.noise : fi.resonlp(ctFreq,q,gain);
```
<!-- /faust-run -->

The first argument of [`hslider`](#hslider-primitive) is the 
*name of the parameter* as it will be displayed in the interface or used in the 
API (it can be different from the name of the variable associated with the UI 
element), the next one is the *default value*, then the *min* and *max* values 
and finally the *step*. To summarize: `hslider("paramName",default,min,max,step)`.

Let's now add a "gate" [`button`](#button-primitive) to start and stop the sound 
(where `gate` is just the name of the button):

<!-- faust-run -->
```
import("stdfaust.lib");
ctFreq = hslider("[0]cutoffFrequency",500,50,10000,0.01);
q = hslider("[1]q",5,1,30,0.1);
gain = hslider("[2]gain",1,0,1,0.01);
t = button("[3]gate");
process = no.noise : fi.resonlp(ctFreq,q,gain)*t;
```
<!-- /faust-run -->

Note that we were able to 
[order parameters in the interface](#ordering-ui-elements) by numbering them in 
the parameter name field using squared brackets. 

Faust user interface elements run at control rate. Thus, 
you might have noticed that clicks are produced when moving sliders quickly. 
This problem can be easily solved by "smoothing" down the output of the sliders 
using the [`si.smoo`](../libraries/index.html#smoo) function:

<!-- faust-run -->
```
import("stdfaust.lib");
ctFreq = hslider("[0]cutoffFrequency",500,50,10000,0.01) : si.smoo;
q = hslider("[1]q",5,1,30,0.1) : si.smoo;
gain = hslider("[2]gain",1,0,1,0.01) : si.smoo;
t = button("[3]gate") : si.smoo;
process = no.noise : fi.resonlp(ctFreq,q,gain)*t;
```
<!-- /faust-run -->

Note that we're also using `si.smoo` on the output of the `gate` button to 
apply a exponential envelope on its signal. 

This is a very broad introduction to making user interface elements in Faust. 
You can do much more like creating groups, using knobs, different types of 
menus, etc. but at least you should be able to make Faust programs at this 
point that are controllable and sound good (or not ;) ).

## Final Polishing

Some Faust functions already contain a built-in UI and are ready-to-be-used. 
These functions are all placed in 
[demo.lib](../libraries/index.html#demo.lib) and are accessible through the 
`dm.` environment. 

As an example, let's add a reverb to our previous code by calling 
[`dm.zita_light`](../libraries/index.html#dm.zita_light) (high quality feedback 
delay network based reverb). Since this function has two implicit inputs, we 
also need to split the output of the filter (otherwise you will get an error 
because Faust wont know how to connect things):

<!-- faust-run -->
```
import("stdfaust.lib");
ctFreq = hslider("[0]cutoffFrequency",500,50,10000,0.01) : si.smoo;
q = hslider("[1]q",5,1,30,0.1) : si.smoo;
gain = hslider("[2]gain",1,0,1,0.01) : si.smoo;
t = button("[3]gate") : si.smoo;
process = no.noise : fi.resonlp(ctFreq,q,gain)*t <: dm.zita_light;
```
<!-- /faust-run -->

Hopefully, you should see many more UI elements in your interface. 

That's it folks! At this point you should be able to use 
[Faust standard functions](../libraries/index.html#standard-functions), connect 
them together and build a simple UI at the top of them.

## Some Project Ideas

In this section, we present a couple of project ideas that you could try to 
implement using 
[Faust standard functions](../libraries/index.html#standard-functions). Also, 
feel free to check the [`/examples` folder of the Faust repository](https://github.com/grame-cncm/faust/tree/master/examples).

### Additive Synthesizer

Make an additive synthesizer using [`os.osc`](../libraries/index.html#os.osc) 
(sine wave oscillator):

```
import("stdfaust.lib");
// freqs and gains definitions go here
process = 
	os.osc(freq0)*gain0,
	os.osc(freq2)*gain2 
	:> _ // merging signals here
	<: dm.zita_light; // and then splitting them for stereo in
```

### FM Synthesizer

Make a frequency modulation (FM) synthesizer using 
[`os.osc`](../libraries/index.html#os.osc) (sine wave oscillator):

```
import("stdfaust.lib");
// carrierFreq, modulatorFreq and index definitions go here
process = 
	os.osc(carrierFreq+os.osc(modulatorFreq)*index)
	<: dm.zita_light; // splitting signals for stereo in
```

### Guitar Effect Chain

Make a guitar effect chain:

<!-- faust-run -->
```
import("stdfaust.lib");
process = 
	dm.cubicnl_demo : // distortion 
	dm.wah4_demo <: // wah pedal
	dm.phaser2_demo : // stereo phaser 
	dm.compressor_demo : // stereo compressor
	dm.zita_light; // stereo reverb
```
<!-- /faust-run -->

Since we're only using functions from 
[`demo.lib`](../libraries/index.html#demo.lib) here, there's no need to define 
any UI since it is built-in in the functions that we're calling. Note that the 
mono output of `dm.wah4_demo` is split to fit the stereo input of 
`dm.phaser2_demo`. The last three effects have the same number of inputs and 
outputs (2x2) so no need to split or merge them.

### String Physical Model Based On a Comb Filter

Make a string physical model based on a feedback comb filter:

```
import("stdfaust.lib");
// freq, res and gate definitions go here
string(frequency,resonance,trigger) = trigger : ba.impulsify : fi.fb_fcomb(1024,del,1,resonance)
with {
	del = ma.SR/frequency;
};
process = string(freq,res,gate);
```

Sampling rate is defined in [`maths.lib`](../libraries/index.html#maths.lib) as 
[`SR`](../libraries/index.html#ma.sr). We're using it here to compute the 
length of the delay of the comb filter. [`with{}`](#with-expression) is a Faust 
primitive to attach local variables to a function. So in the current case, 
`del` is a local variable of `string`.

## What to Do From Here?

TODO.
