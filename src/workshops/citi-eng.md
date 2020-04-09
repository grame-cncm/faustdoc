## 1. Sawtooth signal

By convention, in Faust, a full-scale audio signal varies between -1 and +1, but first we will start with a sawtooth signal between 0 and 1 which will then be used as a _phase generator_ to produce different waveforms.

### Phase Generator

The first step is to build a _phase generator_ that produces a periodic sawtooth signal between 0 and 1. Here is the signal we want to generate :

<img src="img/phase-sig.png" width="80%" class="mx-auto d-block">

### Ramp

To do this we will produce an "infinite" ramp, which we will then transform into a periodic signal thanks to a _part-decimal_ operation.

<img src="img/ramp-sig.png" width="80%" class="mx-auto d-block">

The ramp is produced by the following program :

<!-- faust-run -->
```
process = 0.125 : + ~ _;
```
<!-- /faust-run -->


### Semantics

To understand the above diagram, we will annotate it with its mathematical semantics.

<img src="img/ramp-diag-math.svg" width="80%" class="mx-auto d-block">

As can be seen in the diagram, the formula for the output signal is: \(y(t) = y(t-1) + 0.125\)

We can calculate the first values of \(y(t)\):

- \(y(t<0)=0\).
- \(y(0) = y(-1) + 0.125 = 0.125$\).
- \(y(1) = y(0) + 0.125 = 2*0.125 = 0.250\)
- \(y(2) = y(1) + 0.125 = 3*0.125 = 0.375\)
- ...
- \(y(6) = y(5) + 0.125 = 7*0.125 = 0.875\)
- \(y(7) = y(6) + 0.125 = 8*0.125 = 1,000\)
- \(y(8) = y(7) + 0.125 = 9*0.125 = 1.125\)
- ...

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




