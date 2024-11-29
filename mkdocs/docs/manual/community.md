# Material from the community

Here is a list of additional material contributed by the community of Faust developers or users.

## Articles, Video and Blog Posts


#### [About this filters business](https://lucaspanedda.github.io/2024/11/12/filters.html) 

A tutorial on Digital Filters in Faust.

#### [Exploring Pseudo-Random and Stochastic Signals](https://lucaspanedda.github.io/2024/11/15/random.html)

Exploring Pseudo-Random and Stochastic Signals in Digital Sound Synthesis Random and stochastic signals in synthesis can be useful for implementing time-varying oscillators and/or control signals.

#### [Generate WAMs with FaustIDE](http://www.webaudiomodules.com/docs/usage/generate-with-faustide/)
[Web Audio Modules](http://www.webaudiomodules.com) (WAM) ias a standard for Web Audio plugins and DAWs. The 2.0 version of Web Audio Modules has been released in 2021 as a group effort by a large set of people and since then, multiple plugins and hosts have been published, mostly as open source and free software.

The FAUST IDE is a very popular tool for [generating WAMs from existing FAUST code](http://www.webaudiomodules.com/docs/usage/generate-with-faustide) (and there are hundreds of source code example available for audio effects, instruments, etc.). You can [generate WAMs directly](http://www.webaudiomodules.com/docs/usage/generate-with-faust) from the command line using the [faust2wam script](https://github.com/Fr0stbyteR/faust2wam).

#### [Mozzi Revisited](https://www.pschatzmann.ch/home/2024/03/15/mozzi-revisited/)

Mozzi brings your Arduino to life by allowing it to produce much more complex and interesting growls, sweeps and chorusing atmospherics. These sounds can be quickly and easily constructed from familiar synthesis units like oscillators, delays, filters and envelopes and can be [programmed with Faust](https://github.com/pschatzmann/arduino-audio-tools/wiki/Faust).

#### [How to compile HISE and FAUST for Audio Plugin Development](https://www.youtube.com/watch?v=qHHShO4uOvI)

This video shows how you can use Faust inside [HISE](https://hise.dev). More info on how to use Faust in HISE can be found on the [HISE Faust forum](https://forum.hise.audio/category/14/faust-development).

#### [How to build Mod Duo plugin written in Faust](https://medium.com/@vlad.shcherbakov/deploying-a-faust-program-to-mod-duo-f2a588eaea7b)

This article shows how you can compile a Faust program to run on [Mod Duo](https://mod.audio).

#### [Handling infinity and not-a-number (NaN) values in Faust and C++ audio programming](https://www.dariosanfilippo.com/blog/2020/handling_inf_nan_values_in_faust_and_cpp/)  

This post by [Dario Sanfilippo](https://www.dariosanfilippo.com) discusses insights gained over a few years of audio programming to implement robust Faust/C++ software, particularly when dealing with infinity and NaN values.

#### [Three ways to implement recursive circuits in the Faust language](https://www.dariosanfilippo.com/blog/2020/faust_recursive_circuits/)  

This post by [Dario Sanfilippo](https://www.dariosanfilippo.com) is about the implementation of not-so-simple recursive circuits in the Faust language.  

#### [Make LV2 plugins with Faust](https://z-uo.medium.com/make-lv2-plugins-with-faust-ce58601ab3b9)  

This post by Nicola Landro is about making LV2 plugins with Faust.

#### [Getting started with Faust for SuperCollider](https://madskjeldgaard.dk/posts/getting-started-with-faust-for-supercollider/)  

This post by [Mads Kjeldgaard](https://madskjeldgaard.dk/pages/about/) is about using Faust with [SuperCollider](https://supercollider.github.io).

#### [Get Started Audio Programming with the FAUST Language](https://medium.com/@kmatthew/get-started-audio-programming-with-the-faust-language-75b854b6f7d4)  

This post by [Matt K](https://medium.com/@kmatthew) is about starting audio Programming with Faust. 

#### [Using Faust on the OWL family of devices](https://openwarelab.org/Faust)

This tutorial focus on using Faust and on features that are specific to OWL and the OpenWare firmware.

#### [I ported native guitar plugins to JavaScript (in-depth)](https://kutalia.medium.com/how-i-ported-native-musical-plugins-to-javascript-in-depth-dafa014dae01)

This post by Konstantine Kutalia is porting Faust coded Kapitonov Plugins Pack in JavaScript.

#### [Using Faust with the Arduino Audio Tools Library](https://www.pschatzmann.ch/home/2022/04/22/using-faust-dsp-with-my-arduino-audio-tools/)

A blog about using Faust with  Arduino Audio Tools.

#### [Writing a Slew Limiter in the Faust Language](https://www.youtube.com/watch?v=3WY0ikTFAe4)

A video about writing a Slew Limiter in the Faust Language by Julius Smith.

#### [Make an Eight Channel Mixer in the Faust IDE](https://www.youtube.com/watch?v=W4zyZisuAJ4)

A video about making an Eight Channel Mixer in the Faust IDE  by Julius Smith.

#### [Creating VSTs and more using FAUST](https://musichackspace.org/product/creating-vsts-and-more-using-faust/)

FAUST is a programming language that enables us to quickly create cross-platform DSP code. We can easily create VST plugins, Max-Externals and more. Its high-quality built-in library of effects and tools enables us to quickly draft high quality audio processing devices. The workshop aims at getting new users started, conveying what FAUST is good for and how to use it effectively to produce high quality results quickly.

## Various Tools

### Syntax Highlighting

#### [tree-sitter-faust](https://github.com/khiner/tree-sitter-faust)

[Tree-sitter](https://tree-sitter.github.io/) grammar Faust. Every Faust syntax feature should be supported. The npm package is [here](https://www.npmjs.com/package/tree-sitter-faust).

#### [Syntax Highlighting Files](https://github.com/grame-cncm/faust/tree/master-dev/syntax-highlighting)

This folder contains syntax highlighting files for various editors.

#### [Sublime Text syntax](https://github.com/nuchi/faust-sublime-syntax)

Sublime Text syntax file for the Faust programming language.

#### [Faust-Mode](https://github.com/rukano/emacs-faust-mode)

Major Emacs mode for the Faust programming language, featuring syntax highlighting, automatic indentation and auto-completion.

#### [Faustine](https://github.com/emacsmirror/faustine)

Faustine allows the edition of Faust code using emacs.

#### [faust neovim plugin](https://github.com/madskjeldgaard/faust-nvim)

Plugin to edit Faust code in the hyperextensible Vim-based text editor [neowim](http://neovim.io).
 
### Code Generators
 
#### [faust2pdex](https://github.com/jujudusud/BPD/tree/master/tools/faust2pdex)
 
 Generator of Faust wrappers for Pure Data. This software wraps the C++ code generated by Faust into a native external for Pure Data. You obtain a piece of source code that you can use with pd-lib-builder to produce a native binary with the help of make. No knowledge of C++ programming is required.

#### [Faust.quark](https://github.com/madskjeldgaard/faust.quark)

This SuperCollider package makes it possible to create SuperCollider packages (Quarks) containing plugins written in Faust code. With this, you can distribute plugins written in Faust and make it easy for others to install, compile or uninstall them. It also contains some simple interfaces for the `faust` and `faust2sc.py` commands used behind the scenes.

#### [ode2dsp](https://git.sr.ht/~kdsch/ode2dsp)

[ode2dsp](https://git.sr.ht/~kdsch/ode2dsp) is a Python library for generating ordinary differential equation (ODE) solvers in digital signal processing (DSP) languages. It automates the tedious and error-prone symbolic calculations involved in creating a DSP model of an ODE.

Features:

- Support linear and nonlinear systems of ODEs
- Support trapezoidal and backward Euler discrete-time integral approximations
- Approximate solutions of implicit equations using Newton's method
- Render finite difference equations (FDEs) to Faust code
- Calculate stability of ODEs and FDEs at an operating point

### Contributing

Feel free to contribute by [forking this project](https://docs.github.com/en/github/collaborating-with-pull-requests/working-with-forks) and [creating a pull request](https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request), or by mailing the library description [here](mailto:research@grame.fr).

