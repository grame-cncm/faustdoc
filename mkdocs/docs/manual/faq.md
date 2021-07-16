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

In Faust, the interval calculation system on signals is supposed to detect possible problematic computations at compile time, and refuse to compile the corresponding DSP code. But **since the interval calculation is currently quite imperfect**, it can misbehave and generate possible problematic code, **that will possibly misbehave at runtime**. The typical case is when producing indexes to access rdtable/rwtable or delay lines, **that may trigger memory access crashes as explained before**.

Several strategies have been developed to help programmers better understand their written DSP code, and possibly analyse it both at compile time and runtime:

- at compile time, using the `-ct` and  `-cat` compilation options allows to check table index range, by verifying that the actual signal range is compatible with the actual table size. Note that since the interval calculation is currently imperfect, you may see *false positive* especially when using recursive signals where the interval calculation system will typically produce *[-INFINITY, INFINITY]* range, which is not precise enough to correctly describe the real signal range. 
- at runtime, the [inter-tracer](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark) tool runs and instruments the compiled program using the Interpreter backend, and can give various informations like the production *NaN* or *INFINITY* values, and using the `-me` with the `faust2caqt` script to catch math computation exceptions (see the [Debugging the DSP Code](https://faustdoc.grame.fr/manual/optimizing/) section in the documentation).

Note that the Faust [math library](https://faustlibraries.grame.fr/libs/maths/) contains the implementation of the`INFINITY` value (depending of the choosen type like `float`, `double` or `quad`), and `isnan` and `isinf`  functions that may help during development.


## Pattern matching and lists

Strictly speaking, there are no lists in Faust. For example the expression `()` or `NIL` in Lisp, which indicates an empty list, does not exist in Faust. Similarly, the distinction in Lisp between the number `3` and the list with only one element `(3)` does not exist in Faust. 

However, list operations can be simulated (in part) using the parallel binary composition operation `,` and pattern matching. The parallel composition operation is right-associative. This means that the expression `(1,2,3,4)` is just a simplified form of the fully parenthesized expression `(1,(2,(3,4)))`. The same is true for `(1,2,(3,4))` which is also a simplified form of the same fully parenthesized expression `(1,(2,(3,4)))`. 

You can think of pattern-matching as always being done on fully parenthesized expressions. Therefore no Faust function can ever distinguish `(1,2,3,4)` from `(1,2,(3,4))`, because they represent the same fully parenthesized expression `(1,(2,(3,4)))`. 

This is why `ba.count( ((1,2), (3,4), (5,6)) )` is not 3 but 4, and also why `ba.count( ((1,2), ((3,4),5,6)) )` is not 2 but 4. 

Explanation: in both cases the fully parenthesized expression is `( (1,2),((3,4),(5,6)) )`. The definition of  `ba.count ` being:

```
count((x,y)) = 1 + count(y);  // rule R1
count(x)     = 1;             // rule R2 
```
we have:

```
ba.count( ((1,2),((3,4),(5,6))) ) 
-R1->   1 + ba.count( ((3,4),(5,6)) ) 
-R1->   1 + 1 +  ba.count( (5,6) ) 
-R1->   1 + 1 + 1 + ba.count( 6 )
-R2->   1 + 1 + 1 + 1 
```
Please note that pattern matching is not limited to parallel composition, the other composition operators `(<: : :> ~)` can be used too.


## What is the situation about Faust compiler licence and the deployed code?


*Q: Does the Faust license (GPL) apply somehow to the code exports that it produces as well? Or can the license of the exported code be freely chosen such that one could develop commercial software (e.g. VST plug-ins) using Faust?*

A: You can freely use Faust to develop commercial software. The GPL license of the compiler *doesn't* apply to the code generated by the compiler. 

The license of the code generated by the Faust compiler depends only on the licenses of the input files. You should therefore check the licenses of the Faust libraries used and the architecture files. On the whole, when used unmodified, Faust libraries and architecture files are compatible with commercial, non-open source use.
