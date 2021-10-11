# Optimizing the Code


## Optimizing the DSP Code 

Faust is a Domain Specific Language helping the programmer to write very high-level and concise DSP code, while letting the compiler do the hard work of producing the best and most efficient implementation of the specification. When processing the DSP source, the compiler typing system is able to discover how the described computations are effectively separated in four main categories: 

- computations done *at compilation/specialisation time*: this is the place for algorithmic signal processors definition heavily based on the lambda-calculus constitute of the language, together with its pattern-matching capabilities
- computations done *at init time*: for instance all the code that depends of the actual sample-rate, or filling of some internal tables (coded with the `rdtable` or `rwtable` language primitives) 
- computations done *at control rate*: typically all code that read the current values of controllers (buttons, sliders, nentries) and update the DSP internal state which depends of them
- computations done *at sample rate*: all remaining code that process and produce the samples 

One can think of these four categories as *different computation rates*. The programmer can possibly split its DSP algorithm to distribute the needed computation in the most appropriate domain (*slower rate* domain better than *faster rate* domain) and possibly rewrite some parts of its DSP algorithm from one domain to a slower rate one to finally obtain the most efficient code.

### Computations Done *at Compilation/Specialisation Time*

#### Using Pattern Matching 

**TODO**: explain how pattern-matching can be used to algorithmically describe signal processors, explain the principle of defining a new DSL inside the Faust DSL (with [fds.lib](https://faustlibraries.grame.fr/libs/fds/), [physmodels.lib](https://faustlibraries.grame.fr/libs/physmodels/), [wdmodels.lib](https://faustlibraries.grame.fr/libs/wavedigitalfilters/) as examples).

#### Specializing the DSP Code

The Faust compiler can possibly do a lot of optimizations at compile time. The DSP code can for instance be compiled for a fixed sample rate, thus doing at compile time all computation that depends of it. Since the Faust compiler will look for librairies starting from the local folder, a simple way is to locally copy the `libraries/platform.lib` file (which contains the `SR` definition), and change its definition for a fixed value like 48000 Hz. Then the DSP code has to be recompiled for the specialisation to take effect. Note that `libraries/platform.lib` also contains the definition of  the `tablesize` constant which is used in various places to allocate tables for oscillators. Thus decreasing this value can save memory, for instance when compiling for embedded devices. This is the technique used in some Faust services scripts which add the `-I /usr/local/share/faust/embedded/` parameter to the Faust command line to use a special version of the platform.lib file.

### Computations Done *at Init time*

If not specialized with a constant value at compilation time, all computations that use the sample rate (which is accessed with the `ma.SR` in the DSP source code and given as parameter in the DSP `init` function) will be done at init time, and possibly again each time the same DSP is initialized with another sample rate.  

#### Using rdtable or rwtable

**TODO**: explain how computations can be done at init time and how to use rdtable or rwtable to store pre-computed values.

### Computations Done *at Control Rate*

#### Parameter Smoothing

Control parameters are sampled once per block, their values are considered constant during the block, and the internal state depending of them is updated and appears at the beginning of the `compute` method, before the sample rate DSP loop. 

If a control parameter needs to be smoothed (like to avoid clicks or too abrupt changes), with the `control : si.smoo` kind of code, the computation rate moves from *control rate* to *sample rate*, and will be more costly. It means that the need for parameter smoothing *should be carefully studied*. 

Another point to consider is the *order of computation* when smoothing control. Here slider value is *first* converted first to a dB value, *then* smoothed:

```
import("stdfaust.lib");
smoother_vol = hslider("Volume", 0.5, 0, 1, 0.01) : ba.linear2db : si.smoo;
process = *(smoother_vol);
```

And the generated C++ code for `compute` has the costly `log10` math function used in `ba.linear2db` evaluted at control rate, so once before the DSP loop:

```c++
virtual void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
  FAUSTFLOAT* input0 = inputs[0];
  FAUSTFLOAT* output0 = outputs[0];
  float fSlow0 = (0.0199999996f * std::log10(float(fHslider0)));
  for (int i = 0; (i < count); i = (i + 1)) {
    fRec0[0] = (fSlow0 + (0.999000013f * fRec0[1]));
    output0[i] = FAUSTFLOAT((float(input0[i]) * fRec0[0]));
    fRec0[1] = fRec0[0];
  }
}
```

But if the order between `ba.linear2db` and  `si.smoo` is reversed like in the following code:

```
import("stdfaust.lib");
smoother_vol = hslider("Volume", 0.5, 0, 1, 0.01) : si.smoo: ba.linear2db;
process = *(smoother_vol);
```

The generated C++ code for `compute` now has the `log10` math function used in `ba.linear2db` evaluted at sample rate in the DSP loop, which is obviously much more costly:


```c++
virtual void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
  FAUSTFLOAT* input0 = inputs[0];
  FAUSTFLOAT* output0 = outputs[0];
  float fSlow0 = (0.00100000005f * float(fHslider0));
  for (int i = 0; (i < count); i = (i + 1)) {
    fRec0[0] = (fSlow0 + (0.999000013f * fRec0[1]));
    output0[i] = FAUSTFLOAT((20.0f * (float(input0[i]) * std::log10(fRec0[0]))));
    fRec0[1] = fRec0[0];
  }
}
```

So to obtain the best performances in the generated code, all costly computations have to be done on the control value (as much as possible, this may not always be the desirable behaviour), and `si.smoo` (or any function that moves the computation from control rate to sample rate) as the last operation. 

### Computations Done *at Sample Rate* 

#### Using Function Tabulation

The use of `rdtable` kind of compilation done at init time can be simplified using the [ba.tabulate](https://faustlibraries.grame.fr/libs/basics/#batabulate) function to *tabulate* a given unary function `fun` on a given range. A table is created and filled with precomputed values, and can be used to compute `fun(x)` in a more efficient way (at the cost of additional  static memory needed for the table).

#### Using Fast Math Functions

When costly math functions still appear in the sample rate code, the `-fm` [compilation option](https://faustdoc.grame.fr/manual/options/) can possibly be used to replace the standard versions provided by the underlying OS (like `std::cos`, `std::tan`... in C++ for instance) with user defined ones (hopefully faster, but possibly less precise).

### Managing DSP Memory Size

The Faust compiler automatically allocates memory for delay-lines, represented as buffers with *wrapping* read/write indexes that continously loop inside the buffer. Several strategies can be used to implement the wrapping indexes:  

- arrays of power-of-two sizes can be accessed using mask based index computation which is the fastest method, but consumes more memory since a delay-line of a given size will be extended to the next power-of-two size
- otherwise the *wrapping* index can be implemented with a *if* based method where the increasing index is compared to the delay-line size, and wrapped to zero when reaching it 

The `-dlt <n>`  (`--delay-line-threshold`) option allows to choose between the two available stategies. By default its value is INT_MAX thus all delay-lines are allocated using the first method. By choising a given value (in frames) for `-dlt`, all delay-lines with size bellow this value will be allocated using the first method (faster but consuming more memory), and other ones with the second method (slower but consuming less memory). Thus by gradually changing this `-dlt`  value in this continuum *faster/more memory up to slower/less memory*, the optimal choice can be done. **This option can be especially useful in embedded devices context.**

## Optimizing the C++ or LLVM Code

From a given DSP program, the Faust compiler tries to generate the most efficient implementation. Optimizations can be done at DSP writing time, or later on when the target langage is generated (like  C++ or LLVM IR).
The generated code can have different *shapes* depending of compilation options, and can run faster of slower. Several programs and tools are available to help Faust programmers to test (for possible numerical or precision issues), optimize their programs by discovering the best set of options for a given DSP code, and finally compile them into native code for the target CPUs. 

By default the Faust compiler produces a big scalar loop in the generated `mydsp::compute` method. Compiler options allow to generate other code *shapes*, like for instance separated simpler loops connected with buffers in the so-called vectorized mode (obtained using  the `-vec` option). The assumption is that auto-vectorizer passes in modern compilers will be able to better generate efficient SIMD code for them. In this vec option, the size of the internal buffer can be changed using the `-vs value` option. Moreover the computation graph can be organized in deep-first order using `-dfs`.  A lot of other compilation choices are fully controllable with options. Note that the C/C++ and LLVM backends are the one with the maximum of possible compilation options. 

Manually testing each of them and their combination is out of reach. So several tools have been developed to automatize that process and help search the configuration space to discover the best set of compilation options: 

### faustbench

The **faustbench** tool uses the C++ backend to generate a set of C++ files produced with different Faust compiler options. All files are then compiled in a unique binary that will measure DSP CPU of all versions of the compiled DSP. The tool is supposed to be launched in a terminal, but it can be used to generate an iOS project, ready to be launched and tested in Xcode. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faustbench).

### faustbench-llvm

The **faustbench-llvm** tool uses the `libfaust` library and its LLVM backend to dynamically compile DSP objects produced with different Faust compiler options, and then measure their DSP CPU usage. Additional Faust compiler options can be given beside the ones that will be automatically explored by the tool. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faustbench-llvm).

### dynamic-faust

The **dynamic-faust** tool uses the dynamic compilation chain (based on the LLVM backend), and compiles a Faust DSP source to a LLVM IR (.ll), bicode (.bc), machine code (.mc) or object code (.o) output file. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#dynamic-faust).

### Optimizing with any faust2xx tool

All `faust2xx` tools compile in scalar mode by default, but can take any combination of optimal options (like `-vec -fun -vs 32 -dfs -mcd 32` for instance) the previously described tools will automatically find. So by chaining the use of **faustbench** of **faustbench-llvm** to discover the best compilation options for a given DSP, then use them in the desired **faust2xx** tool, a CPU optimized standalone or plugin can be obtained. 
 
Note that some **faust2xx** tools like [`faust2max6`](https://github.com/grame-cncm/faust/tree/master-dev/architecture/max-msp) or `faust2caqt` can internally call the `faustbench-llvm` tool to discover and later on use the best possible compilation options. 

## Compiling for Multiple CPUs

On modern CPUs, compiling native code dedicated to the target processor is critical to obtain the best possible performances. When using the C++ backend, the same C++ file can be compiled with `gcc` of `clang` for each possible target CPU using the appropriate `-march=cpu` option. When using the LLVM backend, the same LLVM IR code can be compiled into CPU specific machine code using the `dynamic-faust` tool. This step will typically be done using the best compilation options automatically found with the `faustbench` tool or `faustbench-llvm` tools. A specialized tool has been developed to combine all the possible options.

### faust2object

The `faust2object` tool  either uses the standard C++ compiler or the LLVM dynamic compilation chain (the `dynamic-faust` tool) to compile a Faust DSP to object code files (.o) and wrapper C++ header files for different CPUs. The DSP name is used in the generated C++ and object code files, thus allowing to generate distinct versions of the code that can finally be linked together in a single binary. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faust2object).
