# Using Faust in JSFX

In this tutorial, we present how [Faust](https://faust.grame.fr) can be used with [JSFX](https://www.reaper.fm/sdk/js/js.php), a scripting language used in [Reaper](https://www.reaper.fm). The JSFX engine is integrated in Reaper by default, and can also be found as a plugin opcode for Csound, as well as a set of standalone projects : [ysfx](https://github.com/jpcima/ysfx), [jsusfx](https://github.com/asb2m10/jsusfx/tree/bcc9cd7b910ee7bba5b4cd2649448ade2ec15712). 
The JSFX language is based on Cockos [EEL2](https://www.cockos.com/EEL2/) open-source programming language.

#### Who is this tutorial for?

The [first section](#using-command-line-tools) assumes a working [Faust compiler installed](https://github.com/grame-cncm/faust) on the machine, so is more designed for regular Faust users. The [second section](#using-the-faust-web-ide) is better suited for JSFX users who want to discover Faust.  


## Using command line tools

### Generating JSFX code

Assuming you've [compiled and installed](https://github.com/grame-cncm/faust/wiki/BuildingSimple) the **faust** compiler from the [master-dev branch](https://github.com/grame-cncm/faust), starting from the following DSP **osc.dsp** program:

<!-- faust-run -->
```
import("stdfaust.lib");

vol = hslider("volume [unit:dB]", 0, -96, 0, 0.1) : ba.db2linear : si.smoo;
freq1 = hslider("freq1 [unit:Hz]", 1000, 20, 3000, 1);
freq2 = hslider("freq2 [unit:Hz]", 200, 20, 3000, 1);

process = vgroup("Oscillator", os.osc(freq1) * vol, os.osc(freq2) * vol);
```
<!-- /faust-run -->

The JSFX code can be generated using
```bash
faust -lang jsfx osc.dsp -o osc.jsfx 
```

This will generate JSFX code that follows the standard JSFX file structure: 

```jsfx
@init // init section

@block // control section 

@slider // called when a control value changes

@sample // audio computation section
``` 

This code can be directly imported in Reaper or placed in Reaper Effects directory. 
<img src="img/jsfx_reaper.png" class="mx-auto d-block" width="100%">
<center>*Generated JSFX plugin in Reaper*</center>

The generated code is fully self-contained and can be directly imported as a Reaper JSFX audio plugin, on any supported platform. 

At the top of the generated file, a few lines are dedicated to report file description and metadata.
Then, the initialization starts with:  

- Sliders
- Inputs and outputs

```jsfx
slider1:fHslider0=1000<20,3000,1>hslider_freq10
slider2:fHslider2=200<20,3000,1>hslider_freq20
slider3:fHslider1=0<-96,0,0.1>hslider_volume0

out_pin:output0
out_pin:output1
```

In JSFX, sliders are the only available controls that match Faust controls. It has been decided that buttons and checkboxes are thus represented as ***0-1*** sliders in JSFX. 

Next, the `@init` section starts with all required functions - including math functions missing in JSFX and memory management functions.
These functions will always be included in generated JSFX code, since the rest of the code requires it. 

The `@init` section then defines a few constants (bitmasks for MIDI processing, and useful constants for processing like number of voices `nvoices`).
The actual DSP part starts right after these constants. 
Global tables are then allocated, here the table where sine waveform will be computed: 

```
ftbl0mydspSIG0 = MEMORY.alloc_memory(65536);
```

And the structure of our DSP class is defined. Since JSFX is not a real object oriented programming language, we use indexes inside memory chunks to access DSP object members. 
Each object itself is represented as an address in JSFX preallocated memory. The `dsp.` fields indicate the position of members inside the object memory. 

```
// DSP struct memory layout
dsp.memory = MEMORY.alloc_memory(0);
ddsp.size = 24;
dsp.iVec1 = 0;
dsp.fHslider0 = 2;
dsp.fSampleRate = 3;
dsp.fConst1 = 4;
dsp.fRec1 = 5;
dsp.fConst2 = 7;
dsp.fConst3 = 8;
dsp.fHslider1 = 9;
dsp.fRec2 = 10;
dsp.fHslider2 = 12;
dsp.fRec3 = 13;
dsp.iVec0 = 15;
dsp.iRec0 = 17;
dsp.fSlow0 = 19;
dsp.fSlow1 = 20;
dsp.fSlow2 = 21;
dsp.output0 = 22;
dsp.output1 = 23;
```

The next part consists in two functions used to create DSP objects, allocate their memory and initialize their states. One object represents one voice. If object has no `[nvoices]` metadata, or if `[nvoices:1]`, only one object will be created. The `create_instance` function allocates memory, then `init_instances` precomputes object state, including constants and everything that doesn't need to be computed at runtime. 

At last, the `@init` section defines the `control` function. This function corresponds to the computation happening just before the audio loop in the C++ backend. These correspond to the computations related to controls and MIDI. 

In JSFX sandboxed context, we don't need to call it on every loop, thus it has been pushed outside of `@block`. Moreover, this computation must be accessible from both `@slider` and `@block`. The current implementation will trigger a call to `control` function everytime a slider value changes, or everytime a MIDI input event happens. 


By default, the `@block` section is empty. It will be filled with code if MIDI is somehow enabled:

 - by associating MIDI input to a control in slider metadata `[keyon:64]`
 - by setting polyphonic mode with `declare options ["nvoices:4"]` 
    
The former will actually connect MIDI key or ctrl to the slider, while the latter will connect MIDI note inputs to sliders named *freq*, *key*, *vel*, *gain*, *gate*, and will convert the MIDI value to whatever it is supposed to represent: frequency for *freq*, raw MIDI note number for "key" (...).  

The `@block` section contains a condition so that it will only call `control` function when MIDI events occur. 

The ̀`@slider` section only calls `control`, and is itself only computed when a slider value changes.

Finally, the `@sample` section is where the magic happens. It will loop through the different objects and compute the audio output. This section is represented in JSFX as a block of code called for every single sample. At the bottom of generated code, object outputs are summed in JSFX special variables `spl0`, `spl1` (...), which are the actual outputs of a JSFX plugin.

### MIDI basic example

Basic MIDI inputs can be retrieved with controls (Faust sliders) if specific metadata are added to the control name.
The available MIDI inputs are: 

 - keyon
 - keyoff
 - key (both keyon and keyoff)
 - ctrl

See [MIDI](https://faustdoc.grame.fr/manual/midi/) for more information about MIDI metadata syntax.

<!-- faust-run -->
```
declare options "[midi:on]";
import("stdfaust.lib");

vel = hslider("vel[midi:ctrl 10]", 0, 0, 127, 1);
freq = hslider("freq[midi:ctrl 11]", 50, 50, 1000, 0.1);

process = os.osc(freq) * 0.1 * (vel / 127);
```
<!-- /faust-run -->

The generated code will contain a `@block` section that connects MIDI CC input (for CC 10 and 11) to relevant control values. 

```jsfx
@block
midi_event = 0;
while (midirecv(mpos, msg1, msg2, msg3)) (
        status = msg1&0xF0;
        channel = msg1&0x0F;
        (status == CC) ? (
                midi_event += 1;
                (msg2 == 0xa) ? (fHslider1 = midi_scale(msg3, 0.0000000000000000, 127.0000000000000000, 1.0000000000000000));
                (msg2 == 0xb) ? (fHslider0 = midi_scale(msg3, 50.0000000000000000, 1000.0000000000000000, 0.1000000000000000));
        );
);
(midi_event > 0) ? (control());
```

### MIDI polyphonic example

As explained in the [MIDI](https://faustdoc.grame.fr/manual/midi/) documentation, Faust supports MIDI polyphonic audio plugins. These plugins respond to MIDI note inputs with three different data: 

 - key or frequency
 - velocity or gain
 - a gate used to trigger an envelope 

Be careful that *key* will be a value between 0-127 while frequency will be converted to cycle per seconds. Same mechanism applies to velocity (0-127) versus gain (0-1). 
The following code shows the basic mechanism of MIDI polyphonic instrument that compiles for JSFX. 

<!-- faust-run -->
```
declare options "[nvoices:4]";
import("stdfaust.lib");

freq = hslider("freq", 0, 0, 10000, 0.1) : si.smoo;
gain = hslider("gain", 0, 0, 1, 0.01) : si.smoo;
gate = checkbox("gate");
env = gate : en.asr(0.1, 0.5, 0.5);

process = os.osc(freq) * env * gain * 0.1;
```
<!-- /faust-run -->

In this JSFX backend, polyphonic voices use a voice stealing mechanism, allowing a new voice to steal the oldest one if no voice is free. 

The generated code contains a filled `@block` section that is used to look for MIDI input notes `midirecv`, thus performing expected actions: 

 - a NOTE ON message looks for an available voice (or steals the oldest one if necessary) and sets its controls
 - a NOTE OFF message looks for the voice that is playing its key to turn its gate off. 
    
    
```
@block
midi_event = 0;
while (midirecv(mpos, msg1, msg2, msg3)) (
        status = msg1&0xF0;
        channel = msg1&0x0F;
        (status == NOTE_ON) ? (
                midi_event += 1;
                voice_idx = get_oldest_voice();
                sort_voices(voice_idx);
                obj = get_dsp(voice_idx);
                obj[dsp.key_id] = msg2;
                obj[dsp.gate] = 1;
                obj[dsp.fCheckbox0] = 1;
                obj[dsp.fHslider1] = midi_scale(msg3, 0.0000000000000000, 1.0000000000000000, 0.0100000000000000);
                obj[dsp.fHslider0] = limit(mtof(msg2), 0.0000000000000000, 10000.0000000000000000);
        ); // NOTE ON condition off
        (status == NOTE_OFF) ? (
                midi_event += 1;
                voice_idx = 0;
                while(voice_idx < nvoices) (
                        obj = get_dsp(voice_idx);
                        (obj[dsp.key_id] == msg2 && obj[dsp.gate] > 0) ? (
                                obj[dsp.gate] = 0;
                                obj[dsp.fCheckbox0] = 0;
                                voice_idx = nvoices;
                        );
                        voice_idx += 1;
                ); // end of while
        ); // end of condition
);
(midi_event > 0) ? (control());
```

## Using the Faust Web IDE


### Generating a JSFX file

The JSFX backend is available on the [Faust web IDE](https://faustide.grame.fr/). In order to export a Faust program as JSFX code, you will need to click on the "export/compile to specific target" button (on the left side, below "Save as"). Then, you need to  choose ***jsfx*** both as the platform and architecture, and click ***compile***.  
This will allow your to download a `binary.zip` file, containing the resulting ***jsfx*** file and your original ***dsp*** file. 

### Generating a JSFX file in polyphonic mode

Use the `declare options "[midi:on][nvoices:n]";` [convention](https://faustdoc.grame.fr/manual/midi/#configuring-and-activating-polyphony) in the DSP code to activate MIDI and polyphonic mode.

## Limitations

As JSFX is a sandboxed environment, this backend cannot match the full Faust potential. Some features are missing, some other might come in the future. 

First, only three controls are available: 

 - sliders: hslider, vslider, nentry
 - button
 - checkbox
 
All of these are mapped to sliders in JSFX. 

On the MIDI side, this backend does not support program changes, neither channel press, or pitchweel. As described before, the available MIDI is key, keyon, keyoff, ctrl and polyphonic mode. 

