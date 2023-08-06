# Advanced debugging with interp-tracer

Some general informations are [given here](https://faustdoc.grame.fr/manual/debugging/#debugging-the-dsp-code) on how to debug the Faust DSP code. This tutorial aims to better explain how the [interp-tracer](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#interp-tracer) tool can be used to debug code at runtime.  
The **interp-tracer** tool runs and instruments the compiled program using the Interpreter backend. Various statistics on the code are collected and displayed while running and/or when closing the application, typically FP_SUBNORMAL, FP_INFINITE and FP_NAN values, or INTEGER_OVERFLOW, CAST_INT_OVERFLOW, NEGATIVE_BITSHIFT and DIV_BY_ZERO operations, or LOAD/STORE errors.

##  Debugging out-of-domain computations 

Using the `-trace 4`option allows to exit at first error and write FBC (Faust Byte Code) trace as a `DumpCode-foo.txt` file, and the program memory layout as `DumpMem-fooXXX.txt` file. 

The following `debug.dsp` DSP program:

```
process = hslider("foo", 0.5, -1, 1, 0.01) : log; 
```

will produce out-of-domain values as soon at the slider value is 0 or below, with the following trace written on the console:

```
-------- Interpreter 'NaN' trace start --------
opcode 202 kLogf int 0 real 0 offset1 -1 offset2 -1
Stack [Int: 0] [REAL: 0,000000]
opcode 2 kLoadReal int 0 real 0 offset1 1 offset2 0 name fHslider0
Stack [Int: 0] [REAL: -4,605170]
opcode 279 kCondBranch int 0 real 0 offset1 0 offset2 0
Stack [Int: 16] [REAL: -4,605170]
opcode 46 kLTInt int 0 real 0 offset1 -1 offset2 -1
Stack [Int: 0] [REAL: -4,605170]
opcode 3 kLoadInt int 0 real 0 offset1 2 offset2 0 name i0
Stack [Int: 1] [REAL: -4,605170]
opcode 3 kLoadInt int 0 real 0 offset1 1 offset2 0 name count
Stack [Int: 16] [REAL: -4,605170]
opcode 7 kStoreInt int 0 real 0 offset1 2 offset2 0 name i0
Stack [Int: 1] [REAL: -4,605170]
opcode 33 kAddInt int 0 real 0 offset1 -1 offset2 -1
Stack [Int: 0] [REAL: -4,605170]
-------- Interpreter 'NaN' trace end --------
```

The trace contains the stack of Faust Byte Code (FBC) instructions executed by the interpreter, with the latest instructions executed before the actual error, here the `kLogf` operation. The names of the fields in the DSP structure are also visible, here `fHslider0`. Looking at the generated C++ can help understand the control flow:

```C++
virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) 
{
    FAUSTFLOAT* output0 = outputs[0];
    float fSlow0 = std::log(float(fHslider0));
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        output0[i0] = FAUSTFLOAT(fSlow0);
    }
}
```

The generated `DumpMem-debug22419.txt` file contains the content of the interpreter Virtual Machine REAL (float/double depending on the `-single/-double` compilation option) memory array, and INT (integer) memory array.

```
DSP name: debug
=================================
REAL memory: 3
0 defaultsound 0
1 fHslider0 -0.01
2 fSlow0 -4.60517
=================================
INT memory: 3
0  44100
1 count 16
2 i0 16
```

## Debugging rdtable and rwtable primitives

The [rdtable](https://faustdoc.grame.fr/manual/syntax/#rdtable-primitive) primitive uses a read index, and the [rwtable](https://faustdoc.grame.fr/manual/syntax/#rdtable-primitive) primitive uses a read index and a write index. The table size is known at compile time, and read/write indexes must stay inside the table to avoid memory access crashes at runtime. 

The [-ct](https://faustdoc.grame.fr/manual/debugging/#the-ct-option) option can be used to check table index range and generate safe table access code. 

For the following DSP table.dsp program:

```
process = rwtable(SIZE, 0.0, rdx, _, wdx)
with {
    SIZE = 16;
    integrator = +(1) ~ _;
    rdx = integrator%(SIZE*2);
    wdx = integrator%(SIZE*2);
};
```

the generated code with the `-ct 0` option will produce:

```C++
virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) {
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* output0 = outputs[0];
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        iRec0[0] = iRec0[1] + 1;
        int iTemp0 = iRec0[0] % 32;
        ftbl0[iTemp0] = float(input0[i0]);
        output0[i0] = FAUSTFLOAT(ftbl0[iTemp0]);
        iRec0[1] = iRec0[0];
    }
}
```

with incorrect table access code in the `compute` method, where the `iTemp0` read and write indexes may exceed the table size of 16. Executing `interp-tracer -trace 4 -ct 0 table.dsp` generates the following trace on the console, showing memory read/write access errors:

```
-------- Interpreter crash trace start --------
assertStoreRealHeap array: fIntHeapSize 17 index 16 size 16 name ftbl0
Stack [Int: 16] [REAL: 0,000000]
opcode 3 kLoadInt int 0 real 0 offset1 7 offset2 0 name iTemp0
Stack [Int: 15] [REAL: 0,000000]
opcode 24 kLoadInput int 0 real 0 offset1 0 offset2 0
Stack [Int: 16] [REAL: 0,000000]
opcode 3 kLoadInt int 0 real 0 offset1 6 offset2 0 name i0
Stack [Int: 16] [REAL: 0,000000]
opcode 7 kStoreInt int 0 real 0 offset1 7 offset2 0 name iTemp0
Stack [Int: 16] [REAL: 0,000000]
opcode 41 kRemInt int 0 real 0 offset1 -1 offset2 -1
Stack [Int: 0] [REAL: 0,000000]
opcode 11 kLoadIndexedInt int 0 real 0 offset1 0 offset2 2 name iRec0
Stack [Int: 0] [REAL: 0,000000]
opcode 1 kInt32Value int 0 real 0 offset1 -1 offset2 -1
Stack [Int: 0] [REAL: 0,000000]
opcode 1 kInt32Value int 32 real 0 offset1 -1 offset2 -1
-------- Interpreter crash trace end --------
```

With the `-ct 1` option, the generated code is now:

```C++
virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) {
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* output0 = outputs[0];
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        iRec0[0] = iRec0[1] + 1;
        int iTemp0 = std::max<int>(0, std::min<int>(iRec0[0] % 32, 15));
        ftbl0[iTemp0] = float(input0[i0]);
        output0[i0] = FAUSTFLOAT(ftbl0[iTemp0]);
        iRec0[1] = iRec0[0];
    }
}
```

where the `iTemp0` read and write index is now constrained to stay in the *[0..15]* range and the code will not crash at runtime anymore.

The DSP program was indeed incorrect with the indexes wrapping at 32 samples boundaries. It can be rewritten as:

```
process = rwtable(SIZE, 0.0, rdx, _, wdx)
with {
    SIZE = 16;
    index = (+(1) : %(SIZE)) ~ _;
    rdx = index;
    wdx = index;
};
```

and the generated C++ code with the `-ct 1` option (and using the `-wall`option to print warning messages on the console) is now:

```C++
virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) {
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* output0 = outputs[0];
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        iRec0[0] = (iRec0[1] + 1) % 16;
        int iTemp0 = std::max<int>(0, std::min<int>(iRec0[0], 15));
        ftbl0[iTemp0] = float(input0[i0]);
        output0[i0] = FAUSTFLOAT(ftbl0[iTemp0]);
        iRec0[1] = iRec0[0];
    }
}
```

with the warning messages:

```
WARNING : RDTbl read index [0:inf] is outside of table size (16) in read(write(TABLE(16,0.0f),proj0(letrec(W0 = ((proj0(W0)'+1)%16)))@0,IN[0]),proj0(letrec(W0 = ((proj0(W0)'+1)%16)))@0)
WARNING : WRTbl write index [0:inf] is outside of table size (16) in write(TABLE(16,0.0f),proj0(letrec(W0 = ((proj0(W0)'+1)%16)))@0,IN[0])
```

The range test code checks if the read or write index interval is inside the *[0..size-1]* range, and only generates constraining code when needed. **But since the signal interval calculation is currently imperfect, unneeded range constraining code might be generated !** This is actually the case in the generated code, and can be tested using `interp-tracer -trace 4 -ct 0 table.dsp`, which does not generate constraining code, but does not show any problem.

**If one is absolutely sure of the *stay in range* property, then adding constraining code can be deactivated using `-ct 0` and the generated code will be faster.** The hope is to improve the signal interval calculation model, so that the index constraining code will not be needed anymore.

Note that the DSP program can be rewritten this way:

```
process = rwtable(SIZE, 0.0, rdx, _, wdx)
with {
    SIZE = 16;
    index = (+(1) ~ _) : %(SIZE);
    rdx = index;
    wdx = index;
};
```

in this case the signal interval is correct and the generated C++ code is now:

```C++
virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) {
    FAUSTFLOAT* input0 = inputs[0];
    FAUSTFLOAT* output0 = outputs[0];
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        iRec0[0] = iRec0[1] + 1;
        int iTemp0 = iRec0[0] % 16;
        ftbl0[iTemp0] = float(input0[i0]);
        output0[i0] = FAUSTFLOAT(ftbl0[iTemp0]);
        iRec0[1] = iRec0[0];
    }
}
```

without any added range constraining code.

**Note that `-ct 1` option is the default, so safe code is always generated.** 

##  Debugging the select2 primitive

The `select2` primitive has a strict semantic, but for code optimization strategies, the generated code [is not fully strict]( https://faustdoc.grame.fr/manual/faq/#does-select2-behaves-as-a-standard-cc-like-if). 

For the following DSP program:

```
process = select2(button("gate"), branch1, branch2)
with {
    branch1 = (hslider("foo", 0.5, 0, 1, 0.01):log);
    branch2 = (hslider("bar", 0.5, -1, 1, 0.01):sqrt);
};
```

the generated  C++ is using the `((cond) ? then : else)` form which actually only computes one of the *then* or *else* branch depending of the `button("gate")` condition: 

```C++
virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) 
{
    FAUSTFLOAT* output0 = outputs[0];
    float fSlow0 = ((int(float(fButton0))) ? std::sqrt(float(fHslider1)) : std::log(float(fHslider0)));
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        output0[i0] = FAUSTFLOAT(fSlow0);
    }
}
```

Thus executing it with `interp-tracer -trace 4 debug.dsp` allows it to detect one falling branch when the condition is in a given state. To force computation of both branches, the `-sts (--strict-select)` option can be used. The generated C++ is now:

```C++
virtual void compute(int count, FAUSTFLOAT** RESTRICT inputs, FAUSTFLOAT** RESTRICT outputs) 
{
    FAUSTFLOAT* output0 = outputs[0];
    float fThen0 = std::log(float(fHslider0));
    float fElse0 = std::sqrt(float(fHslider1));
    float fSlow0 = ((int(float(fButton0))) ? fElse0 : fThen0);
    for (int i0 = 0; i0 < count; i0 = i0 + 1) {
        output0[i0] = FAUSTFLOAT(fSlow0);
    }
}
```

where intermediate `fThen0` and `fElse0` created variables force the actual computation of both branches. Then executing `interp-tracer -trace 4 -sts debug.dsp` will reveal the out-of-bounds calculation on both branches, for both states of the condition. 

##  Debugging using test signals

Effects DSP programs usually need to be fed with standardized test input signals to possibly trigger abnormal behavior.  The `interp-tracer`  tool has an `-input`  option to connect an `impulse` program (defined with the `process = 1-1';` ),  then a `noise` program (defined with the `import("stdfaust.lib"); process = no.noise;` ) to all inputs of the tested DSP. So something like the `interp-tracer -trace 4 -input debug.dsp` command has to be used.

More specialized test input signals can be used by directly modifying the `debug.dsp` code, then running the DSP code normally (that is not using the `-input` option anymore). So writing something like:  `process = test_signal <: effect;` to connect a given mono `test_signal` to all inputs of the `effect` program.

##  Correcting the program
 
 The `interp-tracer` tool helps finding programming errors. But obviously, the detected errors must then be corrected:
 
 - by carefully checking signal range, like verifying the min/max values in `vslider/hslider/nentry` user-interface items
 - by checking mathematical function domains 
 - by checking indexes when using by `rdtable\rwtable` primitives
 - ...
