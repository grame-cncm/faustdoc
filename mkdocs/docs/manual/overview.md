# Overview of the Faust Universe

While in its most *primitive* form, Faust is distributed as a command-line compiler, a wide range of additional tools for Faust have also been developed. While the variety and function of these tools might be hard to grasp at first, this chapter aims to provide an overview of their roles and will hopefully help you decide when you might want to use a given tool.

<!-- TODO: it'd be nice to have some kind of figure here summarizing everything the various Faust branches should appear in this figure: we want something as complete as possible. -->

## The Faust Distribution

The Faust distribution hosts the source of the Faust compiler (both in its command line and library version), the source of the Faust *architectures* (targets), the various Faust compilation scripts, a wide range of Faust-related-tools, the [Faust DSP Libraries](https://faustlibraries.grame.fr) (which in practice are hosted in a separate Git submodule), and more.

The latest stable release of the Faust distribution can be found [here](https://github.com/grame-cncm/faust/releases). It is recommended for Faust users who are willing to compile the Faust compiler and libfaust from scratch.

To have the latest stable development version, you can use the `master branch` of the Faust [git repository](https://github.com/grame-cncm/faust/tree/master) which is hosted on GitHub. For something even more bleeding edge (to be used at your own risk), you can use the `master-dev` branch of the Faust [git repository](https://github.com/grame-cncm/faust/tree/master-dev).
`master-dev` is the development sub-branch of `master`. It is used by Faust developers to commit their changes and can be considered the "main development branch". The goal is to make sure that `master` is always functional. Merges between `master-dev` and `master` are carried out at each stable release by the GRAME team.

Also, note that pre-compiled packages of the Faust compiler and of libfaust for various platforms can be found on the of the [Faust website](https://faust.grame.fr).

The Faust distribution is organized as follows:

<pre><code class="hljs markdown">bin/           : contains the compiler and the <a href="../tools">Faust tools</a>
include/       : contains header files required by the Faust tools
lib/           : contains the Faust libraries
share/         : contains documentation, the Faust libraries and architecture files</code></pre>

**Note**: you can install the Faust distribution anywhere you want, provided that the `faust` command is available from your PATH (this requires updating your .profile if it's not in a standard location). 

The following subsections present the main tools built on top of the Faust compiler that should make your life easier (while coding with Faust at least).

## Faust IDE

[Faust IDE](https://faustide.grame.fr) is a zero-conf tool that provides all the compilation services, including binaries generation for all the supported platforms and architectures, but also various utilities for signal processing development.

## Faust Editor

 [Faust Editor](https://fausteditor.grame.fr) is a zero-conf tool that provides all the compilation services, including binaries generation for all the supported platforms and architectures.

## Faust Playground

[Faust Playground](https://faustplayground.grame.fr) is a graphical environment to develop Faust programs with a higher level approach. It was designed for kids and for pedagogical purposes.

## Faustgen

Faustgen is a Max/MSP external that provides features similar to FaustLive. It's the ideal tool for fast prototyping in Max/MSP. Faustgen is part of the [Faust](https://github.com/grame-cncm/faust) project, and is distributed in the [Faust releases](https://github.com/grame-cncm/faust/releases).

## FaustLive

[FaustLive](https://github.com/grame-cncm/faustlive) is an advanced self-contained prototyping environment for the Faust programming language with an ultra-short edit-compile-run cycle. Thanks to its fully embedded compilation chain, FaustLive is simple [to install](https://github.com/grame-cncm/faustlive/releases) and doesn't require any external compiler, development toolchain or SDK to run.

FaustLive is the ideal tool for fast prototyping. Faust programs can be compiled and run on the fly just with a simple drag and drop. Programs can even be edited and recompiled while running, without sound interruption. FaustLive also supports native application generation using the Faust online compiler. **Note that FaustLive is regularly recompiled, but is no longer developed. It is recommended to use Faust IDE instead**.  
