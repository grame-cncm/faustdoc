# Using Faust in Cmajor

In this tutorial, we present how [Faust](https://faust.grame.fr) can be used with [Cmajor](https://cmajor.dev), a C-like procedural high-performance language especially designed for audio processing, with dynamic JIT-based compilation. Compiling Faust DSP to Cmajor code allows you to take advantage of hundreds of DSP building blocks implemented in the [Faust Libraries](https://faustlibraries.grame.fr), ready-to-use [Examples](../examples/ambisonics.md), any DSP program developed in more than 200 projects listed on the [Powered By Faust](https://faust.grame.fr/community/powered-by-faust/) page, or Faust DSP programs found on the net.

#### Who is this tutorial for?

The [first section](#using-command-line-tools) assumes a working [Faust](https://github.com/grame-cncm/faust) compiler is installed on the machine, so it is more designed for regular Faust users. The [second section](#using-the-faust-web-ide) is better suited for Cmajor users who want to discover Faust.  

#### Installing the required packages

Download the [**cmaj** package](https://github.com/SoundStacks/cmajor/releases) and install to have it in your PATH. 

## Using command line tools

### Generating Cmajor code

Assuming you've [installed the **faust** compiler](https://faust.grame.fr/downloads/), starting from the following DSP **osc.dsp** program:

<!-- faust-run -->
```
import("stdfaust.lib");

vol = hslider("volume [unit:dB]", 0, -96, 0, 0.1) : ba.db2linear : si.smoo;
freq1 = hslider("freq1 [unit:Hz]", 1000, 20, 3000, 1);
freq2 = hslider("freq2 [unit:Hz]", 200, 20, 3000, 1);

process = vgroup("Oscillator", os.osc(freq1) * vol, os.osc(freq2) * vol);
```
<!-- /faust-run -->

The Cmajor code can be generated using:

```bash
faust -lang cmajor osc.dsp -o osc.cmajor
```

This will generate a `mydsp` processor included in a namespace `faust {...}` with a set of methods to manipulate it. This API basically mimics the [one defined for the C++ backend](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/dsp.h). 

### Looking at the generated code

The generated code contains `input event` definition for the three sliders defined in the DSP source code:

```
input event float32 eventfHslider1 [[ name: "freq1", group: "/v:Oscillator/freq1", min: 20.0f, max: 3000.0f, init: 1000.0f, step: 1.0f, meta_unit0: "Hz" ]];
input event float32 eventfHslider2 [[ name: "freq2", group: "/v:Oscillator/freq2", min: 20.0f, max: 3000.0f, init: 200.0f, step: 1.0f, meta_unit1: "Hz" ]];
input event float32 eventfHslider0 [[ name: "volume", group: "/v:Oscillator/volume", min: 0.0f, max: 1.0f, init: 0.5f, step: 0.01f ]];
```

The needed `main` function executes the DSP sample generation code:

```
void main()
{
    // DSP loop running forever...
    loop
    {
        if (fUpdated) { fUpdated = false; control(); }

        // Computes one sample
        fRec1[0] = fControl[1] + fRec1[1] - floor (fControl[1] + fRec1[1]);
        output0 <- float32 (fControl[0] * ftbl0mydspSIG0.at (int32 (65536.0f * fRec1[0])));
        fRec2[0] = fControl[2] + fRec2[1] - floor (fControl[2] + fRec2[1]);
        output1 <- float32 (fControl[0] * ftbl0mydspSIG0.at (int32 (65536.0f * fRec2[0])));
        fRec1[1] = fRec1[0];
        fRec2[1] = fRec2[0];

        // Moves all streams forward by one 'tick'
        advance();
    }
}
```

Note that the generated code uses the so-called [scalar code generation model](../manual/compiler.md#structure-of-the-generated-code), the default one, where the compiled sample generation code is inlined on the Cmajor `loop` block. 

We cannot directly play the generated `osc.cmajor` file since the **cmaj** program expects an `osc.cmajorpatch` to execute. A simple solution is to use the following command:

```bash
cmaj create --name=osc osc 
```

to create an  `osc`  folder with default  `osc.cmajor` and `osc.cmajorpatch` files. Then using the command:

```bash
faust -lang cmajor osc.dsp -o osc/osc.cmajor
```

allows us to simply replace the default `osc.cmajor` with our own Faust-generated version.

The patch file can now be compiled and executed using the **cmaj** program:

```bash
cmaj play osc/osc.cmajorpatch
```

The three declared sliders are automatically created and can be used to change the two channel frequencies and their volume.

The Cmajor processor code can directly be used in a more complex Cmajor program, possibly connected to other Faust generated or Cmajor hand-written processors. Note that the generated processor name can simply be changed using the Faust compiler `-cn <name>` option, so that several Faust generated processors can be distinguished by their names:

```bash
faust -lang cmajor -cn osc osc.dsp -o osc/osc.cmajor
```

### Using the faust2cmajor tool

The [faust2cmajor](https://github.com/grame-cncm/faust/tree/master-dev/architecture/cmajor#faust2cmajor) tool allows you to automate calling the Faust compiler with the right options and interacting with the **cmaj** program:

```bash
faust2cmajor -h
Usage: faust2cmajor [options] [Faust options] <file.dsp>
Compiles Faust programs to Cmajor
Options:
-midi : activates MIDI control
-nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
-effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
-effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
-juce : to create a JUCE project
-dsp : to create a 'dsp' compatible subclass
-play : to start the 'cmaj' runtime with the generated Cmajor file
Faust options : any option (e.g. -vec -vs 8...). See the Faust compiler documentation.
```

So the following command:
```bash
faust2cmajor -play osc.dsp 
```

will directly compile the `osc.dsp` file, generate the `osc.cmajor` and `osc.cmajorpatch` files:

```
{
    "CmajorVersion": 1,
    "ID": "grame.cmajor.osc",
    "version": "1.0",
    "name": "osc",
    "description": "Cmajor example",
    "category": "synth",
    "manufacturer": "GRAME",
    "website": "https://faust.grame.fr",
    "isInstrument": false,
    "source": "osc.cmajor"
}
```

And activate the **cmaj** program to run the processor. 

The following [polyphonic ready instrument](../manual/midi.md#midi-polyphony-support) DSP can be converted to a MIDI ready cmajor instrument:

<!-- faust-run -->
```
declare options "[midi:on][nvoices:8]";
import("stdfaust.lib");
process = organ <: _,_
with {
    decimalpart(x) = x-int(x);
    phasor(f) = f/ma.SR : (+ : decimalpart) ~ _;
    osc(f) = sin(2 * ma.PI * phasor(f));
    freq = nentry("freq", 100, 100, 3000, 0.01);
    gate = button("gate");
    gain = nentry("gain", 0.5, 0, 1, 0.01);
    organ = en.adsr(0.1, 0.1, 0.7, 0.25, gate) * (osc(freq) * gain + osc(2*freq)*0.5 * gain);
};

```
<!-- /faust-run -->

The following command then opens the **cmaj** program and MDI events can be sent to control the instrument:
```bash
faust2cmajor -play -midi -nvoices 16 organ.dsp 
```

Note that the generated GUI is empty, since the generated processor cannot automatically reflect its controls in the main graph.

The following polyphonic ready instrument DSP, with an [integrated effect](../manual/midi.md#audio-effects-and-polyphonic-synthesizer), can be converted to a MIDI ready cmajor instrument:

<!-- faust-run -->
```
declare options "[midi:on][nvoices:8]";
import("stdfaust.lib");
process = pm.clarinet_ui_MIDI <: _,_;
effect = dm.freeverb_demo;
```
<!-- /faust-run -->

The following command then opens the **cmaj** program and MIDI events can be sent to control the instrument:

```bash
faust2cmajor -play -midi -nvoices 16 -effect auto clarinet.dsp 
```

Here again, the generated GUI is empty.

### Generating the Cmajor output using faustremote

A possibility is to use the [faustremote](../manual/remote.md) script to convert a local DSP with the following commands:

```bash
faustremote cmajor cmajor foo.dsp
unzip binary.zip
```

## Using the Faust Web IDE

Faust DSP programs can be written and tested in the [Faust Web IDE](https://faustide.grame.fr/) and generated as embeddable Cmajor code.

### Generating the Cmajor output

The output as a Cmajor program can directly be generated using the *Platform = cmajor* and *Architecture = cmajor* export options. The resulting *foo* folder is self-contained, containing the `foo.cmajor` and `foo.cmajorpatch` files. The program can be executed using the `cmaj play foo/foo.cmajorpatch` command or possibly [converted as a JUCE plugin](https://github.com/SoundStacks/cmajor/blob/main/docs/Cmaj%20Quick%20Start.md).

<img src="img/export.png" class="mx-auto d-block" width="40%">
<center>*Exporting the code*</center>

### Generating the Cmajor output in polyphonic mode

DSP programs following the polyphonic [freq/gate/gain convention](../manual/midi.md#midi-polyphony-support) can be generated using the *Platform = cmajor* and *Architecture = cmajor-poly* export options. The resulting *foo* folder is self-contained, containing the `foo.cmajor` and `foo.cmajorpatch` files. The instrument can be executed using the `cmaj play foo/foo.cmajorpatch` command and played with a MIDI device or possibly [converted as a JUCE plugin](https://github.com/SoundStacks/cmajor/blob/main/docs/Cmaj%20Quick%20Start.md).

### Generating the Cmajor output in polyphonic mode with a global effect

DSP programs following the polyphonic [freq/gate/gain convention](../manual/midi.md#midi-polyphony-support) with an [integrated effect](../manual/midi.md#audio-effects-and-polyphonic-synthesizer) can be generated using the *Platform = cmajor* and *Architecture = cmajor-poly-effect* export options. The resulting *foo* folder is self-contained, containing the `foo.cmajor` and `foo.cmajorpatch` files. The instrument can be executed using the `cmaj play foo/foo.cmajorpatch` command and played with a MIDI device or possibly [converted as a JUCE plugin](https://github.com/SoundStacks/cmajor/blob/main/docs/Cmaj%20Quick%20Start.md).

### Generating the Cmajor Output from a Faust DSP Program Found on the Web

Faust DSP programs found on the web can also be converted:

- for instance the [fverb](https://faust.grame.fr/community/powered-by-faust/#fverb) listed on the [Powered By Faust](https://faust.grame.fr/community/powered-by-faust/) page. The DSP content can simply be loaded using the `https://faustide.grame.fr/?code=URL` syntax, so
with the following URL: [https://faustide.grame.fr/?code=https://raw.githubusercontent.com/jpcima/fverb/master/fverb.dsp](https://faustide.grame.fr/?code=https://raw.githubusercontent.com/jpcima/fverb/master/fverb.dsp), tested in the Faust Web IDE, then converted into a Cmajor program as already shown

- basic [Examples](../examples/ambisonics.md) have been compiled to Cmajor [here](cmajor/rsrc/examples-cmajor.zip)

- examples of the [faustplayground](https://faustplayground.grame.fr/) platform can be [found here](https://github.com/grame-cncm/faustplayground/tree/master/public/faust-modules) and possibly converted. They have been compiled to Cmajor [here](cmajor/rsrc/faust-modules-cmajor.zip).

## Experimental Faust in Cmajor Integration 

With the release of the [Cmajor source code](https://github.com/cmajor-lang/cmajor), an experimental integration with Faust is now available, beginning with the [Cmajor 1.0.2616 release](https://github.com/cmajor-lang/cmajor/releases/tag/1.0.2616). This enables the creation of patches that merge Faust and Cmajor code. The `libfaust` component, which includes a Faust-to-Cmajor backend, is compiled as WebAssembly and dynamically used in the Faust DSP-to-Cmajor conversion process. The resulting Cmajor files are then JIT-compiled. See the [FaustFM example](https://github.com/cmajor-lang/cmajor/tree/main/examples/patches/FaustFM).

### Known limitations

The Cmajor language generates some useful APIs when the patch is exported in C++ or JavaScript. For example the `getInputEndpoints/getOutputEndpoints` and `getEndpointHandle` functions allow an external piece of code to enumerate and access all endpoints, to possibly control the program or build a GUI. But unfortunately those functions **are not part of the language itself**. Thus we know of no way:

 - to write a generic Cmajor program that would automatically connect some endpoints (assuming they would use some kind of MIDI describing metadata) to MIDI messages
 
 - to write a generic Cmajor program that would automatically wrap a voice generated from a Faust DSP program in a polyphonic and MIDI-aware program, and expose the voice set of parameters at the main graph level, to be controlled globally for all voices

We think the language would gain expressive power by having some kind of [reflexivity](https://en.wikipedia.org/wiki/Reflective_programming). 
