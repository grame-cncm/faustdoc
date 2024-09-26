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

The Faust compiler can possibly do a lot of optimizations at compile time. The DSP code can for instance be compiled for a fixed sample rate, thus doing at compile time all computation that depends of it. Since the Faust compiler will look for librairies starting from the local folder, a simple way is to locally copy the `libraries/platform.lib` file (which contains the `SR` definition), and change its definition for a fixed value like 48000 Hz. Then the DSP code has to be recompiled for the specialisation to take effect. Note that `libraries/platform.lib` also contains the definition of the `tablesize` constant which is used in various places to allocate tables for oscillators. Thus decreasing this value can save memory, for instance when compiling for embedded devices. This is the technique used in some Faust services scripts which add the `-I /usr/local/share/faust/embedded/` parameter to the Faust command line to use a special version of the platform.lib file.

### Computations Done *at Init time*

If not specialized with a constant value at compilation time, all computations that use the sample rate (which is accessed with the `ma.SR` in the DSP source code and given as parameter in the DSP `init` function) will be done at init time, and possibly again each time the same DSP is initialized with another sample rate.  

#### Using rdtable or rwtable

**TODO**: explain how computations can be done at init time and how to use `rdtable` or `rwtable` to store pre-computed values.

Several [tabulation functions](https://faustlibraries.grame.fr/libs/basics/#function-tabulation) can possibly be used.

### Computations Done *at Control Rate*

#### Parameter Smoothing

Control parameters are sampled once per block, their values are considered constant during the block, and the internal state depending of them is updated and appears at the beginning of the `compute` method, before the sample rate DSP loop. 

In the following DSP code, the `vol` slider value is directly applied on the input audio signal:

```
import("stdfaust.lib");
vol = hslider("Volume", 0.5, 0, 1, 0.01);
process = *(vol);
```

In the generated C++ code for `compute`, the `vol` slider value is sampled before the actual DSP loop, by reading the `fHslider0` field kept in a local  `fSlow0` variable:

```c++
virtual void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* output0 = outputs[0];
    float fSlow0 = float(fHslider0);
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        output0[i0] = FAUSTFLOAT(fSlow0 * float(input0[i0]));
    }
}
```

If the control parameter needs to be smoothed (like to avoid clicks or too abrupt changes), with the `control : si.smoo` kind of code, the computation rate moves from *control rate* to *sample rate*. If the previous DSP code is now changed with:

```
import("stdfaust.lib");
vol = hslider("Volume", 0.5, 0, 1, 0.01) : si.smoo;
process = *(vol);
```

The `vol` slider is sampled before the actual DSP loop and multiplied by the filter `fConst0` constant computed at init time, and finally used in the DSP loop in the smoothing filter:

```c++
virtual void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* output0 = outputs[0];
    float fSlow0 = fConst0 * float(fHslider0);
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        fRec0[0] = fSlow0 + fConst1 * fRec0[1];
        output0[i0] = FAUSTFLOAT(float(input0[i0]) * fRec0[0]);
        fRec0[1] = fRec0[0];
    }
}
```

So the CPU usage will obviously be higher, and the need for parameter smoothing should be carefully studied.

Another point to consider is the *order of computation* when smoothing control. In the following DSP code, the dB slider value is *first* converted first to a linear value, *then* smoothed:

```
import("stdfaust.lib");
smoother_vol = hslider("Volume", -6.0, -120.0, .0, 0.01) : ba.db2linear : si.smoo;
process = *(smoother_vol);
```

And the generated C++ code for `compute` has the costly `pow` math function used in `ba.db2linear` evaluted at control rate, so once before the DSP loop:

```c++
virtual void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* output0 = outputs[0];
    float fSlow0 = fConst0 * std::pow(1e+01f, 0.05f * float(fHslider0));
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        fRec0[0] = fSlow0 + fConst1 * fRec0[1];
        output0[i0] = FAUSTFLOAT(float(input0[i0]) * fRec0[0]);
        fRec0[1] = fRec0[0];
    }
}
```

But if the order between `ba.db2linear` and `si.smoo` is reversed like in the following code:

```
import("stdfaust.lib");
smoother_vol = hslider("Volume", -6.0, -120.0, .0, 0.01) : si.smoo : ba.db2linear;
process = *(smoother_vol);
```

The generated C++ code for `compute` now has the `pow` math function used in `ba.db2linear` evaluated at sample rate in the DSP loop, which is obviously much more costly:

```c++
virtual void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* output0 = outputs[0];
    float fSlow0 = fConst0 * float(fHslider0);
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        fRec0[0] = fSlow0 + fConst1 * fRec0[1];
        output0[i0] = FAUSTFLOAT(float(input0[i0]) * std::pow(1e+01f, 0.05f * fRec0[0]));
        fRec0[1] = fRec0[0];
    }
}
```

So to obtain the best performances in the generated code, all costly computations have to be done on the control value (as much as possible, this may not always be the desirable behaviour), and `si.smoo` (or any function that moves the computation from control rate to sample rate) as the last operation. 

### Computations Done *at Sample Rate* 

#### Possibly deactivating table range check with -ct option

The [-ct](../manual/debugging.md#the-ct-option) option is activated by default (starting at Faust version 2.53.4), but can possibly be removed (using `-ct 0`) to speed up the code. Read [Debugging rdtable and rwtable primitives](../tutorials/debugging.md#debugging-rdtable-and-rwtable-primitives) for a complete description.

#### Using Function Tabulation

The use of `rdtable` kind of compilation done at init time can be simplified using the [ba.tabulate](https://faustlibraries.grame.fr/libs/basics/#batabulate) or [ba.tabulate_chebychev](https://faustlibraries.grame.fr/libs/basics/#batabulate_chebychev) functions to *tabulate* a given unary function `fun` on a given range. A table is created and filled with precomputed values, and can be used to compute `fun(x)` in a more efficient way (at the cost of additional  static memory needed for the table).

#### Using Fast Math Functions

When costly math functions still appear in the sample rate code, the `-fm` [compilation option](../manual/options.md) can possibly be used to replace the standard versions provided by the underlying OS (like `std::cos`, `std::tan`... in C++ for instance) with user defined ones (hopefully faster, but possibly less precise).

### Delay lines implementation and DSP memory size

The Faust compiler automatically allocates buffers for the delay lines. At each sample calculation, the delayed signal is written to a specific location (the *write* position) and read from another location (the *read* position), the *distance in samples* between the read and write indexes representing the delay itself.

There are two possible strategies for implementing delay lines: either the read and write indices remain the same and the delay line memory is moved after each sample calculation, or the read and write indices move themselves along the delay line (with two possible *wrapping index* methods). These multiple methods allow arbitration between memory consumption and the CPU cost of using the delay line.

Two compiler options `-mcd <n>` (`-max-copy-delay`) and `-dlt <n>` (`--delay-line-threshold`) allow you to play with both strategies and even combine them.

For very short delay lines of up to two samples, the first strategy is implemented by manually shifting the buffer. Then a shift loop is generated for delay from 2 up to `-mcd <n>` samples. 

For delays values bigger than `-mcd <n>` samples, the second strategy is implemented by:

- either using arrays of power-of-two sizes accessed using mask based index computation with delays smaller than `-dlt <n>` value.
- or using a wrapping index moved by an if based method where the increasing index is compared to the delay-line size, and wrapped to zero when reaching it. This method is used for to delay values bigger then `-dlt <n>`. 

In this strategy the first method is faster but consumes more memory (since a delay line of a given size will be extended to the next power-of-two size), and the second method is  slower but consume less memory.  

Note that by default `-mcd 16` is `-dlt <INT_MAX>` values are used. Here is a scheme explaining the mecanism:

```
[ shift buffer |-mcd <N1>| wrapping power-of-two buffer |-dlt <N2>| if based wrapping buffer ]
```

Here is an example of a Faust program with 10 delay lines in parallel, each delaying a separated input, with three ways of compiling it (using the defaut `-scalar` mode):

<!-- faust-run -->
```
process = par(i, 10, @(i+1)) :> _;
```
<!-- /faust-run -->

When compiling with `faust -mcd 20`, since 20 is larger than the size of the largest delay line, all of them are compiled with the *shifted memory* strategy:

```c++
...
// The DSP memory layout
float fVec0[11];
float fVec1[10];
float fVec2[9];
float fVec3[8];
float fVec4[7];
float fVec5[6];
float fVec6[5];
float fVec7[4];
float fVec8[2];
float fVec9[3];
int fSampleRate;
...
virtual void compute(int count, 
    FAUSTFLOAT** RESTRICT inputs, 
    FAUSTFLOAT** RESTRICT outputs) 
{
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* input1 = inputs[1];
    FAUSTFLOAT* input2 = inputs[2];
    FAUSTFLOAT* input3 = inputs[3];
    FAUSTFLOAT* input4 = inputs[4];
    FAUSTFLOAT* input5 = inputs[5];
    FAUSTFLOAT* input6 = inputs[6];
    FAUSTFLOAT* input7 = inputs[7];
    FAUSTFLOAT* input8 = inputs[8];
    FAUSTFLOAT* input9 = inputs[9];
    FAUSTFLOAT* output0 = outputs[0];
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        fVec0[0] = float(input9[i0]);
        fVec1[0] = float(input8[i0]);
        fVec2[0] = float(input7[i0]);
        fVec3[0] = float(input6[i0]);
        fVec4[0] = float(input5[i0]);
        fVec5[0] = float(input4[i0]);
        fVec6[0] = float(input3[i0]);
        fVec7[0] = float(input2[i0]);
        fVec8[0] = float(input0[i0]);
        fVec9[0] = float(input1[i0]);
        output0[i0] = FAUSTFLOAT(fVec0[10] + fVec1[9] + fVec2[8] + fVec3[7] + fVec4[6] 
            + fVec5[5] + fVec6[4] + fVec7[3] + fVec8[1] + fVec9[2]);
        for (int j0 = 10; j0 > 0; j0 = j0 - 1) {
            fVec0[j0] = fVec0[j0 - 1];
        }
        for (int j1 = 9; j1 > 0; j1 = j1 - 1) {
            fVec1[j1] = fVec1[j1 - 1];
        }
        for (int j2 = 8; j2 > 0; j2 = j2 - 1) {
            fVec2[j2] = fVec2[j2 - 1];
        }
        for (int j3 = 7; j3 > 0; j3 = j3 - 1) {
            fVec3[j3] = fVec3[j3 - 1];
        }
        for (int j4 = 6; j4 > 0; j4 = j4 - 1) {
            fVec4[j4] = fVec4[j4 - 1];
        }
        for (int j5 = 5; j5 > 0; j5 = j5 - 1) {
            fVec5[j5] = fVec5[j5 - 1];
        }
        for (int j6 = 4; j6 > 0; j6 = j6 - 1) {
            fVec6[j6] = fVec6[j6 - 1];
        }
        for (int j7 = 3; j7 > 0; j7 = j7 - 1) {
            fVec7[j7] = fVec7[j7 - 1];
        }
        fVec8[1] = fVec8[0];
        fVec9[2] = fVec9[1];
        fVec9[1] = fVec9[0];
       
    }
}
...
```

In this code example, the *very short delay lines of up to two samples by manually shifting the buffer* method can be seen in those lines:

```c++
...
// Delay line of 1 sample
fVec8[1] = fVec8[0];
// Delay line of 2 samples
fVec9[2] = fVec9[1];
fVec9[1] = fVec9[0];
...
```

and the *shift loop is generated for delay from 2 up to `-mcd <n>` samples*  method can be seen in those lines:

```c++
...
output0[i0] = FAUSTFLOAT(fVec0[10] + fVec1[9] + fVec2[8] + fVec3[7] + fVec4[6] 
    + fVec5[5] + fVec6[4] + fVec7[3] + fVec8[1] + fVec9[2]);
// Shift delay line of 10 samples
for (int j0 = 10; j0 > 0; j0 = j0 - 1) {
    fVec0[j0] = fVec0[j0 - 1];
}
// Shift delay line of 9 samples
for (int j1 = 9; j1 > 0; j1 = j1 - 1) {
    fVec1[j1] = fVec1[j1 - 1];
}
...
```

When compiled with `faust -mcd 0`, all delay lines use the *wrapping index* second strategy with power-of-two size (since `-dlt <INT_MAX>` is used by default):

```c++
...
// The DSP memory layout
int IOTA0;
float fVec0[16];
float fVec1[16];
float fVec2[16];
float fVec3[8];
float fVec4[8];
float fVec5[8];
float fVec6[8];
float fVec7[4];
float fVec8[2];
float fVec9[4];
int fSampleRate;
...
virtual void compute(int count, 
    FAUSTFLOAT** RESTRICT inputs, 
    FAUSTFLOAT** RESTRICT outputs) 
{
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* input1 = inputs[1];
    FAUSTFLOAT* input2 = inputs[2];
    FAUSTFLOAT* input3 = inputs[3];
    FAUSTFLOAT* input4 = inputs[4];
    FAUSTFLOAT* input5 = inputs[5];
    FAUSTFLOAT* input6 = inputs[6];
    FAUSTFLOAT* input7 = inputs[7];
    FAUSTFLOAT* input8 = inputs[8];
    FAUSTFLOAT* input9 = inputs[9];
    FAUSTFLOAT* output0 = outputs[0];
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        fVec0[IOTA0 & 15] = float(input9[i0]);
        fVec1[IOTA0 & 15] = float(input8[i0]);
        fVec2[IOTA0 & 15] = float(input7[i0]);
        fVec3[IOTA0 & 7] = float(input6[i0]);
        fVec4[IOTA0 & 7] = float(input5[i0]);
        fVec5[IOTA0 & 7] = float(input4[i0]);
        fVec6[IOTA0 & 7] = float(input3[i0]);
        fVec7[IOTA0 & 3] = float(input2[i0]);
        fVec8[IOTA0 & 1] = float(input0[i0]);
        fVec9[IOTA0 & 3] = float(input1[i0]);
        output0[i0] = FAUSTFLOAT(fVec0[(IOTA0 - 10) & 15] + fVec1[(IOTA0 - 9) & 15] 
            + fVec2[(IOTA0 - 8) & 15] + fVec3[(IOTA0 - 7) & 7] + fVec4[(IOTA0 - 6) & 7]
            + fVec5[(IOTA0 - 5) & 7] + fVec6[(IOTA0 - 4) & 7] + fVec7[(IOTA0 - 3) & 3] 
            + fVec8[(IOTA0 - 1) & 1] + fVec9[(IOTA0 - 2) & 3]);
        IOTA0 = IOTA0 + 1;
    }
}
...
```

In this code example, several delay lines of various power-of-two size (2, 4, 8, 16) are generated. A unique continuously incremented `IOTA0` variable is shared between all delay lines. The *wrapping index* code is generated with this `(IOTA0 - 5) & 7` kind of code, with a power-of-two - 1 mask (so 8 - 1 = 7 here). 

When compiled with `faust -mcd 4 -dlt 7`, a mixture of the three generation strategies is used:

```c++
// The DSP memory layout
...
int fVec0_widx;
float fVec0[11];
int fVec1_widx;
float fVec1[10];
int fVec2_widx;
float fVec2[9];
int fVec3_widx;
float fVec3[8];
int IOTA0;
float fVec4[8];
float fVec5[8];
float fVec6[8];
float fVec7[4];
float fVec8[2];
float fVec9[3];
int fSampleRate;
...
virtual void compute(int count, 
    FAUSTFLOAT** RESTRICT inputs, 
    FAUSTFLOAT** RESTRICT outputs) 
{
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* input1 = inputs[1];
    FAUSTFLOAT* input2 = inputs[2];
    FAUSTFLOAT* input3 = inputs[3];
    FAUSTFLOAT* input4 = inputs[4];
    FAUSTFLOAT* input5 = inputs[5];
    FAUSTFLOAT* input6 = inputs[6];
    FAUSTFLOAT* input7 = inputs[7];
    FAUSTFLOAT* input8 = inputs[8];
    FAUSTFLOAT* input9 = inputs[9];
    FAUSTFLOAT* output0 = outputs[0];
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        int fVec0_widx_tmp = fVec0_widx;
        fVec0[fVec0_widx_tmp] = float(input9[i0]);
        int fVec0_ridx_tmp0 = fVec0_widx - 10;
        int fVec1_widx_tmp = fVec1_widx;
        fVec1[fVec1_widx_tmp] = float(input8[i0]);
        int fVec1_ridx_tmp0 = fVec1_widx - 9;
        int fVec2_widx_tmp = fVec2_widx;
        fVec2[fVec2_widx_tmp] = float(input7[i0]);
        int fVec2_ridx_tmp0 = fVec2_widx - 8;
        int fVec3_widx_tmp = fVec3_widx;
        fVec3[fVec3_widx_tmp] = float(input6[i0]);
        int fVec3_ridx_tmp0 = fVec3_widx - 7;
        fVec4[IOTA0 & 7] = float(input5[i0]);
        fVec5[IOTA0 & 7] = float(input4[i0]);
        fVec6[IOTA0 & 7] = float(input3[i0]);
        fVec7[0] = float(input2[i0]);
        fVec8[0] = float(input0[i0]);
        fVec9[0] = float(input1[i0]);
        output0[i0] = FAUSTFLOAT(fVec0[((fVec0_ridx_tmp0 < 0) ? fVec0_ridx_tmp0 + 11 : fVec0_ridx_tmp0)] 
            + fVec1[((fVec1_ridx_tmp0 < 0) ? fVec1_ridx_tmp0 + 10 : fVec1_ridx_tmp0)] 
            + fVec2[((fVec2_ridx_tmp0 < 0) ? fVec2_ridx_tmp0 + 9 : fVec2_ridx_tmp0)] 
            + fVec3[((fVec3_ridx_tmp0 < 0) ? fVec3_ridx_tmp0 + 8 : fVec3_ridx_tmp0)] 
            + fVec4[(IOTA0 - 6) & 7] + fVec5[(IOTA0 - 5) & 7] + fVec6[(IOTA0 - 4) & 7] + fVec7[3] + fVec8[1] + fVec9[2]);
        fVec0_widx_tmp = fVec0_widx_tmp + 1;
        fVec0_widx_tmp = ((fVec0_widx_tmp == 11) ? 0 : fVec0_widx_tmp);
        fVec0_widx = fVec0_widx_tmp;
        fVec1_widx_tmp = fVec1_widx_tmp + 1;
        fVec1_widx_tmp = ((fVec1_widx_tmp == 10) ? 0 : fVec1_widx_tmp);
        fVec1_widx = fVec1_widx_tmp;
        fVec2_widx_tmp = fVec2_widx_tmp + 1;
        fVec2_widx_tmp = ((fVec2_widx_tmp == 9) ? 0 : fVec2_widx_tmp);
        fVec2_widx = fVec2_widx_tmp;
        fVec3_widx_tmp = fVec3_widx_tmp + 1;
        fVec3_widx_tmp = ((fVec3_widx_tmp == 8) ? 0 : fVec3_widx_tmp);
        fVec3_widx = fVec3_widx_tmp;
        IOTA0 = IOTA0 + 1;
        for (int j0 = 3; j0 > 0; j0 = j0 - 1) {
            fVec7[j0] = fVec7[j0 - 1];
        }
        fVec8[1] = fVec8[0];
        fVec9[2] = fVec9[1];
        fVec9[1] = fVec9[0];
    }
}
...
```

In this code example, the *wrapping index moved by an if based method* can be recognized with the use of those `fVec0_ridx_tmp0` and `fVec0_widx_tmp0` kind of variables.

Choosing values that use less memory can be particularly important in the context of embedded devices. Testing different combinations of the `-mcd` and `-dlt` options can help optimize CPU utilisation, to summarize:

- chosing a big `n` value for `-mcd n` will consume less memory but the shift loop will start to be time consuming with big delay values. This model may sometimes be better suited if the C++ or LLVM compiler correctly auto-vectorizes the code and generates more efficient SIMD code.
- chosing `-mcd 0` will activate the *wrapping index* second strategy for all delay lines in the DSP code, then playing with `-dlt <n>` allows you to arbitrate between the *faster but consuming more memory* method and *slower but consume less memory* method.
- chosing a combinaison of `-mcd n1` and `-dlt <n2>` can possibly be the model to chose when a lot of delay lines with different sizes are used in the DSP code.

Using the benchmark tools [faustbench](#faustbench) and [faustbench-llvm](#faustbench-llvm) allow you to refine the choice of compilation options.

#### Recursive signals

In the C++ generated code, the delays lines appear as `fVecXX` arrays. When recursion is used in the DSP, a one sample delay is automatically added in the recursive path, and a very short delay line is allocated (appearing as `fRecX` arrays in the generated code). Here is the code of a recursively defined integrator:

<!-- faust-run -->
```
process = 1 : + ~ _;
```
<!-- /faust-run -->

And the generated C++ code with the `iRec0` buffer:

```c++
...
// The DSP memory layout
int iRec0[2];
...
virtual void compute(int count, 
    FAUSTFLOAT** RESTRICT inputs, 
    FAUSTFLOAT** RESTRICT outputs) 
{
    FAUSTFLOAT* output0 = outputs[0];
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        iRec0[0] = iRec0[1] + 1;
        output0[i0] = FAUSTFLOAT(iRec0[0]);
        iRec0[1] = iRec0[0];
    }
}
...   
```

#### Delay lines in recursive signals

Here is an example of a Faust program with 10 recursive blocks in parallel, each using a delay line of increasing value:

<!-- faust-run -->
```
process = par(i, 10, + ~ @(i+1)) :> _;
```
<!-- /faust-run -->

Since a recursive signal uses a one sample delay in its loop, a buffer is allocated to handle the delay. When a delay is used in addition to the recursive signal, a *single buffer* is allocated to combine the two delay sources. The generated code using `faust -mcd 0` for instance is now:

```c++
...
// The DSP memory layout
int IOTA0;
float fRec0[4];
float fRec1[4];
float fRec2[8];
float fRec3[8];
float fRec4[8];
float fRec5[8];
float fRec6[16];
float fRec7[16];
float fRec8[16];
float fRec9[16];
int fSampleRate;
...
virtual void compute(int count, 
    FAUSTFLOAT** RESTRICT inputs, 
    FAUSTFLOAT** RESTRICT outputs) 
{
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* input1 = inputs[1];
    FAUSTFLOAT* input2 = inputs[2];
    FAUSTFLOAT* input3 = inputs[3];
    FAUSTFLOAT* input4 = inputs[4];
    FAUSTFLOAT* input5 = inputs[5];
    FAUSTFLOAT* input6 = inputs[6];
    FAUSTFLOAT* input7 = inputs[7];
    FAUSTFLOAT* input8 = inputs[8];
    FAUSTFLOAT* input9 = inputs[9];
    FAUSTFLOAT* output0 = outputs[0];
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        fRec0[IOTA0 & 3] = float(input0[i0]) + fRec0[(IOTA0 - 2) & 3];
        fRec1[IOTA0 & 3] = float(input1[i0]) + fRec1[(IOTA0 - 3) & 3];
        fRec2[IOTA0 & 7] = float(input2[i0]) + fRec2[(IOTA0 - 4) & 7];
        fRec3[IOTA0 & 7] = float(input3[i0]) + fRec3[(IOTA0 - 5) & 7];
        fRec4[IOTA0 & 7] = float(input4[i0]) + fRec4[(IOTA0 - 6) & 7];
        fRec5[IOTA0 & 7] = float(input5[i0]) + fRec5[(IOTA0 - 7) & 7];
        fRec6[IOTA0 & 15] = float(input6[i0]) + fRec6[(IOTA0 - 8) & 15];
        fRec7[IOTA0 & 15] = float(input7[i0]) + fRec7[(IOTA0 - 9) & 15];
        fRec8[IOTA0 & 15] = float(input8[i0]) + fRec8[(IOTA0 - 10) & 15];
        fRec9[IOTA0 & 15] = float(input9[i0]) + fRec9[(IOTA0 - 11) & 15];
        output0[i0] = FAUSTFLOAT(fRec0[IOTA0 & 3] + fRec1[IOTA0 & 3] + fRec2[IOTA0 & 7] + fRec3[IOTA0 & 7] + fRec4[IOTA0 & 7] + fRec5[IOTA0 & 7] + fRec6[IOTA0 & 15] + fRec7[IOTA0 & 15] + fRec8[IOTA0 & 15] + fRec9[IOTA0 & 15]);
        IOTA0 = IOTA0 + 1;
    }
}
...
```

with buffers named `fRecX` instead of `fVecX` in the previous example. The `-mcd <n>` and `-dlt <n>` options can be used with the same purpose.

### Managing DSP Memory Layout

On audio boards where the memory is separated as several blocks (like SRAM, SDRAM…) with different access time, it becomes important to refine the DSP memory model so that the DSP structure will not be allocated on a single block of memory, but possibly distributed on all available blocks. The idea is then to allocate parts of the DSP that are often accessed in fast memory and the other ones in slow memory. This can be controled using the `-mem` compilation option and an [adapted architecture file](../manual/architectures.md#custom-memory-manager).

## Optimizing the C++ or LLVM Code

From a given DSP program, the Faust compiler tries to generate the most efficient implementation. Optimizations can be done at DSP writing time, or later on when the target langage is generated (like  C++ or LLVM IR).
The generated code can have different *shapes* depending of compilation options, and can run faster of slower. Several programs and tools are available to help Faust programmers to test (for possible numerical or precision issues), optimize their programs by discovering the best set of options for a given DSP code, and finally compile them into native code for the target CPUs. 

By default the Faust compiler produces a big scalar loop in the generated `mydsp::compute` method. Compiler options allow you to generate other code *shapes*, like for instance separated simpler loops connected with buffers in the so-called vectorized mode (obtained using  the `-vec` option). The assumption is that auto-vectorizer passes in modern compilers will be able to better generate efficient SIMD code for them. In this vec option, the size of the internal buffer can be changed using the `-vs value` option. Moreover the computation graph can be organized in deep-first order using `-dfs`.  

Delay lines implementation can be be controlled with the `-mcd size` and `-dlt size` options, to choose for example between *power-of-two sizes and mask based wrapping* (faster but consumming more memory) or *if based wrapping*, slower but consumming less memory. 

Many other compilation choices are fully controllable with options. Note that the C/C++ and LLVM backends offer the greatest number of compilation options. Here are just a few of them:

-  `-clang` option: when compiled with clang/clang++, adds specific #pragma for auto-vectorization.
-  `-nvi` option: when compiled with the C++ backend, does not add the 'virtual' keyword. **This option can be especially useful in embedded devices context** 
-  `-mapp` option: simpler/faster versions of 'floor/ceil/fmod/remainder' functions (experimental)

Manually testing each of them and their combination is out of reach. So several tools have been developed to automatize that process and help search the configuration space to discover the best set of compilation options (be sure to run `make benchmark && sudo make devinstall` in Faust toplevel folder to install the benchmark tools):

### faustbench

The **faustbench** tool uses the C++ backend to generate a set of C++ files produced with different Faust compiler options. All files are then compiled in a unique binary that will measure DSP CPU of all versions of the compiled DSP. The tool is supposed to be launched in a terminal, but it can be used to generate an iOS project, ready to be launched and tested in Xcode. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faustbench).

### faustbench-llvm

The **faustbench-llvm** tool uses the `libfaust` library and its LLVM backend to dynamically compile DSP objects produced with different Faust compiler options, and then measure their DSP CPU usage. Additional Faust compiler options can be given beside the ones that will be automatically explored by the tool. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faustbench-llvm).

### faust2bench

The **faust2bench** tool allows you to benchmark a given DSP program:

```
faust2bench -h
Usage: faust2bench [Faust options] <file.dsp>
Compiles Faust programs to a benchmark executable
```

So something like `faust2bench -vec -lv 0 -vs 4 foo.dsp` is used to produce an executable, then launching `./foo` gives :

```
./foo
./foo : 303.599 MBytes/sec (DSP CPU % : 0.224807 at 44100 Hz)
```

The `-inj` option allows to possibly inject and benchmark an external C++ class to be *adapted* to behave as a `dsp` class, like in the following `adapted.cpp` example. The inherited `compute` method is rewritten to call the external C++ `limiterStereo.SetPreGain` etc... code to update the controllers, and the method `limiterStereo.Process` which computes the DSP:

```c++
#include "faust/dsp/dsp.h"
#include "Limiter.hpp"

struct mydsp : public dsp {
    
    Limiter<float> limiterStereo;
    
    void init(int sample_rate)
    {
        limiterStereo.SetSR(sample_rate);
    }
    
    int getNumInputs() { return 2; }
    int getNumOutputs() { return 2; }
    
    int getSampleRate() { return 44100; }
    
    void instanceInit(int sample_rate)
    {}
    
    void instanceConstants(int sample_rate)
    {}
    void instanceResetUserInterface()
    {}
    void instanceClear()
    {}
    
    void buildUserInterface(UI* ui_interface)
    {}
    
    dsp* clone()
    {
        return new mydsp();
    }
    void metadata(Meta* m)
    {}
    
    void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs)
    {
        limiterStereo.SetPreGain(0.5);
        limiterStereo.SetAttTime(0.5);
        limiterStereo.SetHoldTime(0.5);
        limiterStereo.SetRelTime(0.5);
        limiterStereo.SetThreshold(0.5);

        limiterStereo.Process(inputs, outputs, count);
    }
    
};
```

Using `faust2bench -inj adapted.cpp dummy.dsp` creates the executable to be tested with `./dummy` (remember that  `dummy.dsp` is a program that is not actually used in `-inj` mode).

### dynamic-faust

The **dynamic-faust** tool uses the dynamic compilation chain (based on the LLVM backend), and compiles a Faust DSP source to a LLVM IR (.ll), bicode (.bc), machine code (.mc) or object code (.o) output file. This is an alternative to the C++ compilation chain, since DSP code can be compiled to object code (.o),  then used and linked in a regular C++ project. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#dynamic-faust).

### Optimizing with any faust2xx tool

All `faust2xx` tools compile in scalar mode by default, but can take any combination of optimal options (like `-vec -fun -vs 32 -dfs -mcd 32` for instance) the previously described tools will automatically find. So by chaining the use of **faustbench** of **faustbench-llvm** to discover the best compilation options for a given DSP, then use them in the desired **faust2xx** tool, a CPU optimized standalone or plugin can be obtained. 
 
Note that some **faust2xx** tools like [`faust2max6`](https://github.com/grame-cncm/faust/tree/master-dev/architecture/max-msp) or `faust2caqt` can internally call the `faustbench-llvm` tool to discover and later on use the best possible compilation options. 

## Compiling for Multiple CPUs

On modern CPUs, compiling native code dedicated to the target processor is critical to obtain the best possible performances. When using the C++ backend, the same C++ file can be compiled with `gcc` of `clang` for each possible target CPU using the appropriate `-march=cpu` option. When using the LLVM backend, the same LLVM IR code can be compiled into CPU specific machine code using the [dynamic-faust](../manual/optimizing.md#dynamic-faust) tool. This step will typically be done using the best compilation options automatically found with the [faustbench](../manual/optimizing.md#faustbench) tool or [faustbench-llvm](../manual/optimizing.md#faustbench-llvm) tools. A specialized tool has been developed to combine all the possible options.

### faust2object

The `faust2object` tool  either uses the standard C++ compiler or the LLVM dynamic compilation chain (the [dynamic-faust](../manual/optimizing.md#dynamic-faust) tool) to compile a Faust DSP to object code files (.o) and wrapper C++ header files for different CPUs. The DSP name is used in the generated C++ and object code files, thus allowing to generate distinct versions of the code that can finally be linked together in a single binary. A more complete documentation is available on the [this page](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#faust2object).
