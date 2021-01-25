# Architecture files

A Faust program describes a *signal processor*, a pure computation that maps *input signals* to *output signals*. It says nothing about audio drivers or controllers (like GUI, OSC, MIDI, sensors) that are going to control the DSP. This missing information is provided by *architecture files*.

An *architecture file* describes how to relate a Faust program to the external world, in particular the audio drivers and the controllers interfaces to be used. This approach allows a single Faust program to be easily deployed to a large variety of audio standards (Max/MSP externals, PD externals, VST plugins, CoreAudio applications, JACK applications, iPhone, etc.).

The architecture to be used is specified at compile time with the `-a` option. For example `faust -a jack-gtk.cpp foo.dsp` indicates to use the JACK GTK architecture when compiling `foo.dsp`.

**TODO: The main available architecture files are listed table 6.1.** 



Some of these architectures are a modular combination of an *audio module* and one or more *controller modules*. Among these user interface modules OSCUI provide supports for Open Sound Control allowing Faust programs to be controlled by OSC messages.

**Describe Minimal architecture files** 


## Audio architecture modules

An *audio architecture module* typically connects a Faust program to the audio drivers. It is responsible for allocating and releasing the audio channels and for calling the Faust `dsp::compute` method to handle incoming audio buffers and/or to produce audio output. It is also responsible for presenting the audio as non-interleaved float data, normalized between -1.0 and 1.0.

A Faust audio architecture module derives from an *audio* class defined as below (simplified version, see the [real version here)](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/audio/audio.h):

```c++
class audio {
     
    public:
    
        audio() {}
        virtual ~audio() {}
    
        /**
         * Init the DSP.
         * @param name - the DSP name to be given to the audio driven 
         * (could appear as a JACK client for instance)
         * @param dsp - the dsp that will be initialized with the driver sample rate
         *
         * @return true is sucessful, false if case of driver failure.
         **/
        virtual bool init(const char* name, dsp* dsp) = 0;
    
        /**
         * Start audio processing.
         * @return true is sucessfull, false if case of driver failure.
         **/
        virtual bool start() = 0;
        
        /**
         * Stop audio processing.
         **/
        virtual void stop() = 0;
        
        void setShutdownCallback(shutdown_callback cb, void* arg) = 0;
    
         // Return buffer size in frames.
        virtual int getBufferSize() = 0;
    
        // Return the driver sample rate in Hz.
        virtual int getSampleRate() = 0;

        // Return the driver hardware inputs number.
        virtual int getNumInputs() = 0;
    
        // Return the driver hardware outputs number.
        virtual int getNumOutputs() = 0;
        
        /**
        * @return Returns the average proportion of available CPU 
        * being spent inside the audio callbacks (between 0.0 and 1.0).
        **/
        virtual float getCPULoad() = 0;
};
```

The API is simple enough to give a great flexibility to audio architectures implementations. The  `init` method should initialize the audio. At  `init` exit, the system should be in a safe state to recall the  `dsp` object state. 

**Schéma de la hiéarchie audio.**



## MIDI architecture modules

An *MIDI architecture module* typically connects a Faust program to the MIDI drivers. MIDI control connects DSP parameters with MIDI messages (in both directions), and can be used to trigger polyphonic instruments.

#### MIDI Messages Description in the DSP Source Code

MIDI control messages are described as meta-data in UI elements. They are decoded by a `MidiUI` class, subclass of `UI`, which parses incoming MIDI messages and updates the appropriate priate control parameters, or sends MIDI messages when the UI elements (sliders, buttons...) are moved.

#### Defined Standard MIDI messages

A special `[midi:xxx yyy...]` metadata needs to be added in the UI element. The full description of supported MIDI messages is now part of the [Faust documentation](https://faustdoc.grame.fr/manual/midi/).

#### MIDI Classes

A `midi` base class defining MIDI messages decoding/encoding methods has been developed. It will be used to receive and tranmist MIDI messages:

class midi {

```c++
public:

    midi() {}
    virtual ~midi() {}

    // Additional time-stamped API for MIDI input
    virtual MapUI* keyOn(double, int channel, int pitch, int velocity)
    {
        return keyOn(channel, pitch, velocity);
    }
    
    virtual void keyOff(double, int channel, int pitch, int velocity = 127)
    {
        keyOff(channel, pitch, velocity);
    }

    virtual void keyPress(double, int channel, int pitch, int press)
    {
        keyPress(channel, pitch, press);
    }
    
    virtual void chanPress(double date, int channel, int press)
    {
        chanPress(channel, press);
    }

    virtual void pitchWheel(double, int channel, int wheel)
    {
        pitchWheel(channel, wheel);
    }
       
    virtual void ctrlChange(double, int channel, int ctrl, int value)
    {
        ctrlChange(channel, ctrl, value);
    }

    virtual void ctrlChange14bits(double, int channel, int ctrl, int value)
    {
        ctrlChange14bits(channel, ctrl, value);
    }

    virtual void rpn(double, int channel, int ctrl, int value)
    {
        rpn(channel, ctrl, value);
    }

    virtual void progChange(double, int channel, int pgm)
    {
        progChange(channel, pgm);
    }

    virtual void sysEx(double, std::vector<unsigned char>& message)
    {
        sysEx(message);
    }

    // MIDI sync
    virtual void startSync(double date)  {}
    virtual void stopSync(double date)   {}
    virtual void clock(double date)  {}

    // Standard MIDI API
    virtual MapUI* keyOn(int channel, int pitch, int velocity)      { return nullptr; }
    virtual void keyOff(int channel, int pitch, int velocity)       {}
    virtual void keyPress(int channel, int pitch, int press)        {}
    virtual void chanPress(int channel, int press)                  {}
    virtual void ctrlChange(int channel, int ctrl, int value)       {}
    virtual void ctrlChange14bits(int channel, int ctrl, int value) {}
    virtual void rpn(int channel, int ctrl, int value)              {}
    virtual void pitchWheel(int channel, int wheel)                 {}
    virtual void progChange(int channel, int pgm)                   {}
    virtual void sysEx(std::vector<unsigned char>& message)         {}

    enum MidiStatus {
        // channel voice messages
        MIDI_NOTE_OFF = 0x80,
        MIDI_NOTE_ON = 0x90,
        MIDI_CONTROL_CHANGE = 0xB0,
        MIDI_PROGRAM_CHANGE = 0xC0,
        MIDI_PITCH_BEND = 0xE0,
        MIDI_AFTERTOUCH = 0xD0,         // aka channel pressure
        MIDI_POLY_AFTERTOUCH = 0xA0,    // aka key pressure
        MIDI_CLOCK = 0xF8,
        MIDI_START = 0xFA,
        MIDI_CONT = 0xFB,
        MIDI_STOP = 0xFC,
        MIDI_SYSEX_START = 0xF0,
        MIDI_SYSEX_STOP = 0xF7
    };

    enum MidiCtrl {
        ALL_NOTES_OFF = 123,
        ALL_SOUND_OFF = 120
    };

    enum MidiNPN {
        PITCH_BEND_RANGE = 0
    };
};
```
A [midi_hander](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/midi/midi.h#L261) subclass implements actual decoding. Several concrete implementations based on native API have been written and can be found in the [faust/midi](https://github.com/grame-cncm/faust/tree/master-dev/architecture/faust/midi) folder.

Depending on the used native MIDI API, event time-stamps are either expressed in absolute time or in frames. They are converted to offsets expressed in samples relative to the beginning of the audio buffer.

Connected with the `MidiUI` class, sub-class of `UI`, they allow a given DSP to be controlled with incoming MIDI messages or possibly send MIDI messages when its internal control state changes.

In the following piece of code, a `MidiUI` object is created and connected to a `rt_midi` MIDI message handler, then given as parameter to the standard `buildUserInterface` to control the DSP parameters:

```c++
...
rt_midi midi_handler("MIDI");
MidiUI midiinterface(&midi_handler);
DSP->buildUserInterface(&midiinterface);
...
```




## UI architecture modules

A UI architecture module links user actions (via graphic widgets, command line parameters, OSC messages, etc.) with the Faust program to control. It is responsible for associating program parameters to user interface elements and to update parameter’s values according to user actions. This association is triggered by the `dsp::buildUserInterface`call, where the `dsp` asks a UI object to build the DSP module controllers.

Since the interface is basically graphic oriented, the main concepts are *widget* based: a UI architecture module is semantically oriented to handle active widgets, passive widgets and widgets layout.

A Faust UI architecture module derives an *UI* class **(Figure 6.1) TODO.**

#### Active widgets

Active widgets are graphical elements that control a parameter value. They are initialized with the widget name and a pointer to the linked value, using the `FAUSTFLOAT` macro type (defined at compile time as either `float` or `double`). The widget currently considered are `Button`, `CheckButton`, `VerticalSlider`, `HorizontalSlider` and `NumEntry`.

A GUI architecture must implement a method `addXxx(const char* name, FAUSTFLOAT* zone, ...)` for each activewidget. Additional parameters are available for `Slider` and `NumEntry`: the `init`, `min`, `max` and `step` values.

#### Passive widgets

Passive widgets are graphical elements that reflect values. Similarly to active widgets, they are initialized with the widget name and a pointer to the linked value. The widget currently considered are `HorizontalBarGraph` and `VerticalBarGraph`.

A UI architecture must implement a method`addXxx(const char* name, FAUSTFLOAT* zone, ...)` for each passive widget. Additional parameters are available, depending on the passive widget type.

#### Widgets layout

Generally, a GUI is hierarchically organized into boxes and/or tab boxes. A UI architecture must support the following methods to setup this hierarchy :

```c++
  openTabBox(const char* label);
  openHorizontalBox(const char* label);
  openVerticalBox(const char* label);
  closeBox(const char* label);
```

Note that all the widgets are added to the current box.

#### Metadata

The Faust language allows widget labels to contain metadata enclosed in square brackets as key/value pairs. These metadata are handled at GUI level by a declare method taking as argument, a pointer to the widget associated zone, the metadata key and value:

```c++
declare(FAUSTFLOAT* zone, const char* key, const char* value);
```

Here is the table of currently supported general medatada (look at section 7 for OSC specific metadata and section 9 for MIDI specific metadata):

Some typical example where several metadata are defined could be:

```
nentry("freq [unit:Hz][scale:log][acc:0 0 -30 0 30][style:menu{’white noise’:0;’pink noise’:1;’sine’:2}][hidden:0]", 0, 20, 100, 1)
```

or:

```
vslider("freq [unit:dB][style:knob][gyr:0 0 -30 0 30]", 0, 20, 100, 1)
```

Note that medatada are not supported in all architecture files. Some of them like (`acc` or `gyr` for example) only make sense on platforms with accelerometers or gyroscopes sensors. The set of medatada may be extended in the future. They can be decoded using the `MetaDataUI`class.

**Schéma de la hiéarchie UI.**



#### DSP JSON description 

The full description of a given compiled DSP can be generated as a JSON file, to be used at several places in the architecture system. This JSON describes the DSP with its inputs/ouput number, some metadata (filename, name, used compilation parameters, used libraries...etc.) as well as its UI. Here is an example of the JSON file generated for the following DSP program:

**TODO**

The JSON file can be generated with `faust -json foo.dsp` command, or by program using the `JSONUI` UI architecture (see next section).

#### GUI builders

Here is the description of some GUI classes:

- the [GTKUI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/GTKUI.h) class uses the [GTK](https://www.gtk.org) toolkit to create a Graphical User interface with a proper group based layout
- the [QTUI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/QTUI.h) class uses the [QT](the [GTKUI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/GTKUI.h) class uses the [GTK](https://www.gtk.org) tookkit to create a GUI with a proper layout) tookkit to create a Graphical User interface with a proper group based layout

#### Some useful UI classes 

Some useful UI classes can possibly be reused in developer code:

- the [MetaDataUI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/MetaDataUI.h) class decodes all currently supported metadata and can be used to retrieve their values 
- the [JSONUI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/JSONUI.h) class allows to generate the JSON description of a given DSP 
- the [MapUI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/MapUI.h) class establishes a mapping beween UI items and their label or paths, and offers a `setParamValue/getParamValue` API to set and get their values
- the extended [APIUI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/APIUI.h) offers `setParamValue/getParamValue` API similar to `MapUI` with additional methods like to deal with accelerometer/gyroscope kind of metadata
- the [SoundUI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/SoundUI.h) class with the associated [Soundfile](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/Soundfile.h) class is used to implement the language `soundfile` primitive, and load the described audio files, by using different concrete implementations, either using [libsndfile](http://www.mega-nerd.com/libsndfile/) with the  [LibsndfileReader.h](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/LibsndfileReader.h) file, or [JUCE](https://juce.com) with the [JuceReader](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/JuceReader.h) file. 



**Aditionnal tools**

**JSONUIDecoder**



#### Multi-controller and synchronisation 

A given DSP can perfectly be controlled by  several UI classes at the same time, and they will all read and write the same DSP control memory zones. Here is an example of code using a GUI using `GTKUI` architecture, as well as OSC control using `OSCUI`:

```c++
...
GTKUI interface(name, &argc, &argv);
DSP->buildUserInterface(&interface);
OSCUI oscinterface(name, argc, argv);
DSP->buildUserInterface(&oscinterface);
...
```
Since several controller *see* the same values, you may have to synchronize them, in order for instance to have the GUI sliders or buttons *reflect the state* that would have been changed by the `OSCUI` controller at reception time, of have OSC messages *been sent* each time UI items like sliders or buttons are moved.   

This synchronization mecanism is implemented in a generic way in the [GUI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/gui/GUI.h) class, which defines  the `uiItem` class as the basic synchronizable memory zone, then grouped in a list controlling the same zone from different GUI instances.  The `uiItem::modifyZone` method is used to change the `uiItem`  state at reception time, and `uiItem::reflectZone`will be called to refect a new value, and can change the Widget layout for instance, or send a message (OSC, MIDI...).

All classes that need to use this synchronization mechanism will have to subclass the `GUI` class, which keep all of them at runtime in a global `GUI::fGuiList` variable.

Finally the static `GUI::updateAllGuis()` synchronization method will be have to be called regularly, in the application or plugin event management loop, or a periodic timer for instance.

  


## DSP architecture modules

The Faust compiler produces a DSP module which format will depend of the chosen backend: a C++ class with the `-lang cpp` option, a data structure with associated functions with the `-lang c` option, an LLVM IR module  with the `-lang llvm` option, a WebAssembly binary module with the `-lang wasm` option, a bytecode stream with the `-lang interp` option... and so on.

### The base dsp class

In C++, the generated class derives from a base `dsp` class:

```c++
class dsp {

public:

    dsp() {}
    virtual ~dsp() {}

    /* Return instance number of audio inputs */
    virtual int getNumInputs() = 0;

    /* Return instance number of audio outputs */
    virtual int getNumOutputs() = 0;

    /**
     * Trigger the ui_interface parameter with instance specific calls
     * to 'openTabBox', 'addButton', 'addVerticalSlider'... in order to build the UI.
     *
     * @param ui_interface - the user interface builder
     */
    virtual void buildUserInterface(UI* ui_interface) = 0;

    /* Return the sample rate currently used by the instance */
    virtual int getSampleRate() = 0;

    /**
     * Global init, calls the following methods:
     * - static class 'classInit': static tables initialization
     * - 'instanceInit': constants and instance state initialization
     *
     * @param sample_rate - the sampling rate in Hertz
     */
    virtual void init(int sample_rate) = 0;

    /**
     * Init instance state
     *
     * @param sample_rate - the sampling rate in HZ
     */
    virtual void instanceInit(int sample_rate) = 0;

    /**
     * Init instance constant state
     *
     * @param sample_rate - the sampling rate in HZ
     */
    virtual void instanceConstants(int sample_rate) = 0;

    /* Init default control parameters values */
    virtual void instanceResetUserInterface() = 0;

    /* Init instance state (like delay lines..) but keep the control parameter values */
    virtual void instanceClear() = 0;
 
    /**
     * Return a clone of the instance.
     *
     * @return a copy of the instance on success, otherwise a null pointer.
     */
    virtual dsp* clone() = 0;

    /**
     * Trigger the Meta* parameter with instance specific calls to 'declare' 
     * (key, value) metadata.
     *
     * @param m - the Meta* meta user
     */
    virtual void metadata(Meta* m) = 0;

    /**
     * DSP instance computation, to be called with successive in/out audio buffers.
     *
     * @param count - the number of frames to compute
     * @param inputs - the input audio buffers as an array of non-interleaved 
     * FAUSTFLOAT samples (eiher float, double or quad)
     * @param outputs - the output audio buffers as an array of non-interleaved 
     * FAUSTFLOAT samples (eiher float, double or quad)
     *
     */
    virtual void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) = 0;

    /**
     * DSP instance computation: alternative method to be used by subclasses.
     *
     * @param date_usec - the timestamp in microsec given by audio driver.
     * @param count - the number of frames to compute
     * @param inputs - the input audio buffers as an array of non-interleaved 
     * FAUSTFLOAT samples (either float, double or quad)
     * @param outputs - the output audio buffers as an array of non-interleaved 
     * FAUSTFLOAT samples (either float, double or quad)
     *
     */
    virtual void compute(double date_usec, 
                         int count, 
                         FAUSTFLOAT** inputs, 
                         FAUSTFLOAT** outputs) = 0;
};
```

For a given compiled DSP program, the compiler will generate a `mydsp` subclass of `dsp` and fill the different methods (the actual name can be changed using the `-cn` option). For dynamic code producing backends like the LLVM IR, SOUL or the Interp ones, the actual code (an LLVM module, a SOUL module or C++ class, or a bytecode stream) is actually wrapped by some additional C++ code glue, to finally produces  an`llvm_dsp` typed object (defined in the [llvm-dsp.h](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/llvm-dsp.h) file), a `soulpatch_dsp`  typed object (defined in the [soulpatch-dsp.h](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/soulpatch-dsp.h) file) or a `interpreter_dsp` typed object (defined in [interpreter-dsp.h](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/interpreter-dsp.h) file), ready to be used  with the `UI` and `audio`  C++ classes (like the C++ generated class). See the following class diagram:

### Macro construction of DSP components

The Faust program specification is usually entirely done in the language itself. But in some specific cases it may be useful to develop *separated DSP components* and *combine* them in a more complex setup.

Since taking advantage of the huge number of already available UI and audio architecture files is important, keeping the same dsp API is preferable, so that more complex DSP can be controlled and audio rendered the usual way. Extended DSP classes will typically subclass the `dsp` root class and override or complete part of its API. 

#### Combining DSP

##### Dsp Decorator Pattern

A `dsp_decorator` class, subclass of the root `dsp` class has first been defined. Following the decorator design pattern, it allows behavior to be added to an individual object, either statically or dynamically.

As an example of the decorator pattern, the `timed_dsp` class allows to decorate a given DSP with sample accurate control capability or  the `mydsp_poly` class for polyphonic DSPs, explained in the next sections.

##### Combining DSP Components

A few additional macro construction classes, subclasses of the root dsp class have been defined in the [dsp-combiner.h](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/dsp-combiner.h) header file:

- the `dsp_sequencer` class combines two DSP in sequence, assuming that the number of outputs of the first DSP equals the number of input of the second one. Its `buildUserInterface` method is overloaded to group the two DSP in a tabgroup, so that control parameters of both DSPs can be individually controlled. Its `compute` method is overloaded to call each DSP `compute` in sequence, using an intermediate output buffer produced by first DSP as the input one given to the second DSP.
- the `dsp_parallelizer`  class combines two DSP in parallel. Its `getNumInputs/getNumOutputs` methods are overloaded by correctly reflecting the input/output of the resulting DSP as the sum of the two combined ones. Its `buildUserInterface` method is overloaded to group the two DSP in a tabgroup, so that control parameters of both DSP can be individually controlled. Its `compute` method is overloaded to call each DSP compute, where each DSP consuming and producing its own number of input/output audio buffers taken from the method parameters.

And so on for other DSP algebraic operator. This end up with a C++ API to combine DSPs wiht the usual 5 operators: `createDSPSequencer`, `createDSPParallelizer`, `createDSPSplitter`, `createDSPMerger`, `createDSPRecursiver` that can possibly be used at C++ level to dynamically combine DSPs (defined in the [dsp-combiner.h](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/dsp-combiner.h) header). 

### Sample Accurate Control

DSP audio languages usually deal with several timing dimensions when treating control events and generating audio samples. For performance reasons, systems maintain separated audio rate for samples generation and control rate for asynchronous messages handling.

The audio stream is most often computed by blocks, and control is updated between blocks. To smooth control parameter changes, some languages chose to interpolate parameter values between blocks.

In some cases control may be more finely interleaved with audio rendering, and some languages simply choose to interleave control and sample computation at sample level.

Although the Faust language permits the description of sample level algorithms (like recursive filters etc.), Faust generated DSP are usually computed by blocks. Underlying audio architectures give a fixed size buffer over and over to the DSP `compute` method which consumes and produces audio samples.

##### Control to DSP Link

In the current version of the Faust generated code, the primary connection point between the control interface and the DSP code is simply a memory zone. For control inputs, the archi- tecture layer continuously write values in this zone, which is then *sampled* by the DSP code at the beginning of the compute method, and used with the same values during the entire call. Because of this simple control/DSP connexion mechanism, the *most recent value* is seen by the DSP code.

Similarly for control outputs , the DSP code inside the `compute`  method possibly write several values at the same memory zone, and the *last value* only will be seen by the control architecture layer when the method finishes.

Although this behaviour is satisfactory for most use-cases, some specific usages need to handle the complete stream of control values with sample accurate timing. For instance keeping all control messages and handling them at their exact position in time is critical for proper MIDI clock synchronisation.

##### Control to DSP Link

The first step consists in extending the architecture control mechanism to deal with *time-stamped* control events. Note that this requires the underlying event control layer to support this capability. The native MIDI API for instance is usually able to deliver time-stamped MIDI messages.

The next step is to keep all time-stamped events in a *time ordered* data structure to be continuously written by the control side, and read by the audio side.

Finally the sample computation has to take account of all queued control events, and correctly change the DSP control state at successive points in time.

##### Slices Based DSP Computation

With time-stamped control messages, changing control values at precise sample indexes on the audio stream becomes possible. A generic *slices based* DSP rendering strategy has been implemented in the [timed_dsp](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/timed-dsp.h) class.

A ring-buffer is used to transmit the stream of time-stamped events from the control layer to the DSP one. In the case of MIDI control case for instance, the ring-buffer is written with a pair containing the time-stamp expressed in samples and the actual MIDI message each time one is received. In the DSP compute method, the ring-buffer will be read to handle all messages received during the previous audio block.

Since control values can change several times inside the same audio block, the DSP compute cannot be called only once with the total number of frames and the complete inputs/outputs audio buffers. The following strategy has to be used:

- several slices are defined with control values changing between consecutive slices
- all control values having the same time- stamp are handled together, and change the DSP control internal state. The slice is computed up to the next control param- eters time-stamp until the end of the given audio block is reached
- in the Figure 3 example, four slices with the sequence of c1, c2, c3, c4 frames are successively given to the DSP compute method, with the appropriate part of the audio input/output buffers. Control values (appearing here as [v1,v2,v3], then [v1,v3], then [v1], then [v1,v2,v3] sets) are changed between slices

Since time-stamped control messages from the previous audio block are used in the current block, control messages are aways handled with one audio buffer latency.



**FIG SLICE**

**TODO: diagram of C++ classes**



**Décrire mydsp_poly, timed_dsp**



### Polyphonic instruments

Directly programing polyphonic instruments in Faust is perfectly possible. It is also needed if very complex signal interaction between the different voices have to be described.

But since all voices would always be computed, this approach could be too CPU costly for simpler or more limited needs. In this case describing a single voice in a Faust DSP program and externally combining several of them with a special polyphonic instrument aware architecture file is a better solution. Moreover, this special architecture file takes care of dynamic voice allocations and control MIDI messages decoding and mapping.

#### Polyphonic ready DSP Code

By convention Faust architecture files with polyphonic capabilities expect to find control parameters named `freq`, `gain` and `gate`. The metadata `declare nvoices "8";` kind of line with a desired value of voices can be added in the source code.

In the case of MIDI control, the freq parameter (which should be a frequency) will be automatically computed from MIDI note numbers, gain (which should be a value between 0 and 1) from velocity and gate from keyon/keyoff events. Thus, gate can be used as a trigger signal for any envelope generator, etc.

#### Using the mydsp_poly class

The single voice has to be described by a Faust DSP program, the `mydsp_poly` class is then used to combine several voices and create a polyphonic ready DSP:

-

- the [poly-dsp.h](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/poly-dsp.h) file contains the definition of the `mydsp_poly` class used to wrap the DSP voice into the polyphonic architecture. This class maintains an array of `dsp`  type of objects, manage dynamic voice allocations, control MIDI messages decoding and mapping, mixing of all running voices, and stopping a voice when its output level decreases below a given threshold.
- as a sub-class of DSP, the `mydsp_poly` class redefines the `buildUserInterface` method. By convention all allocated voices are grouped in a global  *Polyphonic* tabgroup. The first tab contains a *Voices* group, a master like component used to change parameters on all voices at the same time, with a *Panic* button to be used to stop running voices, followed by one tab for each voice. Graphical User Interface components will then reflect the multi-voices structure of the new polyphonic DSP 

**FIGURE**

The resulting polyphonic DSP object can be used as usual, connected with the needed audio driver, and possibly other `UI` control objects like `OSCUI`, `httpdUI`, etc. Having this new UI hierarchical view allows complete OSC control of each single voice and their control parameters, but also all voices using the master component.

The following OSC messages reflect the same DSP code either compiled normally, or in polyphonic mode (only part of the OSC hierarchies are displayed here):

FIGURE

The polyphonic instrument allocation takes the DSP to be used for one voice, the desired number of voices, the dynamic voice allocation state, and the group state which controls if separated voices are displayed or not:

```c++
dsp* poly = new mydsp_poly(dsp, 2, true, true);
```

With the following code, note that a polyphonic instrument may be used outside of a MIDI control context, so that all voices will be always running and possibly controlled with OSC messages for instance:

```c++
dsp* poly = new mydsp_poly(dsp, 8, false, true);
```



#### Controlling the Polyphonic Instrument

The `mydsp_poly` class is also ready for MIDI control and can react to keyon/keyoff and pitch-wheel messages. Other MIDI control parameters can directly be added in the DSP source code.

#### Deploying the Polyphonic Instrument

Several architecture files and associated scripts have been updated to handle polyphonic instruments:

As an example on OSX, the script `faust2caqt foo.dsp` can be used to create a polyphonic CoreAudio/QT application. The desired number of voices is either declared in a nvoices metadata or changed with the `-nvoices num` additional parameter. MIDI control is activated using the `-midi` parameter.

The number of allocated voices can possibly be changed at runtime using the` -nvoices` parameter to change the default value (so using `./foo -nvoices 16` for instance). Several other scripts have been adapted using the same conventions.



#### Polyphonic Instrument with a global output effect

Polyphonic instruments may be used with an output effect. Putting that effect in the main Faust code is not a good idea since it would be instantiated for each voice which would be very inefficient. This is a typical use case for the `dsp_sequencer` class previously presented with the polyphonic DSP connected in sequence with a unique global effect:

```
faustcaqt inst.dsp -effect effect.dsp
```

with `inst.dsp` and `effect.ds`p in the same folder, and the number of outputs of the instrument matching the number of inputs of the effect, has to be used. A `dsp_sequencer` object will be created to combine the polyphonic instrument in sequence with the single output effect.

Polyphonic ready `faust2xx` scripts will then compile the polyphonic instrument and the effect, combine them in sequence, and create a ready to use DSP.



#### Proxy object



#### Other languages than C++

Most of the architecture files have been developed in C++ over the years. Thus they are ready to be used with the C++ backend and the one that generate C++ wrapped modules (like the LLVM, SOUL and Interp backends). For other languages, specific architecture files have to be written. Here is the current situation for other backends:

- the C backend needs the `CGlue` file, the `CInterface` file, and the [minimal-c](https://github.com/grame-cncm/faust/blob/master-dev/architecture/minimal.c) file is a simple example
- the experimental Rust backend can be used with the [minimal-rs](https://github.com/grame-cncm/faust/blob/master-dev/architecture/minimal.rs) architecture, or the more complex JACK `minimal-jack.rs`used in `faust2jackrust` script, or PortAudio `minimal-portaudio.rs` used in `faust2jackportaudio` script
- the experimental Dlang backend can be used with the [minimal.d](https://github.com/grame-cncm/faust/blob/master-dev/architecture/minimal.d) or the [minimal-dplug](https://github.com/grame-cncm/faust/blob/master-dev/architecture/minimal-dplug.d) to be used to generate [DPlug](https://dplug.org) plugins with the `faust2dplug` tool



**DSP statique (C/C++)  et dynamique LLMV Interprete**,  



### Using faust2xx scripts

Different `faust2xx` scripts finally combine architecture files to generate a ready-to-use applications or plugins from a Faust DSP program. They typically combine the generated DSP with an UI architecture file and an audio architecture file. 





DSP algebra

**Décrire MidiUI**

**Décrire le modèle faust2api**

#### Embedded platforms 

Agree on common metadata **[knob:N] [switch:N]**



Agred on metadat naiming



## Developing a new architecture file
