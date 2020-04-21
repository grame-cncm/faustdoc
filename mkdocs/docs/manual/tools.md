# Using the Faust Tools

While in its most *primitive* form, Faust is distributed as a command-line 
compiler, a wide range of tools have been developed around it in the course of 
the past few years. Their variety and their function might be hard to grab at 
first. This sort chapter provides an overview of their role and will hopefully 
help you decide which one is better suited for your personal use. 

The Faust tools is a set of scripts that take a dsp file as input to generate various output for a lot of architectures and platforms. All the tools names are in the form `faust2xxx` where `xxx` is the target architecture.




##  faust2alqt
<pre class=faust-tools>
Usage: faust2alqt [options] <file.dsp>
Target platform: Linux
Require: Alsa, Qt
Compiles Faust programs to alsa-qt
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -qrcode : activates QR code generation
   -poly :   produces a polyphonic DSP, ready to be used with MIDI events
</pre>


##  faust2alsa
<pre class=faust-tools>
Usage: faust2alsa [options] <file.dsp>
Target platform: Linux
Require: Alsa
Compiles Faust programs to alsa-gtk
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -qrcode : activates QR code generation
   -poly :   produces a polyphonic DSP, ready to be used with MIDI events
</pre>


##  faust2alsaconsole
<pre class=faust-tools>
Usage: faust2alsaconsole [options] <file.dsp>
Target platform: Linux
Require: Alsa
Compiles Faust programs to CLI alsa
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -arch32 : compiles a 32 bits binary
   -arch64 : compiles a 64 bits binary
</pre>


##  faust2android
<pre class=faust-tools>
Usage: faust2android [options] [Faust options] <file.dsp>
Target platform: Android
Require: Android SDK
Compile a Faust program to an Android app
Options:
   -osc :    activates OSC control
   -source : creates an eclipse project of the app in the current directory.
   -swig : regenerates the C++ and the JAVA interface for the native portion of the app.
   -faust : only carries out the Faust compilation and install the generated C++ file in the JNI folder.
   -reuse : preserves build directory and reuse it to speedup compilation.
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   -install : once compilation is over, installs the generated apk on the Android device connected to the computer
   -debug : activates verbose output
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2androidunity
<pre class=faust-tools>
Usage: faust2androidunity [options] [Faust options] <file1.dsp> [<file2.dsp>]
Target platform: Android Unity
Require: Android SDK Make sure the ANDROID_HOME environment variable is set to the sdk folder.
Creates android libraries (armeabi-v7a and x86) for faust unity plugin.
If you need other android architectures, open architecture/unity/Android/Application.mk and modify APP_ABI.
See architecture/unity/README.md for more info (also available from the compile folder)
Options:
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -android : creates also the c# and JSON files
</pre>


##  faust2api
<pre class=faust-tools>
Usage: faust2api [options] [Faust options] <file.dsp>
faust2api can be used to generate Faust based dsp objects for various platforms:

Ouput options:
   -ios :       generates an iOS API
   -android :   generates an Android API
   -coreaudio : generates an OSX CoreAudio API
   -alsa :      generates an ALSA API
   -jack :      generates a JACK API
   -portaudio : generates a PortAudio API
   -rtaudio :   generates an RTAudio API
   -of :        generates an openFrameworks API
   -juce :      generates a JUCE API
   -dummy :     generates a dummy audio API

Global options:
   -opt native|generic : activates the best compilation options for the native or generic CPU.
   -nvoices <num> : creates a polyphonic object with <num> voices.
   -effect <effect.dsp> : adds an effect to the polyphonic synth (ignored if -nvoices is not specified).
   -effect auto : adds an effect (extracted automatically from the dsp file) to the polyphonic synth (ignored if -nvoices is not specified).
   -nodoc : prevents documentation from being generated.
   -nozip : prevents generated files to be put in a zip file.
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.

Android specific options:
   -package : set the JAVA package name (e.g. '-package mypackage' will change the JAVA package name to 'mypackage.DspFaust'). The default package name is 'com.DspFaust.'
   -soundfile : add built-in Soundfile support to the API.

Options supported by iOS, CoreAudio, ALSA, JACK, PortAudio, openFrameworks and JUCE
   -midi : add built-in RtMidi support to the API.
   -osc : add built-in OSC support to the API.
   -soundfile : add built-in Soundfile support to the API.

JACK specific options
   -build : build a ready to test binary.
   -dynamic : add libfaust/LLVM dynamic DSP compilation mode.
</pre>


##  faust2au
<pre class=faust-tools>
Usage: faust2au [options] <file.dsp>
Target platform: MacOS
Compiles Faust programs to Audio Unit
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -install : 
   -debug : print all the build steps and keep intermediate build folder
</pre>


##  faust2bela
<pre class=faust-tools>
Usage: faust2bela [options] [Faust options] <file.dsp>
Target platform: Bela
Options:
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
                  Polyphonic mode means MIDI instrument with at least 1 voice. Use no arguments for a simple effect.
   -gui : activates a self-hosted GUI interface. Requires to have libmicrohttpd and libHTTPDFaust installed.
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI
   -tobela : to send C++ file into bela, and to run it.
</pre>


##  faust2caqt
<pre class=faust-tools>
Usage: faust2caqt [options] [Faust options] <file.dsp>
Target platform: MacOS
Require: Qt
Compiles Faust programs to CoreAudio and QT
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -qrcode : activates QR code generation
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   -opt native' to activate the best compilation options for the native CPU : 
   -opt generic' to activate the best compilation options for a generic CPU : 
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -resample : to resample soundfiles to the audio driver sample rate
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   -preset <directory> : add a preset manager on top of GUI and save the preset files in the given directory
   -preset auto : add a preset manager on top of GUI and save the preset files in a system temporary directory
   -me : to catch math computation exception (floating point exceptions and integer div-by-zero or overflow)
   -debug : to print all the build steps
   -nodeploy : skip self-contained application generation (using 'macdeployqt')
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2caqtios
<pre class=faust-tools>
#### qmake-ios is not available
#### you must create an alias named 'qmake-ios' that points to the appropriate qmake in your Qt ios dist
</pre>


##  faust2csound
<pre class=faust-tools>
Usage: faust2csound [options] [Faust options] <file.dsp>
Target platform: any
Require: CSound Dev Kit
Compiles a Faust program into a csound opcode
Options:
   -arch32 : generates a 32 bit architecture.
   -arch64 : generates a 64 bit architecture.
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2csvplot
<pre class=faust-tools>
Usage: faust2csvplot [options]  [Faust options] <file.dsp>
Compiles Faust programs to plotters
Options:
   -arch32 : generates a 32 bit architecture.
   -arch64 : generates a 64 bit architecture.
   -double : generates a 64 bit architecture.
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2dssi
<pre class=faust-tools>
Usage: faust2dssi [options] [Faust options] <file.dsp>
Compiles Faust programs to dssi plugins
Options:
   -osc :    activates OSC control
   -arch32 : generates a 32 bit architecture.
   -arch64 : generates a 64 bit architecture.
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2esp32
<pre class=faust-tools>
Usage: faust2esp32 [options] [Faust options] <file.dsp> <file.dsp>
faust2esp32 can be used to fully program the ESP32 microncontroller and to generate DSP objects
that can be integrated into any ESP32 project. 
Additional information about this tool can be found on the Faust website: https://faust.grame.fr.
Options:
   -gramophone : generates for GRAME Gramophone
   -multi :      generate for GRAME Gramophone in multi DSP mode
   -lib :       generates a package containing an object compatible with any ESP32 project
   -midi :   activates MIDI control
   -main :       add a 'main' entry point
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -wm8978 or -ac101 : to choose codec driver
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2faustvst
<pre class=faust-tools>
Usage: faust2faustvst [options ...] <file.dsp>
Require: VST SDK
Compiles Faust programs to VST plugins
Options:
   -osc :    activates OSC control
   -httpd :  activates HTTP control
   -gui :       build the plugin GUI.
   -keep :      retain the build directory.
   -nometa :    ignore metadata (author information etc.) from the Faust source
   -nomidicc :  plugin doesn't process MIDI control data.
   -notuning :  disable the tuning control (instruments only).
   -novoicectrls : no extra polyphony/tuning controls on GUI (instruments only)
   -nvoices N : number of synth voices (instruments only; arg must be an integer)
   -qt4, -qt5 : select the GUI toolkit (requires Qt4/5; implies -gui).
   -style S :   select the stylesheet (arg must be Default, Blue, Grey or Salmon).
Environment variables:
  FAUSTINC: specify the location of the Faust include directory
    Default: /usr/local/include
  FAUSTARCH: specify the location of the Faust VST library files
    Default: /usr/local/share/faust
  QMAKE: specify the location of the qmake binary
    Default: /usr/bin/qmake-qt5
  SDK: specify the location of the VST SDK
    Default: /usr/local/src/vstsdk
  SDKSRC: specify the location of the VST SDK sources
    Default: /usr/local/src/vstsdk/public.sdk/source/vst2.x
</pre>


##  faust2gen
<pre class=faust-tools>
Usage: faust2gen [options] <file.dsp>
Require: Max-MSP SDK
Compiles Faust programs to fausgen~ patch
Options:
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
</pre>


##  faust2ios
<pre class=faust-tools>
Usage: faust2ios [options] [Faust options] <file.dsp>
Target platform: iOS
Compiles Faust programs to iOS applications.
Options:
   -midi :   activates MIDI control
   -osc :    activates OSC control
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   -xcode :     to compile and keep the intermediate Xcode project
   -xcodeproj : to produce the intermediate Xcode project
   -archive :   to generate the archive for Apple Store
   -32bits :    to compile 32 bits only binary
   -noagc :     to deactivate audio automatic gain control
</pre>


##  faust2jack
<pre class=faust-tools>
Usage: faust2jack [options] [Faust options] <file.dsp>
Target platform: Linux
Require: Jack
Compiles Faust programs to JACK-GTK
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   -resample : to resample soundfiles to the audio driver sample rate.
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2jackconsole
<pre class=faust-tools>
Usage: faust2jackconsole [options] [Faust options] <file.dsp>
Require: Jack
Compiles Faust programs to JACK-console.
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2jackrust
<pre class=faust-tools>
Usage: faust2jackrust [options] [Faust options] <file.dsp>
Compiles Faust programs to JACK and Rust binary
Options:
   -source : only generates the source project.
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
faust2jackrust [-source] [additional Faust options (-vec -vs 8...)] <file.dsp>
</pre>


##  faust2jackserver
<pre class=faust-tools>
Usage: faust2jackserver [options] [Faust options] <file.dsp>
Require: Jack, Qt
Compiles Faust programs to JACK-QT (server mode)
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -qrcode : activates QR code generation
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2jaqt
<pre class=faust-tools>
Usage: faust2jaqt [options] [Faust options] <file.dsp>
Require: Jack, Qt
Compiles Faust programs to JACK-QT
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   -qrcode : activates QR code generation
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   -resample : to resample soundfiles to the audio driver sample rate.
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2jaqtchain
<pre class=faust-tools>
Usage: faust2jaqtchain [options] [Faust options] <file.dsp>
Require: Jack, Qt
Compiles several Faust programs to JACK-QT
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2juce
<pre class=faust-tools>
Usage: faust2juce [options] [Faust options] <file.dsp>
Require: Juce
Compiles Faust programs to JUCE standalone or plugin.
Options:
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   -standalone : to produce a standalone project, otherwise a plugin project is generated
   -jucemodulesdir <folder> : to set JUCE modules directory to <folder>, such as ~/JUCE/modules
   -jsynth :     to use JUCE polyphonic Synthesizer instead of Faust polyphonic code
   -llvm :       to use the LLVM compilation chain (OSX and Linux for now)
</pre>


##  faust2ladspa
<pre class=faust-tools>
Usage: faust2ladspa [options] [Faust options] <file.dsp>
Target platform: Linux
Compiles Faust programs to ladspa plugins
Options:
   -arch32 : generates a 32 bit architecture.
   -arch64 : generates a 64 bit architecture.
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2linuxunity
<pre class=faust-tools>
Usage: faust2linuxunity [options] [Faust options] <file.dsp>
Target platform: Linux
Require: Jack, Unity
Compiles Faust programs to Linux x86_64 library suitable for the Unity environment
Options:
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2lv2
<pre class=faust-tools>
Usage: faust2lv2 [options ...] <file.dsp>
Require: Qt
Compiles Faust programs to lv2 plugins
Options:
   -osc :    activates OSC control
   -httpd :  activates HTTP control
   -dyn-manifest : use dynamic manifests (requires LV2 host support).
   -gui :          build the plugin GUI (requires LV2 UI host support).
   -keep :         retain the build directory.
   -nometa :       ignore metadata (author information etc.) from the Faust source
   -nomidicc :     plugin doesn't process MIDI control data.
   -notuning :     disable the tuning control (instruments only).
   -novoicectrls : no extra polyphony/tuning controls on GUI (instruments only)
   -nvoices N :  number of synth voices (instruments only; arg must be an integer)
   -qt4, -qt5 :  select the GUI toolkit (requires Qt4/5; implies -gui).
   -style S :    select the stylesheet (arg must be Default, Blue, Grey or Salmon).
Environment variables:
  FAUSTINC: specify the location of the Faust include directory
    Default: /usr/local/include/faust
  FAUSTLIB: specify the location of the Faust LV2 library files
    Default: /usr/local/share/faust
  QMAKE: specify the location of the qmake binary
    Default: /usr/bin/qmake-qt5
</pre>


##  faust2mathdoc
<pre class=faust-tools>
Usage: faust2mathdoc [options] <file.dsp>
Require: svg2pdf pdflatex breqn
Generate a full Faust documentation, in a '*-mdoc' top directory
Options:
   -l LANG : LANG is usually a 2-lowercase-letters language name, like en, fr, or it.
   -utf8 : force file.dsp to be recoded in UTF-8 before being processed
</pre>


##  faust2max6
<pre class=faust-tools>
Usage: faust2max6 [options] [Faust options] <file.dsp>
Require: Max-MSP SDK
Compiles Faust programs to Max6 externals using double precision samples
Options:
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   -soundfile-static : similar to -soundfile with resources in statuc mode.
   -opt native|generic : activates the best compilation options for the native or generic CPU.
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -native :    to compile for the native CPU (otherwise the 'generic' mode is used by default)
   -universal : to generate a 64/32 bits external
   -nopatch :   to deactivate patch generation
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2msp
<pre class=faust-tools>
Usage: faust2msp [options] [Faust options] <file.dsp>
Require: Max-MSP SDK
Compiles Faust programs to Max6 externals using simple precision samples
Options:
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -native :    to compile for the native CPU (otherwise the 'generic' mode is used by default)
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2netjackconsole
<pre class=faust-tools>
Usage: faust2netjackconsole [options] [Faust options] <file.dsp>
Require: Jack
Compiles Faust programs to NetJack
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2netjackqt
<pre class=faust-tools>
Usage: faust2netjackqt [options] [Faust options] <file.dsp>
Require: Jack, Qt
Compiles Faust programs to NetJack and QT
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2nodejs
<pre class=faust-tools>
Usage: faust2nodejs [driver] [options] <file.dsp>
Generate Faust-based nodejs native addons. The generated addons can embed most of the audio engines supported by Faust: alsa, JACK, CoreAudio, RtAudio, PortAudio, etc. Since faust2nodejs essentially acts as a wrapper to faust2api, it offers the same features than this system (MIDI and OSC suport, polyphony, separate effect file, etc.).

The following drivers are available: -coreaudio // -alsa // -jack // -portaudio // -rtaudio // -dummy. For example, to create a native nodejs addon with a JACK audio engine, run: faust2nodjs -jack faustFile.dsp

The following options are inherited directly from faust2api and can be used with faust2nodejs:
Options:
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -soundfile : when compiling a DSP using the 'soundfile' primitive, add required resources
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -source : generates the source of the addon without compiling it.
   -electronv <VERSION> : allows to specify the current version of electron if generating an addon for this framework.
   -debug : prints compilation output.
</pre>


##  faust2osxiosunity
<pre class=faust-tools>
Usage: faust2osxiosunity [options] [Faust options] <file.dsp>
Target platform: MacOSX
Require: Unity
Compiles Faust programs to OSX/iOS libraries suitable for the Unity environment
Options:
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -ios :       create an iOS static library
   -universal : generate a 64/32 bits external
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
See architecture/unity/README.md for more info.
</pre>


##  faust2paqt
<pre class=faust-tools>
Usage: faust2paqt [options] [Faust options] <file.dsp>
Require: PortAudio, Qt
Compiles Faust programs to  PortAudio and Qt
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -qrcode : activates QR code generation
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   -nodeploy : skip self-contained application generation (using 'macdeployqt')
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2plot
<pre class=faust-tools>
Usage: faust2plot [options] [Faust options] <file.dsp>
Compiles Faust programs to plotters
Options:
   -s <n> :    start at the sample number <n> (default is 0)
   -n <n> :    render <n> samples (default is 16)
   -r <rate> : change the sample rate (default is 44100 Hz))
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2portaudiorust
<pre class=faust-tools>
Usage: faust2portaudiorust [options] [Faust options] <file.dsp>
Require: PortAudio
Compiles Faust programs to PortAudio and Rust binary
Options:
   -source : only generates the source project.
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2raqt
<pre class=faust-tools>
Usage: faust2raqt [options] [Faust options] <file.dsp>
Require: Qt
Compiles Faust programs to RtAudio-Qt
Options:
   -httpd :  activates HTTP control
   -osc :    activates OSC control
   -midi :   activates MIDI control
   -qrcode : activates QR code generation
   -poly :   produces a polyphonic DSP, ready to be used with MIDI events
   -nodeploy : skip self-contained application generation (using 'macdeployqt')
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2rpialsaconsole
<pre class=faust-tools>
Usage: faust2rpialsaconsole [options] [Faust options] <file.dsp>
Target platform: RaspberryPi
Require: Alsa
Compiles Faust programs to RaspberryPi - alsa console architecture
Options:
   -osc :    activates OSC control
   -httpd :  activates HTTP control
   -arch32 : generates a 32 bit architecture.
   -arch64 : generates a 64 bit architecture.
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2rpinetjackconsole
<pre class=faust-tools>
Usage: faust2rpialsaconsole [options] [Faust options] <file.dsp>
Target platform: RaspberryPi
Require: NetJack
Compiles Faust programs to RaspberryPi - netjack-console architecture
Options:
   -osc :    activates OSC control
   -httpd :  activates HTTP control
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2sam
<pre class=faust-tools>
Usage: faust2sam [options] [Faust options] <file.dsp>
Target platform: ADI SHARC Audio Module board
Generates inline Faust objects for the ADI SHARC Audio Module board
Options:
   -midi :   activates MIDI control
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2smartkeyb
<pre class=faust-tools>
FAUST2SMARTKEYB - MUSICAL MOBILE APP GENERATOR

faust2smartkeyb takes a Faust code as its main argument and convert it into a ready-to-use app for Android or iOS. The only two required arguments of faust2smartkeyb are a Faust file and the target platform (-android or -ios):

Usage: faust2smartkeyb [options] [Faust options] <file.dsp>
Target platform: iOS, Android
Options:
   -android : generates an Android app
   -ios :     generates an iOS app
   -osc :    activates OSC control
   -debug :   activate debug mode
   -effect :  allow to specify an effect Faust file (e.g., -effect myEffect.dsp)
   -install : install the app on the connected device (Android only)
   -nvoices : specify the max number of voices
   -reuse :  reuse the same project source
   -source :  only generate the source (no compilation)
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
More information and tutorials at: https://ccrma.stanford.edu/~rmichon/smartKeyboard
</pre>


##  faust2sndfile
<pre class=faust-tools>
Usage: faust2sndfile [Faust options] <file.dsp>
Require: libsndfile
Process files with Faust DSP
</pre>


##  faust2soul
<pre class=faust-tools>
Usage: faust2soul [options] [Faust options] <file.dsp>
Compiles Faust programs to SOUL
Options:
   -midi :   activates MIDI control
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   -play : to start the 'soul' runtime with the generated SOUL file
   Faust options : any faust option (e.g. -vec -vs 8...). See the faust compiler documentation.
</pre>


##  faust2unity
<pre class=faust-tools>
Usage: faust2unity [options] [Faust options] <file.dsp>
Target platform: Android, Linux, MacOSX, iOS, Windows
Require: Unity
Generates a unity package (compressed .unitypackage folder) with all available architecture libraries for faust unity plugin and the C# files required. Use arguments to generate specific architectures
Options:
   -w32 : generates a Windows 32 bits library
   -w64 : generates a Windows 64 bits library
   -osx : generates a macOS library
   -ios : generates an iOS library
   -android : generates Android libraries (armeabi-v7a and x86).
   -linux : generates a Linux library
   -nvoices <num> : produces a polyphonic DSP with <num> voices, ready to be used with MIDI events
   -source : generates the source files (uncompressed folder)
   -unpacked : generates an unpacked folder with files organized like the Unity Asset hierarchy. Use this options to add specific files in the unity package (in the Assets folder, then use 'encoderunitypackage <folder>' to compress and pack it.
See architecture/unity/README.md for more info.
</pre>


##  faust2wasm
<pre class=faust-tools>
Usage: faust2wasm [options] <file.dsp>
Compiles Faust programs to WASM modules
Options:
   -poly :   produces a polyphonic DSP, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   -opt : optimize the wasm module using Binaryen tools (https://github.com/WebAssembly/binaryen)
   -worklet : generates AudioWorklet compatible code
   -wap :     generates a WAP (Web Audio Plugin). This forces -worklet mode, and create additional files
   -comb :    combine several DSPs in a unique resulting 'comb.js' file, sharing the same Emscripten runtime
   -emcc :    compile C++ generated code to wasm with Emscripten, otherwise the internal wasm backend is used [experimental]
   -npm :     add a package.json file for npm package distribution
</pre>


##  faust2webaudiowasm
<pre class=faust-tools>
Usage: faust2webaudiowasm [options] <file.dsp>
Options:
   -poly :   produces a polyphonic DSP, ready to be used with MIDI events
   -effect <effect.dsp> : generates a polyphonic DSP connected to a global output effect, ready to be used with MIDI or OSC
   -effect auto : generates a polyphonic DSP connected to a global output effect defined as 'effect' in <file.dsp>, ready to be used with MIDI or OSC
   -opt : optimize the wasm module using Binaryen tools (https://github.com/WebAssembly/binaryen)
   -worklet : generates AudioWorklet compatible code
   -links :   add links to source code and SVG diagrams in the generated HTML file
   -emcc :    use the EMCC generated glue (mandatory when using 'soundfiles' in the DSP code) [experimental]
</pre>


##  faust2webaudiowast
<pre class=faust-tools>
Usage: faust2webaudiowast [options] <file.dsp>
Options:
   -poly :   produces a polyphonic DSP, ready to be used with MIDI events
   -opt :     optimize the wasm module using Binaryen tools (https://github.com/WebAssembly/binaryen)
   -worklet : generates AudioWorklet compatible code
   -links :   add links to source code and SVG diagrams in the generated HTML file
   -emcc :    compile C++ generated code to wasm with Emscripten, otherwise the internal wasm backend is used
</pre>

