# Frequently Asked Questions

## Does select2 behaves as a standard C/C++ like if ?

The semantics of Faust is always strict. That's why there is no real if in Faust. And that's why the `ba.if` in the library can be misleading. 
Concerning the way `select2` is compiled, in principle, the strict semantic is always preserved. In particular, the type system flags problematic expressions and the stateful parts are always placed outside the if.  

For example:
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
In order for the stateful parts to be always computed, and therefore preserve the strict semantics, even if a non-strict `(cond) ? then : else` expression is used.

