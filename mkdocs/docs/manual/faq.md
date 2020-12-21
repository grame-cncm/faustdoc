# Frequently Asked Questions

## Does select2 behaves as a standard C/C++ like if ?

The semantics of Faust is always strict. That's why there is no real `if` in Faust. And that's why the `ba.if` in the library (based on `select2` ) can be misleading. 

Concerning the way `select2` is compiled, in principle, the strict semantic is always preserved. In particular, the type system flags problematic expressions and the stateful parts are always placed outside the if.  For example:
```
process = button("choose"), (*(3) : +~_), (*(7):+~_) : select2;
```
is compiled in C/C++ as:

```
for (int i = 0; (i < count); i = (i + 1)) {
    fRec0[0] = (fRec0[1] + (3.0f * float(input0[i])));
    fRec1[0] = (fRec1[1] + (7.0f * float(input1[i])));
    output0[i] = FAUSTFLOAT((iSlow0 ? fRec1[0] : fRec0[0]));
    fRec0[1] = fRec0[0];
    fRec1[1] = fRec1[0];
}
```
In order for the stateful parts to be always computed, and therefore preserve the strict semantic, even if a non-strict `(cond) ? then : else` expression is used.

But it turns out that due to a bug in the compiler, the code generated for `select2` and `select3` is not really strict! Moreover, **our interval calculation system, which is supposed to detect this kind of error, is currently quite imperfect and doesn't do it**. 

For computations that need to avoid certains values or ranges (like doing  `val/0` that would return INF, or `log` of a negative value that would return NAN), the solution is to use min and max to force the arguments to be in the right range of values. For example, to avoid division by 0, you can write `1/max(epsilon, x)`.


## Produced NaN or INFINITY values and table access

On a computer, doing a computation that is undefined in mathematics (like `val/0` of `log(-1)`), and unrepresentable in floating-point arithmetic, will produce a [NaN](https://en.wikipedia.org/wiki/NaN) value, which has a [special internal representation](https://en.cppreference.com/w/cpp/numeric/math/NAN). 

Similarly, some computations will exceed the range that is representable with floating-point arithmetics, and are represented with a special [INFINITY](https://en.cppreference.com/w/cpp/numeric/math/INFINITY) macro, which value depends of the choosen type (like `float`, `double` or `long double`).

After being produced, those values can actually *contaminate* the following flow of computations (that is `Nan + any value = NaN` for instance) up to the point of producing incorrect indexes when used in array access, and causing memory access crashes.  

In Faust, the interval calculation system on signals is supposed to detect possible problematic computations at compile time, and refuse to compile the corresponding DSP code. But **since the interval calculation is currently quite imperfect**, it can misbehave and generate prossible problematic code, **that will possibly misbehave at runtime**. The typical case is when producing indexes to access rdtable/rwtable or delay lines, **that may trigger memory access crashes as explained before**.

Several strategies have been developed to help programmers better understand their written DSP code, and possibly analyse it both at compile time and runtime:

- at compile time, using the `-ct` and  `-cat` compilation options allows to check table index range, by verifying that the actual signal range is compatible with the actual table size. Note that since the interval calculation is currently imperfect, you may see *false positive* especially when using recursive signals where the interval calculation system will typically produce *[-INFINITY, INFINITY]* range, which is not precise enough to correctly describe the real signal range. 
- at runtime, the [inter-tracer](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark) tool runs and instruments the compiled program using the Interpreter backend, and can give various informations like the production *NaN* or *INFINITY* values, and using the `-me` with the `faust2caqt` script to catch math computation exceptions (see the [Debugging the DSP Code](https://faustdoc.grame.fr/manual/optimizing/) section in the documentation).

Note that the Faust [math library](https://faustlibraries.grame.fr/libs/maths/) contains the implementation of the`INFINITY` value (depending of the choosen type like `float`, `double` or `quad`), and `isnan` and `isinf`  functions that may help during development.
