# `faust2[...]` Tools

While in its most *primitive* form, Faust is distributed as a command-line compiler, a wide range of tools have been developed around it in the course of the past few years. Their variety and their function might be hard to grab at first. This sort chapter provides an overview of their role and will hopefully help you decide which one is better suited for your personal use. 

The Faust tools is a set of scripts that take a dsp file as input to generate various output for a lot of architectures and platforms. All the tools names are in the form `faust2xx` where `xx` is the target architecture.

Use `-h` or `-help` to get more information on each specific script options. Additional  Faust compiler options (like `-vec -lv 0 -I /path/to/lib`) can be given. For scripts that combines Faust and the C++ compiler, you can possibly use the  `CXXFLAGS ` environment variable to give additional options to the C++ compiler.

Note that using `-inj <f>` option allows to inject a pre-existing C++ file (instead of compiling a dsp file) into the architecture files machinery. Assuming that the C++ file implements a subclass of the base `dsp` class, the `faust2xx` scripts can possibly be used to produce a ready-to-use application or plugin that can take profit of all already existing UI and audio architectures. 
