# Advanced debugging with interp-tracer

Some general informations are [given here](https://faustdoc.grame.fr/manual/debugging/#debugging-the-dsp-code) on how to debug the Faust DSP code. This tutorial aims to better explain how the [interp-tracer](https://github.com/grame-cncm/faust/tree/master-dev/tools/benchmark#interp-tracer) tool can be used to debug code at runtime.  


The **interp-tracer** tool runs and instruments the compiled program (precisely the `compute` method) using the Interpreter backend. Various statistics on the code are collected and displayed while running and/or when closing the application, typically FP_SUBNORMAL, FP_INFINITE and FP_NAN values, or INTEGER_OVERFLOW, CAST_INT_OVERFLOW and DIV_BY_ZERO operations, or LOAD/STORE errors.

##  Debugging of out-of-domain computation 

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

The trace contains the stack of Faust Byte Code (FBC) instructions executed by the interpreter, with the latest instructions executed before the actual error, here the `kLogf` operation. Name of fields in the DSP structure are also visible, here `fHslider0`. Looking at the generated C++ can help understand the control flow:

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

The generated `DumpMem-debug22419.txt` file contains the content of the interpreter Virtual Machine REAL (float/double depending of the `-single/-double` compilation option) memory array, and INT (integer) memory array.

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

##  Debugging the select2 primitive

The `select2` primitive has a stric semantic, but for code optimization strategies, the generated code [is not fully strict]( https://faustdoc.grame.fr/manual/faq/#does-select2-behaves-as-a-standard-cc-like-if). 

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

Thus executing it with `interp -trace 4 debug.dsp` allows to detect one falling branch when the condition is in a given state. To force computation of both branches, the `-sts (--strict-select)` option can be used. The generated C++ is now:

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

where intermediate `fThen0` and `fElse0` created variables force the actual computation of both branches. Then executing `interp -trace 4 -sts debug.dsp` will reveal the out-of-bounds calculation on both branches, for both states of the condition. 
 
Obviously, these detected errors must then be corrected by carefully checking signal range, like verifying the min/max values in `vslider/hslider/nentry` user-interface items.
