# Tools to Help Debug and Optimize the Generated Code

To create native executables, the Faust compiler produces very efficient C++ or LLVM IR. The generated code can have different "shapes" depending of compilation options, and can run faster of slower. Several programs and tools are available to help Faust programmers to test (for possible numerical or precision issues), optimize their programs by discovering the best set of options for a given DSP code, and finally compile them into native code for the target CPUs. 

## Debugging the DSP Code 

The Faust compiler gives error messages when the written code is not syntactically or semantically correct. When a correct program is finally generated, it may still have numerical or precision issues only appearing at runtime. This typically happens when using mathematical functions outside of their definition domain, like calling `log(0)` or `sqrt(-1)` at some point in the signal path. Those errors have to be then fixed by carefully checking signal range, like verifying the min/max values in `vslider/hslider/nentry` user-interface items. One way to detect and understand them is by running the code in a controlled and instrumented environment. A special version of the `interpreter` backend can be used for that purpose and is embedded in a dedicated testing tool. 

### interp-tracer

The `interp-tracer` tool runs and instruments the compiled program using the Interpreter backend. Various statistics on the code are collected and displayed while running and/or when closing the application, typically `FP_SUBNORMAL`, `FP_INFINITE` and `FP_NAN` values, or `INTEGER_OVERFLOW` and `DIV_BY_ZERO` operations. Mode 4 and 5 allow to display the stack trace of the running code when `FP_INFINITE`, `FP_NAN` or `INTEGER_OVERFLOW` values are produced. The *-control* mode allows to check control parameters, by explicitly setting their *min* and *max* values, then running the DSP and setting all controllers (inside their range) in a random way. Mode 4 up to 7 also check LOAD/STORE errors, and are typically used by the Faust compiler developers to check the generated code. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#interp-tracer).

### Debugging at runtime

On macOS, the [faust2caqt](https://faustdoc.grame.fr/manual/tools/#faust2caqt) script has a `-me` option to catch math computation exceptions (floating point exceptions and integer div-by-zero or overflow) at runtime.  Developers can possibly use the [dsp_me_checker](me-cncm/faust/blob/master-dev/architecture/faust/dsp/dsp-checker.h#L42) class to decorate a given DSP objet with the math computation exception handling code. 

## Optimizing the C++ or LLVM Code

By default the Faust compiler produces a big scalar loop in the generated `mydsp::compute` method. Compiler options allow to generate other code "shape", like for instance separated simpler loops connected with buffers in the so-called vectorized mode (obtained using  the `-vec` option). The assumption is that auto-vectorizer passes in modern compilers will be able to better generate efficient SIMD code for them. In this vec option, the size of the internal buffer can be changed using the `-vs value` option. Moreover the computation graph can be organized in deep-first order using `-dfs`.  A lot of other compilation choices are fully controllable with options. Note that the C/C++ and LLVM backends are the one with the maximum of possible compilation options. 

Manually testing each of them and their combination is out of reach. So several tools have been developed to automatize that process and help search the configuration space to discover the best set of compilation options: 

### faustbench

The `faustbench` tool uses the C++ backend to generate a set of C++ files produced with different Faust compiler options. All files are then compiled in a unique binary that will measure DSP CPU of all versions of the compiled DSP. The tool is supposed to be launched in a terminal, but it can be used to generate an iOS project, ready to be launched and tested in Xcode. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faustbench).

### faustbench-llvm

The `faustbench-llvm` tool uses the `libfaust` library and its LLVM backend to dynamically compile DSP objects produced with different Faust compiler options, and then measure their DSP CPU usage. Additional Faust compiler options can be given beside the ones that will be automatically explored by the tool. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faustbench-llvm).

Some **faust2xx** tools like [`faust2max6`](https://github.com/grame-cncm/faust/tree/master-dev/architecture/max-msp) or `faust2caqt` can internally call the `faustbench-llvm` tool to discover and later on use the best possible compilation options. Remember that all `faust2xx` tools compile in scalar mode by default, but can take any combination of optimal options (like `-vec -fun -vs 32 -dfs -mcd 32` for instance) the previously described tools will automatically find.

## Compiling for Multiple CPU

On modern CPUs, compiling native code dedicated to the target processor is critical to obtain the best possible performances. When using the C++ backend, the same C++ file can be compiled with `gcc` of `clang` for each possible target CPU using the appropriate `-march=cpu` option. When using the LLVM backend, the same LLVM IR code can be compiled into CPU specific machine code using the `dynamic-faust` tool. This step will typically be done using the best compilation options automatically found with the `faustbench` tool or `faustbench-llvm` tools. A specialized tool has been developed to combine all the possible options.

### faust2object

The `faust2object` tool  either uses the standard C++ compiler or the LLVM dynamic compilation chain (the `dynamic-faust` tool) to compile a Faust DSP to object code files (.o) and wrapper C++ header files for different CPUs. The DSP name is used in the generated C++ and object code files, thus allowing to generate distinct versions of the code that can finally be linked together in a single binary. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faust2object).
