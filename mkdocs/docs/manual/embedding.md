# Embedding the Faust Compiler Using libfaust

## Dynamic Compilation Chain

The Faust compiler uses an intermediate FIR representation (Faust Imperative Representation), which can be translated to several output languages. The FIR language describes the computation performed on the samples in a generic manner. It contains primitives to read and write variables and arrays, do arithmetic operations, and define the necessary control structures (`for` and `while` loops, `if` structure, etc.). 

To generate various output languages, several backends have been developed for C, C++, Interpreter, Java, LLVM IR, WebAssembly, etc. The Interpreter, LLVM IR and WebAssembly ones are particularly interesting since they allow the direct compilation of a DSP program into executable code in memory, bypassing the external compiler requirement.

## Using libfaust with the LLVM backend

### Libfaust with LLVM backend API

The complete chain goes from the Faust DSP source code, compiled in LLVM IR using the LLVM backend, to finally produce the executable code using the LLVM JIT. All steps take place in memory, getting rid of the classical file-based approaches. Pointers to executable functions can be retrieved from the resulting LLVM module and the code directly called with the appropriate parameters.

#### Creation API

The `libfaust` library exports the following API: 

- given a Faust source code (as a string or a file), calling the `createDSPFactoryFromString` or `createDSPFactoryFromFile` functions runs the compilation chain (Faust + LLVM JIT) and generates the *prototype* of the class, as a `llvm_dsp_factory` pointer. This factory actually contains the compiled LLVM IR for the given DSP
- alternatively the `createCPPDSPFactoryFromBoxes`allows to create the factory from a box expression built with the [box API](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/libfaust-box.h)
- alternatively the `createDSPFactoryFromSignals`allows to create the factory from a list of outputs signals built with the [signal API](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/libfaust-signal.h)
- the library keeps an internal cache of all allocated *factories* so that the compilation of the same DSP code -- that is the same source code and the same set of *normalized* (sorted in a canonical order) compilation options -- will return the same (reference counted) factory pointer 
- next, the `createDSPInstance` function (corresponding to the `new className` of C++) instantiates a `llvm_dsp` pointer to be used through its interface, connected to the audio chain and controller interfaces. When finished, `delete` can be used to destroy the dsp instance. Note that an instance internally needs to access its associated factory during its entire lifetime.   
- since `llvm_dsp` is a subclass of the `dsp` base class, an object of this type can be used with all the available `audio` and `UI` classes. In essence, this is like reusing [all architecture files](../manual/architectures.md) already developed for the static C++ class compilation scheme like `OSCUI`, `httpdUI` interfaces, etc.
- `deleteDSPFactory` has to be explicitly used to properly decrement the reference counter when the factory is not needed anymore, that is when all associated DSP instances have been properly destroyed
- a unique SHA1 key of the created factory can be obtained using its `getSHAKey` method

#### Saving/restoring the factory

After the DSP factory has been compiled, the application or the plugin running it might need to save it and then restore it. To get the internal factory compiled code, several functions are available:

- `writeDSPFactoryToIR`: get the DSP factory LLVM IR (in textual format) as a string 
- `writeDSPFactoryToIRFile`: get the DSP factory LLVM IR (in textual format) and write it to a file
- `writeDSPFactoryToBitcode`: get the DSP factory LLVM IR (in binary format) as a string 
- `writeDSPFactoryToBitcodeFile`: save the DSP factory LLVM IR (in binary format) in a file
- `writeDSPFactoryToMachine`: get the DSP factory executable machine code as a string
- `writeDSPFactoryToMachineFile`: save the DSP factory executable machine code in a file

To re-create a DSP factory from a previously saved code, several functions are available:

 - `readDSPFactoryFromIR`: create a DSP factory from a string containing the LLVM IR (in textual format) 
 - `readDSPFactoryFromIRFile`: create a DSP factory from a file containing the LLVM IR (in textual format)
 - `readDSPFactoryFromBitcode`: create a DSP factory from a string containing the LLVM IR (in binary format)
 - `readDSPFactoryFromBitcodeFile`: create a DSP factory from a file containing the LLVM IR (in binary format)
 - `readDSPFactoryFromMachine`: create a DSP factory from a string containing the executable machine code
 - `readDSPFactoryFromMachineFile`: create a DSP factory from a file containing the executable machine code.

### Typical code example

More generally, a typical use of `libfaust` in C++ could look like:

```c++
// The Faust code to compile as a string (could be in a file too)
string theCode = "import(\"stdfaust.lib\"); process = no.noise;";

// Compiling in memory (createDSPFactoryFromFile could be used alternatively)
llvm_dsp_factory* m_factory = createDSPFactoryFromString( 
  "faust", theCode, argc, argv, "", m_errorString, optimize);
// creating the DSP instance for interfacing
dsp* m_dsp = m_factory->createDSPInstance();

// Creating a generic UI to interact with the DSP
my_ui* m_ui = new MyUI();
// linking the interface to the DSP instance 
m_dsp->buildUserInterface(m_ui);

// Initializing the DSP instance with the SR
m_dsp->init(44100);

// Hypothetical audio callback, assuming m_input/m_output are previously allocated 
while (...) {
  m_dsp->compute(128, m_input, m_output);
}

// Cleaning
// Manually delete the DSP
delete m_dsp;
delete m_ui;
// The factory actually keeps track of all allocated DSP (done in createDSPInstance).
// So if not manually deleted, all remaining DSP will be garbaged here.
deleteDSPFactory(m_factory);
```

The first step consists in creating a DSP factory from a DSP file (using `createDSPFactoryFromFile`) or string  (using `createDSPFactoryFromString`) with additional parameters given to the compiler. Assuming the compilation works, a factory is returned, to create a DSP instance with the factory `createDSPInstance` method. 

Note that the resulting `llvm_dsp*` pointer type (see [`faust/dsp/llvm-dsp.h`](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/llvm-dsp.h) header file) is a subclass of the base `dsp` class (see [`faust/dsp/dsp.h`](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/dsp.h) header file). Thus it can be used with any `UI` type to plug a GUI, MIDI or OSC controller on the DSP object, like it would be done with a DSP program compiled to a C++ class (the generated `mydsp`  class is also a subclass of the base `dsp` class). This is demonstrated with the `my_ui* m_ui = new MyUI();` and `m_dsp->buildUserInterface(m_ui);` lines where the `buildUserInterface` method is used to connect a controller. 

Then the DSP object has to be connected to an audio driver to be rendered (see the `m_dsp->compute(128, m_input, m_output);` block). A more complete C++ example can be [found here](https://github.com/grame-cncm/faust/blob/master-dev/tests/llvm-tests/llvm-test.cpp). A example using the pure C API can be [found here](https://github.com/grame-cncm/faust/blob/master-dev/tests/llvm-tests/llvm-test.c). 


## Using libfaust with the Interpreter backend

When compiled to embed the [Interpreter backend](https://github.com/grame-cncm/faust/tree/master-dev/compiler/generator/interpreter), `libfaust` can also be used to generate the Faust Bytes Code (FBC) format and interpret it in memory.

### Libfaust with Interpreter backend API

The interpreter backend (described in [this paper](http://www.ifc18.uni-mainz.de/papers/letz.pdf)) has been first written to allow dynamical compilation on iOS, where Apple does not allow LLVM based JIT compilation to be deployed, but can also be used to [develop testing tools](../manual/debugging.md#the-interp-tracer-tool). It has been defined as a typed bytecode and a virtual machine to execute it.

The FIR language is simple enough to be easily translated in the typed bytecode for an interpreter, generated by a FIR to bytecode compilation pass. The virtual machine then executes the bytecode on a stack based machine.

#### Creation API

The interpreter backend API is similar to the LLVM backend API: 

- given a FAUST source code (as a file or a string),  calling the `createInterpreterDSPFactory`  function runs the compilation chain (Faust + interpreter backend) and generates the *prototype* of the class, as an `interpreter_dsp_factory` pointer. This factory actually contains the compiled bytecode for the given DSP
- alternatively the `createInterpreterDSPFactoryFromBoxes` allows to create the factory from a box expression built with the [box API](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/libfaust-box.h)
- alternatively the `createInterpreterDSPFactoryFromSignals` allows to create the factory from a list of outputs signals built with the [signal API](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/libfaust-signal.h)
- the library keeps an internal cache of all allocated *factories* so that the compilation of the same DSP code -- that is the same source code and the same set of *normalized* (sorted in a canonical order) compilation options -- will return the same (reference counted) factory pointer 
- next, the `createDSPInstance` method of the factory class, corresponding to the `new className` of C++, instantiates an `interpreter_dsp` pointer, to be used as any regular Faust compiled DSP object, run and controlled through its interface. The instance contains the interpreter virtual machine loaded with the compiled bytecode, to be executed for each method. When finished, `delete` can be used to destroy the dsp instance. Note that an instance internally needs to access its associated factory during its entire lifetime. 
- since ``interpreter_dsp`` is a subclass of the `dsp` base class, an object of this type can be used with all the available `audio` and `UI` classes. In essence, this is like reusing [all architecture files](../manual/architectures.md) already developed for the static C++ class compilation scheme like `OSCUI`, `httpdUI` interfaces, etc.
- `deleteInterpreterDSPFactory` has to be explicitly used to properly decrement the reference counter when the factory is not needed anymore, that is when all associated DSP instances have been properly destroyed. 
- a unique SHA1 key of the created factory can be obtained using its `getSHAKey` method

#### Saving/restoring the factory

After the DSP factory has been compiled, the application or plugin may want to save/restore it in order to save Faust to interpreter bytecode compilation at next use. To get the internal factory bytecode and save it, two functions are available:

  - `writeInterpreterDSPFactoryToMachine` allows to get the interpreter bytecode as a string
  - `writeInterpreterDSPFactoryToMachineFile` allows to save the interpreter bytecode in a file

To re-create a DSP factory from a previously saved code, two functions are available:

  - `readInterpreterDSPFactoryFromMachine`allows to create a DSP factory from a string containing the interpreter bytecode
  - `readInterpreterDSPFactoryFromMachineFile` allows to create a DSP factory from a file containing the interpreter bytecode

The complete API is available and documented in the installed [faust/dsp/interpreter-dsp.h](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/interpreter-dsp.h) header. Note that only the scalar compilation mode is supported. A more complete C++ example can be [found here](https://github.com/grame-cncm/faust/blob/master-dev/tests/interp-tests/interp-test.cpp). 

### Performances

The generated code is obviously much slower than LLVM generated native code. Measurements on various DSPs examples have been done, and the code is between 3 and more than 10 times slower than the LLVM native code.


## Using libfaust with the WebAssembly backend

The libfaust C++ library can be compiled in WebAssembly with [Emscripten](https://emscripten.org/), and used in the web  or NodeJS platforms. A [specific page on the subject](../manual/deploying.md) is available. 

## Additional Functions

Some additional functions are available in the `libfaust` API:

- **Expanding the DSP code**. The`expandDSPFromString`/`expandDSPFromFile` functions can be used to generate a self-contained DSP source string where all needed librairies have been included. All compilations options are normalized and included as a comment in the expanded string. This is a way to create self-contained version of DSP programs.

- **Using other backends or generating auxiliary files**. The `generateAuxFilesFromString` and `generateAuxFilesFromFile` functions taking a DSP source string or file can be used:
    - to activate and use other backends (depending of which ones have been compiled in libfaust) to generate like C, C++, or Cmajor code, etc. The `argv` parameter has to mimic the command line like for instance: `-lang cpp -vec -lv 1` to generate a C++ file in vector mode.
    - to generate auxiliary files which can be text files SVG, XML, ps, etc. The `argv` parameter has to mimic the command line like for instance: `-json` to generate a JSON file.

## Sample size adaptation

When compiled with the `-double` option, the generated code internally uses `double` format for samples, but also expects inputs/outputs buffers to be filled with samples in double. The `dsp_sample_adapter` decorator class defined in [faust/dsp/dsp-adapter.h](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/dsp-adapter.h) can be used to adapt the buffers. 

## Deployment

The application or plugin using `libfaust` can embed the library either as a statically linked component (to get a self-contained binary) or provided as a separate component to be loaded dynamically at runtime. The Faust libraries themselves usually have to be bundled separately and can be accessed at runtime using the compiler `-I /path/to/libraries` option in `createDSPFactoryFromString/createDSPFactoryFromFile` functions.

## Additional Resources 

Some papers and tutorials are available:

- [Comment Embarquer le Compilateur Faust dans Vos Applications ?](https://hal.archives-ouvertes.fr/hal-00832224)
- [An Overview of the FAUST Developer Ecosystem](https://hal.archives-ouvertes.fr/hal-02158929)
- [Using the box API](../tutorials/box-api.md)
- [Using the signal API](../tutorials/signal-api.md)

## Use Case Examples

The dynamic compilation chain has been used in several projects:

* [FaustLive](https://github.com/grame-cncm/faustlive): an integrated IDE for Faust development offering on-the-fly compilation and execution features

* [Faustgen](https://github.com/grame-cncm/faust/tree/master-dev/embedded/faustgen): a generic Faust [Max/MSP](https://cycling74.com/products/max/) programmable external object

* [Faustgen](https://github.com/CICM/pd-faustgen): a generic Faust [PureData](https://puredata.info) programmable external object

* The [faustgen2~](https://github.com/agraef/pd-faustgen) object is a Faust external for Pd a.k.a. Pure Data, Miller Puckette's interactive multimedia programming environment

* [Faust for Csound](https://github.com/csound/csound/blob/develop/Opcodes/faustgen.cpp): a [Csound](https://csound.com/) opcode running the Faust compiler internally

* [LibAudioStream](https://github.com/sletz/libaudiostream): a framework to manipulate audio ressources through the concept of streams

* [Faust for JUCE](https://github.com/olilarkin/juce_faustllvm): a tool integrating the Faust compiler to [JUCE](https://juce.com/) developed by Oliver Larkin and available as part of the [pMix2 project](https://github.com/olilarkin/pMix2)

* An experimental integration of Faust in [Antescofo](http://forumnet.ircam.fr/product/antescofo-en/)

* [FaucK](https://github.com/ccrma/chugins/tree/main/Faust): the combination of the [ChucK Programming Language](http://chuck.cs.princeton.edu/) and Faust

* [libossia](https://github.com/ossia/libossia) is a modern C++, cross-environment distributed object model for creative coding. It is used in [Ossia score](https://github.com/ossia/score) project

* [Radium](https://users.notam02.no/~kjetism/radium/) is a music editor with a new type of interface, including a Faust audio DSP development environment using libfaust with the LLVM and Interpreter backends

* [Mephisto LV2](https://git.open-music-kontrollers.ch/~hp/mephisto.lv2) is a Just-in-Time Faust compiler embedded in an LV2 plugin, using the C API.

* [gwion-plug](https://github.com/Gwion/gwion-plug/tree/master/Faust) is a Faust plugin for the [Gwion](https://github.com/Gwion/Gwion) programming language. 

* [FaustGen](https://github.com/madskjeldgaard/faustgen-supercollider/) allows to livecode Faust in SuperCollider. It uses the libfaust LLVM C++ API.

* [FAUSTPy](https://github.com/marcecj/faust_python) is a Python wrapper for the Faust DSP language. It is implemented using the CFFI and hence creates the wrapper dynamically at run-time. A updated version of the project is available on [this fork](https://github.com/hrtlacek/faust_python).

* [Faust.jl](https://github.com/corajr/Faust.jl) is Julia wrapper for the Faust compiler. It uses the libfaust LLVM C API.

* [fl-tui](https://gitlab.com/raoulhc/fl-tui) is a Rust wrapper for the Faust compiler. It uses the libfaust LLVM C API.

* [faustlive-jack-rs](https://codeberg.org/obsoleszenz/faustlive-jack-rs) is another Rust wrapper for the Faust compiler, using [JACK](https://jackaudio.org) server for audio. It uses the libfaust LLVM C API.

* [DawDreamer](https://github.com/DBraun/DawDreamer) is an audio-processing Python framework supporting core DAW features. It uses the libfaust LLVM C API.

* [metaSurface64](https://github.com/dblanchemain/metaSurface) is a real-time continuous sound transformation control surface that features both its own loop generator for up to 64 voices and a multi-effects FX engine.  It uses the libfaust LLVM C++ API.

* [metaFx](https://faust.grame.fr/community/powered-by-faust/#metafx) is a control surface for continuous sound transformations in real time, just like the metaSurface64.
Like metaSurface64, it has both its own loop generator and a multi-effects FX engine, but its operation is different, especially for the management of plugin chains and pads.

* [HISE](http://www.hise.audio) is an open source framework for building sample based virtual instruments combining a highly performant Disk-Streaming Engine, a flexible DSP-Audio Module system and a handy Interface Designer.

* [AMATI](https://github.com/glocq/Amati) is a VST plugin for live-coding effects in the Faust programming language.

* [cyfaust](https://github.com/shakfu/cyfaust) is a cython wrapper of the Faust interpreter and the RtAudio cross-platform audio driver, derived from the [faustlab](https://github.com/shakfu/faustlab) project. The objective is to end up with a minimal, modular, self-contained, cross-platform python3 extension.

* [nih-faust-jit](https://github.com/YPares/nih-faust-jit) ia a plugin written in Rust to load Faust dsp files and JIT-compile them with LLVM. A simple GUI is provided to select which script to load and where to look for the Faust libraries that this script may import. The selected DSP script is saved as part of the plugin state and therefore is saved with your DAW project.

* [QLFAUST](https://github.com/njazz/QLFAUST) is plugin for FAUST Programming Language using the [FaustSwiftUI](https://github.com/njazz/FaustSwiftUI) project, a SwiftUI-based dynamic UI renderer for Faust DSP JSON metadata. It parses the Faust UI JSON structure and displays corresponding SwiftUI controls like sliders, toggles, buttons, bargraphs etc.

