# Frequently Asked Questions

## Does select2 behaves as a standard C/C++ like if ?

The semantics of Faust is always strict. That's why there is no real `if` in Faust. And that's why the `ba.if` in the library (based on `select2` ) can be misleading. 

Concerning the way `select2` is compiled, the strict semantic is always preserved. In particular, the type system flags problematic expressions and the stateful parts are always placed outside the if. For instance the following DSP code:

```
process = button("choose"), (*(3) : +~_), (*(7):+~_) : select2;
```

is compiled in C/C++ as:

```c++
for (int i = 0; (i < count); i = (i + 1)) {
    fRec0[0] = (fRec0[1] + (3.0f * float(input0[i])));
    fRec1[0] = (fRec1[1] + (7.0f * float(input1[i])));
    output0[i] = FAUSTFLOAT((iSlow0 ? fRec1[0] : fRec0[0]));
    fRec0[1] = fRec0[0];
    fRec1[1] = fRec1[0];
}
```

When stateless expressions are used, they are by default generated using a *non-strict* conditional expression. For instance the following DSP code:

```
process = select2((+(1)~_)%10, sin:cos:sin:cos, cos:sin:cos:sin);
```

is compiled in C/C++ as:

```c++
for (int i0 = 0; i0 < count; i0 = i0 + 1) {
    iRec0[0] = iRec0[1] + 1;
    output0[i0] = FAUSTFLOAT(((iRec0[0] % 10) 
        ? std::sin(std::cos(std::sin(std::cos(float(input1[i0]))))) 
        : std::cos(std::sin(std::cos(std::sin(float(input0[i0])))))));
    iRec0[1] = iRec0[0];
}
```

where only one of the *then* or *else* branch will be effectively computed, thus saving CPU. Note that this behaviour **should not be misused** to avoid doing some computations ! 

If computing both branches is really needed, like for [debugging purposes](https://faustdoc.grame.fr/manual/debugging/#debugging-at-runtime) (testing if there is no division by 0, or producing `INF` or `NaN` values), the `-sts (--strict-select)` option can be used to force the computation of both branches by putting them in local variables, as shown in the following *generated with `-sts`* code version of the same DSP code:

```c++
for (int i0 = 0; i0 < count; i0 = i0 + 1) {
    iRec0[0] = iRec0[1] + 1;
    float fThen0 = std::cos(std::sin(std::cos(std::sin(float(input0[i0])))));
    float fElse0 = std::sin(std::cos(std::sin(std::cos(float(input1[i0])))));
    output0[i0] = FAUSTFLOAT(((iRec0[0] % 10) ? fElse0 : fThen0));
    iRec0[1] = iRec0[0];
}
```

to therefore preserve the strict semantic, even if a non-strict `(cond) ? then : else` form is used to produce the result of the `select2` expression.

So again remember that `select2` cannot be used to **avoid computing something**. For computations that need to avoid some values or ranges (like doing  `val/0` that would return `INF`, or `log` of a negative value that would return `NaN`), the solution is to use  `min` and  `max` to force the arguments to be in the correct domain of values. For example, to avoid division by 0, you can write `1/max(epsilon, x)`.

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

## Surprising effects of vgroup/hgroup on how controls and parameters work

User interface widget primitives like `button`, `vslider/hslider`, `vbargraph/hbargraph` allow for an abstract description of a user interface from within the Faust code. They can be grouped in a hiearchical manner using `vgroup/hgroup/tgroup` primitives. Each widget then has an associated path name obtained by concatenating the labels of all its surrounding groups with its own label.

Widgets that have the **same path** in the hiearchical structure will correspond to a same controller and will appear once in the GUI. For instance the following DSP code does not contain any explicit grouping mechanism:

```
import("stdfaust.lib");

freq1 = hslider("Freq1", 500, 200, 2000, 0.01);
freq2 = hslider("Freq2", 500, 200, 2000, 0.01);

process = os.osc(freq1) + os.square(freq2), os.osc(freq1) + os.triangle(freq2);
```
<img src="group1.png" class="mx-auto d-block" width="50%">
<center>*Shared freq1 and freq2 controllers*</center>

So even if  `freq1` and  `freq2` controllers are used as parameters at four different places, `freq1` used in `os.osc(freq1)` and `os.square(freq1)` will have the same path, be associated to a unique controller, and will finally appear once in the GUI. And this is the same mecanism for `freq2` .

Now if some grouping mecanism is used to better control the UI rendering, as in the following DSP code: 

```
import("stdfaust.lib");

freq1 = hslider("Freq1", 500, 200, 2000, 0.01);
freq2 = hslider("Freq2", 500, 200, 2000, 0.01);

process = hgroup("Voice1", os.osc(freq1) + os.square(freq2)), hgroup("Voice2", os.osc(freq1) + os.triangle(freq2));
```

The `freq1` and  `freq2` controllers now don't have the same path in each group, and so four separated controllers and UI items are finally created. 

<img src="group2.png" class="mx-auto d-block" width="60%">
<center>*Four freq1 and freq2 controllers*</center>

Using the relative pathname as explained in [Labels as Pathnames](https://faustdoc.grame.fr/manual/syntax/#labels-as-pathnames) possibly allows us to move `freq1` one step higher in the hierarchical structure, thus having again a unique path and controller: 

```
import("stdfaust.lib");

freq1 = hslider("../Freq1", 500, 200, 2000, 0.01);
freq2 = hslider("Freq2", 500, 200, 2000, 0.01);

process = hgroup("Voice1", os.osc(freq1) + os.square(freq2)), hgroup("Voice2", os.osc(freq1) + os.triangle(freq2));
```

<img src="group3.png" class="mx-auto d-block" width="50%">
<center>*freq1 moved one step higher in the hierarchical structure*</center>
