# `faust2[...]` Tools

While in its most *primitive* form Faust is distributed as a command-line compiler, a wide range of tools has been developed around it in the course of the past few years. Their variety and function might be hard to grasp at first. This description provides an overview of their role and will hopefully help you decide which one is better suited for your personal use. 

The Faust tools are a set of scripts that take a DSP file as input to generate various outputs for many architectures and platforms. All tool names are of the form `faust2xx`, where `xx` is the target architecture. 

Use `-h` or `-help` to get more information on each script's options, the supported platforms, and any required packages. Additional Faust compiler options (like `-vec -lv 0 -I /path/to/lib`) can be given. For scripts that combine Faust and the C++ compiler, you can use the `CXXFLAGS` environment variable to provide additional options to the C++ compiler.

Note that some of the tools are somewhat *meta* tools because they are based on a framework that can itself generate several formats later on. This is the case of the `faust2juce` script, for instance.

Note that using the `-inj <f>` option allows you to inject a pre-existing C++ file (instead of compiling a DSP file) into the architecture-file machinery. Assuming that the C++ file implements a subclass of the base `dsp` class, the `faust2xx` scripts can be used to produce a ready-to-use application or plug-in that can take advantage of all existing UI and audio architectures. 

The `template-llvm.cpp` file that uses libfaust + the LLVM backend to dynamically compile a `foo.dsp` file is an example of this approach. It can be used with the `-inj` option in `faust2xx` tools like:
 
 - `faust2cagtk -inj template-llvm.cpp faust2cagtk-llvm.dsp` (a dummy DSP) to generate a monophonic `faust2cagtk-llvm` application.
  
 or:
 
 - `faust2cagtk -inj template-llvm.cpp -midi -nvoices 8 faust2cagtk-llvm.dsp`
 to generate a polyphonic (8 voices), MIDI controllable `faust2cagtk-llvm` application.
 
 Note that libfaust and the LLVM libraries still have to be added at the link stage, so a *-dyn : create libfaust + LLVM backend dynamic version* option has been added to the `faust2cagtk` tool and several others.


