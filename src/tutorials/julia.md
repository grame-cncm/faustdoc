

# Using Faust in Julia

In this tutorial, we present how Faust can be used in [Julia](https://julialang.org/), a high-level, high-performance, dynamic programming language. While it is a general-purpose language and can be used to write any application, many of its features are well suited for numerical analysis and computational science.

A [Julia backend](https://github.com/grame-cncm/faust/tree/master-dev/compiler/generator/julia) has recently be added in the Faust compiler. It allows to generate ready to use Julia code from any Faust DSP program. On the other hand, an [integration of the libfaust compiler](https://github.com/corajr/Faust.jl) in Julia has been developed by [Cora Johnson-Roberson](https://corajr.com), but will not be covered by this tutorial.

Note that this tutorial demonstrates a *Work In Progress*, since the Faust Julia integration is not yet distributed as a proper Julia package. This will be the next step, probably adding the *Julia backend in the Faust compiler* approach in the Cora Johnson-Roberson libfaust based package. 

#### Who is this tutorial for?

The [first section](#using-command-line-tools) assumes a working [Faust compiler installed](https://github.com/grame-cncm/faust) on the machine, so is more designed for regular Faust users. The [second section](#using-the-faust-web-ide) is better suited for Julia users who want to discover Faust and test the produced Julia code.  

## Installing the required packages

With a fresh Julia install, all required packages are decribed in the [packages.jl](https://raw.githubusercontent.com/grame-cncm/faust/master-dev/architecture/julia/packages.jl) file:

 - in case you have an installed Faust version, it can be installed with the `julia packages.jl` command done in the `architecture/julia` folder of the Faust repository
 - of directly downloaded, and executed with the `julia packages.jl` command

## Using command line tools

### Generating Julia code

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

 The Julia code can be generated using:

```bash
faust -lang julia osc.dsp -o osc.jl
```

This will generate a `mydsp{T}` data structure, as a subtype of the `abstract type dsp`, with a set of methods to manipulate it. The generated API simply follows [the one defined](https://github.com/grame-cncm/faust/blob/master-dev/architecture/julia/dsp/dsp.jl) for the base `dsp` type. This API basically mimics the [one defined for the C++ backend](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/dsp.h).

The resulting file is not self-contained and so cannot be directly compiled using the **julia** program:

```bash
julia osc.jl
ERROR: LoadError: UndefVarError: dsp not defined
...
```

Some additional types like `FAUSTFLOAT`, `dsp`, `Meta` and `UI` have to be defined in a so-called [architecture files](https://faustdoc.grame.fr/manual/architectures/). The Julia specific ones are [described here](https://github.com/grame-cncm/faust/tree/master-dev/architecture/julia#julia-architecture-files). A simple one named [minimal.jl](https://github.com/grame-cncm/faust/blob/master-dev/architecture/julia/minimal.jl) can be used for that with the following command:

```bash
faust -lang julia osc.dsp -a julia/minimal.jl -o osc.jl
```

Now the resulting **foo.jl **file is self-contained and can be executed with: 

```bash
julia -i osc.jl (here -i to stay in interactive mode)
```

Which compiles the Julia code, executes it and produces:

```bash
Application name: osc

getNumInputs: 0
getNumOutputs: 2

Path/UIZone dictionary: Dict{String, UIZone}("/Oscillator/volume" => UIZone(:fHslider0, 0.0f0, -96.0f0, 0.0f0, 0.1f0), "/Oscillator/freq2" => UIZone(:fHslider2, 1000.0f0, 20.0f0, 3000.0f0, 1.0f0), "/Oscillator/freq1" => UIZone(:fHslider1, 1000.0f0, 20.0f0, 3000.0f0, 1.0f0))

```
With the name of the application, the number of input/output channels, the set of controller paths with their range, and a display of the first samples of the computed outputs (using the powerfull [Plots.jl](http://docs.juliaplots.org/latest/) package), and showing here the effect of the `si.smoo` at the beginning of the signals:

<img src="img/osc-display.png" class="mx-auto d-block" width="60%">
<center>*Displaying the outputs*</center>


### Looking at the generated code

A `mydsp{T}` data structure, as a subtype of the `abstract type dsp` is generated, and contains the field definitions with their types, as well as a constructor initializing them:

```julia
mutable struct mydsp{T} <: dsp
	fSampleRate::Int32 
	fConst1::T 
	fHslider0::FAUSTFLOAT 
	fConst2::T 
	fRec0::Vector{T} 
	fConst3::T 
	fHslider1::FAUSTFLOAT 
	fRec2::Vector{T} 
	fHslider2::FAUSTFLOAT 
	fRec3::Vector{T} 
	iVec0::Vector{Int32} 
	iRec1::Vector{Int32} 
	ftbl0mydspSIG0::Vector{T} 
	mydsp{T}() where {T} = begin
		dsp = new{T}()
		dsp.fRec0 = zeros(T, 2)
		dsp.fRec2 = zeros(T, 2)
		dsp.fRec3 = zeros(T, 2)
		dsp.iVec0 = zeros(Int32, 2)
		dsp.iRec1 = zeros(Int32, 2)
		dsp.ftbl0mydspSIG0 = zeros(T, 65536)
		dsp
	end
end
```
Note that the structure is parametrized with a `{T}` type to be given at initialization time. The `const REAL = Float32` or `const REAL = Float64`  line is generated depending of the `-single` (default), or `-double` option given at compilation time, and can be used for that. 

Several access methods are generated:

```julia
function getNumInputs(dsp::mydsp{T}) where {T}
	return Int32(0) 
end
function getNumOutputs(dsp::mydsp{T}) where {T}
	return Int32(2) 
end
```

Several initialiation methods like `init!`, `initanceInit!`, `instanceResetUserInterface!` etc. are generated, here is one of them:

```julia
function instanceResetUserInterface!(dsp::mydsp{T}) where {T}
	dsp.fHslider0 = FAUSTFLOAT(0.0f0) 
	dsp.fHslider1 = FAUSTFLOAT(1000.0f0) 
	dsp.fHslider2 = FAUSTFLOAT(200.0f0) 
end
```

The `buildUserInterface!` method uses a [UI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/julia/gui/UI.jl) subtype to build a controller, which could be a Graphical User Interface (for instance using [GTK](https://github.com/grame-cncm/faust/blob/master-dev/architecture/julia/gui/GTKUI.jl)), or an [OSC](https://github.com/grame-cncm/faust/blob/master-dev/architecture/julia/gui/OSCUI.jl) controller:


```julia
function buildUserInterface!(dsp::mydsp{T}, ui_interface::UI) where {T}
	openVerticalBox!(ui_interface, "Oscillator") 
	declare!(ui_interface, :fHslider1, "unit", "Hz") 
	addHorizontalSlider!(ui_interface, "freq1", :fHslider1, FAUSTFLOAT(1000.0f0), FAUSTFLOAT(20.0f0), FAUSTFLOAT(3000.0f0), FAUSTFLOAT(1.0f0)) 
	declare!(ui_interface, :fHslider2, "unit", "Hz") 
	addHorizontalSlider!(ui_interface, "freq2", :fHslider2, FAUSTFLOAT(500.0f0), FAUSTFLOAT(20.0f0), FAUSTFLOAT(3000.0f0), FAUSTFLOAT(1.0f0)) 
	declare!(ui_interface, :fHslider0, "unit", "dB") 
	addHorizontalSlider!(ui_interface, "volume", :fHslider0, FAUSTFLOAT(0.0f0), FAUSTFLOAT(-96.0f0), FAUSTFLOAT(0.0f0), FAUSTFLOAT(0.1f0)) 
	closeBox!(ui_interface)
end
```

The DSP structure fields to access are simply described with their name (actually a [Symbol](https://docs.julialang.org/en/v1/manual/metaprogramming/#Symbols) in Julia terminology), and can later be used with the standard [setproperty!](https://docs.julialang.org/en/v1/base/base/#Base.setproperty!) and [getproperty](https://docs.julialang.org/en/v1/base/base/#Base.getproperty) access methods, like in the `setParamValue!` and `getParamValue`methods written in the [MapUI](https://github.com/grame-cncm/faust/blob/master-dev/architecture/julia/gui/MapUI.jl) architecture.

And finally the `compute!` method that processes and input buffer with `count` frames to produce an output buffer: 


```julia
@inbounds function compute!(dsp::mydsp, count::Int32, inputs, outputs)
	output0 = @inbounds @view outputs[:, 1]
	output1 = @inbounds @view outputs[:, 2]
	fSlow0::Float32 = (dsp.fConst1 * pow(10.0f0, (0.0500000007f0 * Float32(dsp.fHslider0)))) 
	fSlow1::Float32 = (dsp.fConst3 * Float32(dsp.fHslider1)) 
	fSlow2::Float32 = (dsp.fConst3 * Float32(dsp.fHslider2)) 
	@inbounds for i0 in 0:count-1
		dsp.fRec0[1] = (fSlow0 + (dsp.fConst2 * dsp.fRec0[2])) 
		dsp.fRec2[1] = (fSlow1 + (dsp.fRec2[2] - floor((fSlow1 + dsp.fRec2[2])))) 
		output0[i0+1] = FAUSTFLOAT((dsp.fRec0[1] 
        * dsp.ftbl0mydspSIG0[trunc(Int32, (65536.0f0 * dsp.fRec2[1]))+1])) 
		dsp.fRec3[1] = (fSlow2 + (dsp.fRec3[2] - floor((fSlow2 + dsp.fRec3[2])))) 
		output1[i0+1] = FAUSTFLOAT((dsp.fRec0[1] 
        * dsp.ftbl0mydspSIG0[trunc(Int32, (65536.0f0 * dsp.fRec3[1]))+1])) 
		dsp.fRec0[2] = dsp.fRec0[1] 
		dsp.fRec2[2] = dsp.fRec2[1] 
		dsp.fRec3[2] = dsp.fRec3[1] 
	end
end
```
**Note** that not all generated methods are presented in this short presentation. Look at the generated **osc.jl** file to see all of them.

### Using the generated code

Some globals have to be defined:

```julia
# Testing
samplerate = Int32(44100)
block_size = Int32(16)
```

The DSP object has to be created and initialized, here using the generated `REAL` type alias:

```julia
# Init DSP
my_dsp = mydsp{REAL}()
init!(my_dsp, samplerate)
```

His name can be extracted from the DSP metadata using the following code:

```julia
# Retrieve the application name
mutable struct NameMeta <: Meta
    name::String
end

function declare!(m::NameMeta, key::String, value::String)
    if (key == "name") 
        m.name = value;
    end
end)

m = NameMeta("")
metadata!(my_dsp, m)
println("Application name: ", m.name, "\n")
```

The number of inputs/outputs can be printed:

```julia
println("getNumInputs: ", getNumInputs(my_dsp))
println("getNumOutputs: ", getNumOutputs(my_dsp), "\n")
```

Infomation on all controllers can be retrieved using the `MapUI` type:

```julia
# Create a MapUI controller
map_ui = MapUI(my_dsp)
buildUserInterface!(my_dsp, map_ui)

# Print all zones
println("Path/UIZone dictionary: ", getZoneMap(map_ui), "\n")   
```

And finally one buffer can be processed with the following code, here giving `FAUSTFLOAT` as the actual type for external samples:

```julia
inputs = zeros(FAUSTFLOAT, block_size, getNumInputs(my_dsp))
outputs = zeros(FAUSTFLOAT, block_size, getNumOutputs(my_dsp)) 
compute!(my_dsp, block_size, inputs, outputs)
println("One computed output buffer: ", outputs)
```

Now the **osc.jl** can possibly be directly integrated in a larger project, or customised using an adapted new architecture file. 

### The faust2portaudiojulia tool

The Faust DSP program can be compiled and run with the more sophisticated [faust2portaudiojulia](https://github.com/grame-cncm/faust/tree/master-dev/architecture/julia#faust2portaudiojulia) tool which will render it using the [PortAudio.jl](https://juliapackages.com/p/portaudio) package to access the audio driver, [OpenSoundControl.jl](https://juliapackages.com/p/opensoundcontrol) package for OSC control, and [GTK.jl](http://juliagraphics.github.io/Gtk.jl/latest/) package for the Graphical User Interface.

The **faust2portaudiojulia** tool use this [portaudio_gtk.jl](https://github.com/grame-cncm/faust/blob/master-dev/architecture/julia/portaudio_gtk.jl) architecture file. When used the following way:

```bash
faust2portaudiojulia osc.dsp
```

It creates an **osc.jl** file that can simply be executed using:

```bash
julia osc.jl
```

So the stereo program generating sinewaves at 1000 Hz and 200 Hz by default is now playing, without any interface to control it.

Now using the following command:

```bash
faust2portaudiojulia -play 2 osc.dsp
```

Will create the **osc.jl** file, directly execute it using **Julia**, with PortAudio based audio rendering and GTK GUI (and with 2 threads needed for GTK and audio). **Note** that the GUI is still quite simple:

<img src="img/osc-gtk.png" class="mx-auto d-block" width="55%">
<center>*The GTK based controller*</center>


The following command:

```bash
faust2portaudiojulia -play 2 -osc osc.dsp
```

Will create the **osc.jl** file, directly execute it using **Julia**, with PortAudio based audio rendering and OSC control (and with 2 threads needed for OSC and audio).  Now the application starts with an OSC controller running on ports 5000 and 5001:

```bash
getNumInputs: 0
getNumOutputs: 2

Dict{String, UIZone}("/Oscillator/volume" => UIZone(:fHslider0, 0.0f0, -96.0f0, 0.0f0, 0.1f0), "/Oscillator/freq2" => UIZone(:fHslider2, 500.0f0, 20.0f0, 3000.0f0, 1.0f0), "/Oscillator/freq1" => UIZone(:fHslider1, 1000.0f0, 20.0f0, 3000.0f0, 1.0f0))

Faust OSC application 'Oscillator' is running on UDP ports 5000, 5001
```

Direct OSC commands can be sent, as [explained here](https://faustdoc.grame.fr/manual/osc/). So for instance to change both channel frequencies:

```bash
 oscsend localhost 5000 /Oscillator/freq1 f 400
 oscsend localhost 5000 /Oscillator/freq2 f 960
```

You can possibly use the [faust-osc-controller](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faust-osc-controller) tool to remotely control the Julia program, with the following command:


```bash
faust-osc-controller /Oscillator -port 5001 -outport 5000 -xmit 1
```

<img src="img/faust-osc-controller.png" class="mx-auto d-block" width="50%">
<center>*The faust-osc-controller OSC controller*</center>

And finally the `faust-osc-controller` tool can be automatically started along the OSC receiver with the `faust2portaudiojulia -play 2 -oscc osc.dsp` command.

## Using the Faust Web IDE

Faust DSP program can be written, tested in the [Faust Web IDE](https://faustide.grame.fr/) and generated as embeddable Julia code, or possibly as working audio applications.

### Generating the pure Julia output

The output of the Julia backend can directly be generated using the *Platform = source* and *Architecture = julia* export options. As previouly explained, the resulting file is not self-contained, but shows the code which has to be wrapped with adapted Julia architecture files.

<img src="img/export.png" class="mx-auto d-block" width="40%">
<center>*Exporting the code*</center>

### Generating a minimal working Julia file

The *Platform = julia* and *Architecture = julia* export options allow to generate a self-contained file using the `minimal.jl`architecture. It can simply by started with the following command:

```bash
julia -i foo.jl (here -i to stay in interactive mode)
```

### Generating an audio application controllable with GTK or OSC based interfaces

The *Platform = julia* and *Architecture = portaudiojulia* export options allow to generate a self-contained file using the `portaudio_gtk.jl`architecture. The following command starts the program with the GTK control interface: 

```bash
julia -t 2 foo.jl -gtk 
```

The following command starts the program with the OSC control interface, ready to receive OSC commands or controlled with the `faust-osc-controller` tool as previously explained: 

```bash
julia -t 2 foo.jl -osc 
```

And finally the `faust-osc-controller` tool can be automatically started along the OSC receiver with the following command: 

```bash
julia -t 2 foo.jl -oscc 
```
