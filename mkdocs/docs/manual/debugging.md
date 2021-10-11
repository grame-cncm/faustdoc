# Debugging the Code


## Debugging the DSP Code 

On a computer, doing a computation that is undefined in mathematics (like `val/0` of `log(-1)`), and unrepresentable in floating-point arithmetic, will produce a [NaN](https://en.wikipedia.org/wiki/NaN) value, which has a [special internal representation](https://en.cppreference.com/w/cpp/numeric/math/NAN). Similarly, some computations will exceed the range that is representable with floating-point arithmetics, and are represented with a special [INFINITY](https://en.cppreference.com/w/cpp/numeric/math/INFINITY) value, which value depends of the choosen type (like `float`, `double` or `long double`).

After being produced, those values can actually *contaminate* the following flow of computations (that is `Nan + any value = NaN` for instance) up to the point of producing incorrect indexes when used in array access, and causing memory access crashes.  

The Faust compiler gives error messages when the written code is not syntactically or semantically correct, and the interval computation system on signals is supposed to *detect possible problematic computations at compile time*, and refuse to compile the corresponding DSP code.  But *the interval calculation is currently quite imperfect*, can misbehave, and possibly allow problematic code *that can even possibly crash at runtime* to be generated. The typical case is when producing indexes to access `rdtable/rwtable` or delay lines, *that may trigger memory access crashes*.

Several strategies have been developed to help programmers better understand their written DSP code, and possibly analyse it, both at compile time and runtime.

### Debugging at compile time

#### The -ct and -cat options

Using the `-ct` and  `-cat` compilation options allows to check table index range, by verifying that the actual signal range is compatible with the actual table size. Note that since the interval calculation is  imperfect, you may see *false positive* especially when using recursive signals where the interval calculation system will typically produce *[-inf, inf]* range, which is not precise enough to correctly describe the real signal range. 

#### The -me option

Starting with version 2.37.0, mathematical functions which have a finite domain (like `sqrt` defined for positive or null values, or `asin` defined for values in the [-1..1] range) are *checked at compile time* when they *actually compute values at that time*, and *raise an error* if the program tries to compute an out-of-domain value.  If those functions appear in the generated code, their domain of use can also be checked (using the interval computation system) and  the `-me` option *will display warnings* if the domain of use is incorrect. Note that again because of the imperfect  interval computation system, *false positive* may appear and should be checked.

### Debugging at runtime time

#### The interp-tracer tool

The `interp-tracer` tool runs and instruments the compiled program using the Interpreter backend. Various statistics on the code are collected and displayed while running and/or when closing the application, typically `FP_SUBNORMAL`, `FP_INFINITE` and `FP_NAN` values, or `INTEGER_OVERFLOW`, `CAST_INT_OVERFLOW`  and `DIV_BY_ZERO` operations, or `LOAD/STORE` errors. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#interp-tracer).

#### The faust2caqt tool

On macOS, the [faust2caqt](https://faustdoc.grame.fr/manual/tools/#faust2caqt) script has a `-me` option to catch math computation exceptions (floating point exceptions and integer div-by-zero or overflow, etc.) at runtime. Developers can possibly use the [dsp_me_checker](https://github.com/grame-cncm/faust/blob/master-dev/architecture/faust/dsp/dsp-checker.h#L42) class to decorate a given DSP object with the math computation exception handling code. 

### Fixing the errors

Those errors have to be then fixed by carefully checking signal range, like verifying the min/max values in `vslider/hslider/nentry` user-interface items. 

### Additional Resources 

Note that the Faust [math library](https://faustlibraries.grame.fr/libs/maths/) contains the implementation of `isnan` and `isinf`  functions that may help during development.

Handling infinity and not-a-number (NaN) the right way still remains a tricky problem that is not completely handled in the current version of the compiler. Dario Sanfilippo [blog post](https://www.dariosanfilippo.com/blog/2020/handling_inf_nan_values_in_faust_and_cpp/) is a very helpful summary of the situation with a lot of practical solutions to [write safer DSP code](https://github.com/dariosanfilippo/realfaust/blob/main/realfaust.lib).  

