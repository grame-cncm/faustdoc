# Tools to Help Optimize and Debug the Generated Code




## Optimizing the DSP Code 

Faust is a Domain Specific Language helping the programmer to write very high-level and concise DSP code, while letting the compiler do the hard work of producing the best and most efficient implementation of the specification. By analysing the DSP source, the compiler typing system is able to discover how the described computations are effectively separated in four main categories: 

- computations done *at compilation/specialisation time*: this is the place for algorithmic signal processors definition heavily based on the lambda-calculus constitute of the language, together with its pattern-matching capabilities (**TODO**: explain the idea of defining a new DSL inside the Faust DSL)
- computations done *at init time*: for instance all the code that depends of the actual sample-rate, or filling of some internal tables (coded with the `rdtable` or `rwtable` language primitives) 
- computations done *at control rate*: typically all code that read the current values of controllers (buttons, sliders, nentries) and update the internal state which depends of them
- computations done *at sample rate*: all remaining code that process and produce the samples 

One can think of these four categories as *different computation rates*. The programmer can possibly split its DSP algorithm to distribute the needed computation in the most appropriate domain (slower-rate domain better than faster-rate domain) and possibly rewrite some parts of its DSP algorithm from one domain to a slower-rate one to finally write the most efficient code.

### Computations Done *at Compilation/Specialisation Time*

#### Using Pattern matching 

**TODO**: explain how PM can be used to algorithmically describe signal processors, explain the idea of defining a new DSL inside the Faust DSL (with fds.lib, physmodels.lib, wdmodels.lib as examples)

#### Specializing the DSP code

The Faust compiler can possibly do a lot of optimizations at compile time. The DSP code can for instance be compiled for a fixed sample rate, thus doing at compile time all computation that depends of it. Since the Faust compiler will look for librairies starting from the local folder, a simple way is to locally copy the `libraries/platform.lib` file (which contains the `SR` definition), and change its definition for a fixed value like 48000 Hz. Then the DSP code has to be recompiled. Note that `libraries/platform.lib` also contains the definition of  the `tablesize` constant which is used in various places to allocate tables for oscillators. Thus decreasing this value can save memory, for instance when compiling for embedded devices. This is the technique used in some Faust services scripts which add the `-I /usr/local/share/faust/embedded/` parameter to the Faust command line to use a special version of the platform.lib file.

### Computations Done *at Init time*

#### Using rdtable or rwtable

**TODO**: explain how computations can be done at that time and how to use rdtable or rwtable to store pre-computed values

### Computations Done *at Control Rate*

#### Parameter Smoothing

**TODO**:  explain how parameter smoothing can be done to minimize was is done at sample rate 

### Computations Done *at Sample Rate* 

#### Using Function Tabulation

**TODO**:  explain use of the `ba.tabulate` function 

#### Using Fast Math Functions

When costly math functions still appear in the sample rate code, the `-fm` [compilation option](https://faustdoc.grame.fr/manual/options/) can possibly be used to replace the standard versions provided by the underlying OS (like `std::cos`, `std::tan`... in C++ for instance) with user defined ones. 

### Managing DSP memory size

The Faust compiler automatically allocates memory for delay-lines, represented as buffers with *wrapping* read/write indexes that continously loop inside the buffer. Several strategies can be used to implement the wrapping indexes:  

- arrays of power-of-two sizes can be accessed using mask based index computation which is the fastest method, but consumes more memory since a delay-line of a given size will be extended to the next power-of-two size
- otherwise the *wrapping* index can be implemented with a *if* based method where the increasing index is compared to the delay-line size, and wrapped to zero when reaching it. 

The `-dlt <n>`  (`--delay-line-threshold`) option allows to choose between the two available stategies. By default its value is INT_MAX thus all delay-lines are allocated using the first method. By choising a given value (in frames) for `-dlt`, all delay-lines with size bellow this value will be allocated using the first method (faster but consuming more memory), and other ones with the second method (slower but consuming less memory). Thus by gradually changing this `-dlt`  value in this continuum *faster/more memory up to slower/less memory*, the optimal choice can be done. **This option can be especially useful in embedded devices context.**

## Optimizing the C++ or LLVM Code

From a given DSP program, the Faust compiler tries to generate the most efficient implementation. Optimizations can be done at DSP writing time, or later on when the target langage is generated (like  C++ or LLVM IR).
The generated code can have different *shapes* depending of compilation options, and can run faster of slower. Several programs and tools are available to help Faust programmers to test (for possible numerical or precision issues), optimize their programs by discovering the best set of options for a given DSP code, and finally compile them into native code for the target CPUs. 

By default the Faust compiler produces a big scalar loop in the generated `mydsp::compute` method. Compiler options allow to generate other code *shapes*, like for instance separated simpler loops connected with buffers in the so-called vectorized mode (obtained using  the `-vec` option). The assumption is that auto-vectorizer passes in modern compilers will be able to better generate efficient SIMD code for them. In this vec option, the size of the internal buffer can be changed using the `-vs value` option. Moreover the computation graph can be organized in deep-first order using `-dfs`.  A lot of other compilation choices are fully controllable with options. Note that the C/C++ and LLVM backends are the one with the maximum of possible compilation options. 

Manually testing each of them and their combination is out of reach. So several tools have been developed to automatize that process and help search the configuration space to discover the best set of compilation options: 

### faustbench

The `faustbench` tool uses the C++ backend to generate a set of C++ files produced with different Faust compiler options. All files are then compiled in a unique binary that will measure DSP CPU of all versions of the compiled DSP. The tool is supposed to be launched in a terminal, but it can be used to generate an iOS project, ready to be launched and tested in Xcode. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faustbench).

### faustbench-llvm

The `faustbench-llvm` tool uses the `libfaust` library and its LLVM backend to dynamically compile DSP objects produced with different Faust compiler options, and then measure their DSP CPU usage. Additional Faust compiler options can be given beside the ones that will be automatically explored by the tool. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faustbench-llvm).

Some **faust2xx** tools like [`faust2max6`](https://github.com/grame-cncm/faust/tree/master-dev/architecture/max-msp) or `faust2caqt` can internally call the `faustbench-llvm` tool to discover and later on use the best possible compilation options. Remember that all `faust2xx` tools compile in scalar mode by default, but can take any combination of optimal options (like `-vec -fun -vs 32 -dfs -mcd 32` for instance) the previously described tools will automatically find.

## Compiling for Multiple CPUs

On modern CPUs, compiling native code dedicated to the target processor is critical to obtain the best possible performances. When using the C++ backend, the same C++ file can be compiled with `gcc` of `clang` for each possible target CPU using the appropriate `-march=cpu` option. When using the LLVM backend, the same LLVM IR code can be compiled into CPU specific machine code using the `dynamic-faust` tool. This step will typically be done using the best compilation options automatically found with the `faustbench` tool or `faustbench-llvm` tools. A specialized tool has been developed to combine all the possible options.

### faust2object

The `faust2object` tool  either uses the standard C++ compiler or the LLVM dynamic compilation chain (the `dynamic-faust` tool) to compile a Faust DSP to object code files (.o) and wrapper C++ header files for different CPUs. The DSP name is used in the generated C++ and object code files, thus allowing to generate distinct versions of the code that can finally be linked together in a single binary. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faust2object).

## Debugging the DSP Code 

The Faust compiler gives error messages when the written code is not syntactically or semantically correct. When a correct program is finally generated, it may still have numerical or precision issues only appearing at runtime **(Note**: this is mainly due the the non powerful enough signal interval computation of the compiler). This typically happens when using mathematical functions outside of their definition domain, like calling `log(0)` or `sqrt(-1)` at some point in the signal path. Those errors have to be then fixed by carefully checking signal range, like verifying the min/max values in `vslider/hslider/nentry` user-interface items. One way to detect and understand them is by running the code in a controlled and instrumented environment. A special version of the `interpreter` backend can be used for that purpose and is embedded in a dedicated testing tool. 

### interp-tracer

The `interp-tracer` tool runs and instruments the compiled program using the Interpreter backend. Various statistics on the code are collected and displayed while running and/or when closing the application, typically `FP_SUBNORMAL`, `FP_INFINITE` and `FP_NAN` values, or `INTEGER_OVERFLOW` and `DIV_BY_ZERO` operations. Mode 4 and 5 allow to display the stack trace of the running code when `FP_INFINITE`, `FP_NAN` or `INTEGER_OVERFLOW` values are produced. The *-control* mode allows to check control parameters, by explicitly setting their *min* and *max* values, then running the DSP and setting all controllers (inside their range) in a random way. Mode 4 up to 7 also check LOAD/STORE errors, and are typically used by the Faust compiler developers to check the generated code. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#interp-tracer).

### Debugging at runtime

On macOS, the [faust2caqt](https://faustdoc.grame.fr/manual/tools/#faust2caqt) script has a `-me` option to catch math computation exceptions (floating point exceptions and integer div-by-zero or overflow) at runtime. Developers can possibly use the [dsp_me_checker](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/dsp-checker.h#L42) class to decorate a given DSP object with the math computation exception handling code. 