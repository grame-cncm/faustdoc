# Error messages

Error messages are typically displayed in the form of compiler errors. They occur when the code cannot be successfully compiled, and typically indicate issues such as syntax errors or semantic errors. They can include the file and line number where the error occurred (when this information can be retrieved), as well as a brief description of the error. They can occur at different stages in the compilation process.  

The compiler is organized in several steps:

- starting from the DSP source code, the parser builds an internal memory representation of the source program (typically known as an [Abstract Source Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree)) which is here made of primitives in the *Box language*. A first class of errors messages are known as *syntax error* messages, like missing the `;` character to end a line.etc. 
- an expression in the Box language is then evaluated to produce an expression in the *Signal language*. Signals as conceptually infinite streams of samples or control values. The box language actually implements the Faust [Block Diagram Algebra](https://hal.science/hal-02159011v1), and not following the connections rules will trigger a second class of errors messages, the *box connection errors*.
- the pattern matching meta language allows to algorithmically create and manipulate block diagrams expressions. So a third class of *pattern matching coding errors* can occur at this level. 
- signal expressions are then optimized, type annotated (to associate an integer or real type with each signal, but also discovering when signals are to be computed: at init time, control-rate or sample-rate..) to produce a so-called *normal-form*. A fourth class of *typing error* can occur at this level, like using delays with a non-bounded size.etc. 

Note that the current error messages system is still far from perfect, usually when the origin of the error in the DSP source cannot be properly traced. In this case the file and line number where the error occurred are not displayed, but an internal description of the expression (as a Box of a Signal) is printed.

## Syntax errors

Those error happens when the language syntax is not respected [TO COMPLETE]

## Box connection errors

[Diagram expressions](https://faustdoc.grame.fr/manual/syntax/#diagram-expressions) express how block expressions can be combined to create new ones. The connection rules are precisely defined for each of them and have to be followed for the program to be correct.

Remember the [operator priority](https://faustdoc.grame.fr/manual/syntax/#diagram-composition-operations) when writing more complex expressions.   

### The five connections rules 

A second categorie of error messages is returned when block expressions are not correctly connected. 

#### Parallel connection

Combining two blocks `A` and `B` in parallel can never produce a box connection error since the 2 blocks are placed one on top of the other, without connections. The inputs of the resulting block-diagram are the inputs of `A` and `B`. The outputs of the resulting block-diagram are the outputs of `A` and `B`.

#### Sequencial connection error

Combining two blocks `A` and `B` in sequence will produce a box connection error if `outputs(A) != inputs(B)`. So for instance the following program:

<!-- faust-run -->
```
A = _,_;
B = _,_,_;
process = A : B;
```
<!-- /faust-run -->

will produce the following error message:

```
ERROR : sequential composition A:B
The number of outputs [2] of A must be equal to the number of inputs [3] of B

Here  A = _,_;
has 2 outputs

while B = _,_,_;
has 3 inputs
```

#### Split connection error

Combining two blocks `A` and `B` with the split composition will produce a box connection error if the number of inputs of `B` is not a multiple of the number of outputs of `A`. So for instance the following program:

<!-- faust-run -->
```
A = _,_;
B = _,_,_;
process = A <: B;
```
<!-- /faust-run -->

will produce the following error message:

```
ERROR : split composition A<:B
The number of outputs [2] of A must be a divisor of the number of inputs [3] of B

Here  A = _,_;
has 2 outputs

while B = _,_,_;
has 3 inputs
```

#### Merge connection error

Combining two blocks `A` and `B` with the merge composition will produce a box connection error if the number of outputs of `A` is not a multiple of the number of inputs of `B`. So for instance the following program:

<!-- faust-run -->
```
A = _,_;
B = _,_,_;
process = A :> B;
```
<!-- /faust-run -->

will produce the following error message:

```
ERROR : merge composition A:>B
The number of outputs [2] of A must be a multiple of the number of inputs [3] of B

Here  A = _,_;
has 2 outputs

while B = _,_,_;
has 3 inputs
```

#### Recursive connection error

Combining two blocks `A` and `B` with the recursive composition will produce a box connection error if the number of outputs of `A` is less than the number of inputs of `B`, or the number of outputs of `B` is less than the number of inputs of `A` (that is the following $$\mathrm{outputs}(A) \geq \mathrm{inputs}(B) and \mathrm{inputs}(A) \geq \mathrm{outputs}(B)$$ connection rule is not respected). So for instance the following program:

<!-- faust-run -->
```
A = _,_;
B = _,_,_;
process = A ~ B;
```
<!-- /faust-run -->

will produce the following error message:

```
ERROR : recursive composition A~B
The number of outputs [2] of A must be at least the number of inputs [3] of B. The number of inputs [2] of A must be at least the number of outputs [3] of B. 

Here  A = _,_;
has 2 inputs and 2 outputs

while B = _,_,_;
has 3 inputs and 3 outputs
```

#### Route connection errors

More complex routing between blocks can also be described using the `route` primitive. A specific 

```
ERROR : eval not a valid route expression (1)
```

```
ERROR : eval not a valid route expression (2)
```

[TO COMPLETE]

### Iterative constructions 

## Pattern matching errors 

Pattern matching mechanism allows to algorithmically create and manipulate block diagrams expressions. Pattern matching coding errors can occur at this level. And since computation are done at compile time, and the pattern machine language is Turing complete, even infinite loops 

### Multiple symbol definition error

This error happens when a symbol is defined several times in the DSP file:

```
ERROR : [file foo.dsp : N] : multiple definitions of symbol 'foo'
```

[TO COMPLETE]

## Signal related errors 

[TO COMPLETE]

Signal expressions are produced from box expressions, are type annotated and finally reduced to a normal-form. Some primitives expect their parameters to follow some constraints, like being in a specific range or being bounded for instance. 

### Automatic type promotion 

Some primitives (like [route](https://faustdoc.grame.fr/manual/syntax/#route-primitive), [rdtable](https://faustdoc.grame.fr/manual/syntax/#rdtable-primitive), [rwtable](https://faustdoc.grame.fr/manual/syntax/#rwtable-primitive)...) expect arguments with an integer type, which is automatically promoted, that is the equivalent of `int(exp)` is internally added and is not necessary in the source code. 

## Typing errors

### Soundfile usage error 

The soundfile primitive assumes the part number to stay in the [0..255] interval, so for instance the following code: 

<!-- faust-run -->
```
process = _,0 : soundfile("foo.wav", 2);
```
<!-- /faust-run -->

will produce the following error:

```
ERROR : out of range soundfile part number (interval(-1,1,-24) instead of interval(0,255)) in expression : length(soundfile("foo.wav"),IN[0])
```

### Modulo primitive error

The modulo `%` assumes that the denominator is not 0, thus the following code:

<!-- faust-run -->
```
process = _ % 0;
```
<!-- /faust-run -->

will produce the following error:

```
ERROR : % by 0 in IN[0] % 0
```

### Division primitive error

The division `/` assumes that the denominator is not 0, thus the following code:

<!-- faust-run -->
```
process = _ / 0;
```
<!-- /faust-run -->

will produce the following error:

```
ERROR : division by 0 in IN[0] / 0.0f
```

### Delay primitive error

The delay `@` primitive assumes that the delay signal value is bounded, so the following expression:

<!-- faust-run -->
```
process = @(ba.time);
```
<!-- /faust-run -->

will produce the following error:

```
ERROR : can't compute the min and max values of : proj0(letrec(W0 = (proj0(W0)'+1)))@0+-1
        used in delay expression : IN[0]@(proj0(letrec(W0 = (proj0(W0)'+1)))@0+-1)
        (probably a recursive signal)
```

[TO COMPLETE]

## Compiler option errors

All compiler options cannot be used with all backends. Moreover, some compiler options can not be combined. These will typically trigger errors.
