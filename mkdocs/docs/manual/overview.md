# Overview of the Faust Universe

While in its most *primitive* form, Faust is distributed as a command-line compiler, a wide range of tools have been developed around it in the course of the past few years. Their variety and their function might be hard to grab at first. This chapter provides an overview of their role and will hopefully help you decide which one is better suited for your personal use. 

<!-- TODO: it'd be nice to have some kind of figure here summarizing everything the various Faust branches should appear in this figure: we want something as complete as possible. -->

## The Faust Distribution

The Faust distribution hosts the source of the Faust compiler (both in its command line and library version), the source of the Faust *architectures* (targets), the various Faust compilation scripts, a wide range of Faust-related-tools, the [Faust DSP Libraries](https://faustlibraries.grame.fr) (which in practice are hosted a separate Git submodule), etc.

The latest stable release of the Faust distribution can be found [here](https://github.com/grame-cncm/faust/releases). It is recommended for most Faust users willing to compile the Faust compiler and libfaust from scratch.

To have the latest stable development version, you can use the `master branch` of the Faust [git repository](https://github.com/grame-cncm/faust/tree/master) which is hosted on GitHub. For something even more bleeding edge (to be used at your own risks), you might use the `master-dev` branch of the Faust [git repository](https://github.com/grame-cncm/faust/tree/master-dev). 
`master-dev` is the development sub-branch of `master`. It is used by Faust developers to commit  their changes and can be considered as "the main development branch". The goal is to make sure that `master` is always functional. Merges between `master-dev`  and `master` are carried out at each stable release by the GRAME team.

Also, note that pre-compiled packages of the Faust compiler and of libfaust for various platforms can be found on the of the [Faust website](https://faust.grame.fr).

The Faust distribution is organized as follows:

```
bin/           : contains the compiler and the [Faust tools](../tools)
include/       : contains header files required by the Faust tools
lib/           : contains the Faust libraries
share/         : contains documentation, the Faust libraries and architecture files
```

**Note**: you can install the Faust distribution anywhere you want, provided that the `faust` command is available from your PATH (requires to update your .profile if not in a standard location). 

The following subsections present the main tools build on top of the Faust compiler and intended to facilitate your life. 

## FaustLive

[FaustLive](https://github.com/grame-cncm/faustlive) is an advanced self-contained prototyping environment for the Faust programming language with an ultra-short edit-compile-run cycle. Thanks to its fully embedded compilation chain, FaustLive is simple [to install](https://github.com/grame-cncm/faustlive/releases) and doesn't require any external compiler, development toolchain or SDK to run.

FaustLive is the ideal tool for fast prototyping. Faust programs can be compiled and run on the fly by simple drag and drop. They can even be edited and recompiled while running, without sound interruption. It supports also native applications generation using the Faust online compiler.

## Faustgen

Faustgen is a Max/MSP external that provides features similar to FaustLive. It's the ideal tool for fast prototyping in Max/MSP. Faustgen is part of the [Faust](https://github.com/grame-cncm/faust) project, and distributed in the [Faust releases](https://github.com/grame-cncm/faust/releases).

## Faust Editor

 [Faust Editor](https://fausteditor.grame.fr) is a zero-conf tool that provides all the compilation services, including binaries generation for all the supported platforms and architectures.

## Faust IDE

[Faust IDE](https://faustide.grame.fr) is a zero-conf tool that provides all the compilation services, including binaries generation for all the supported platforms and architectures, but also various utilities for signal processing development.

## Faust Playground

[Faust Playground](https://faustplayground.grame.fr) is a graphical environment to develop Faust programs with a higher level approach. It has been initially designed for kids and for pedagogical purpose.
