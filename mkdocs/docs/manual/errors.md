# Error messages

Error messages are typically displayed in the form of compiler errors. They occur when the code cannot be successfully compiled, and typically indicate issues such as syntax errors or semantic errors. They can occur at different stages in the compilation process, possibly with the file and line number where the error occurred (when this information can be retrieved), as well as a brief description of the error. 

The compiler is organized in several stages:

- starting from the DSP source code, the parser builds an internal memory representation of the source program (typically known as an [Abstract Source Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree)) made here of primitives in the *Box language*. A first class of errors messages are known as *syntax error* messages, like missing the `;` character to end a line, etc. 
- an expression in the Box language is then evaluated to produce an expression in the *Signal language* where signals as conceptually infinite streams of samples or control values. The box language actually implements the Faust [Block Diagram Algebra](https://hal.science/hal-02159011v1), and not following the connections rules will trigger a second class of errors messages, the *box connection errors*. Other errors can be produced at this stage when parameters for some primitives are not of the correct type.  
- the pattern matching meta language allows to algorithmically create and manipulate block diagrams expressions. So a third class of *pattern matching coding errors* can occur at this level. 
- signal expressions are optimized, type annotated (to associate an integer or real type with each signal, but also discovering when signals are to be computed: at init time, control-rate or sample-rate..) to produce a so-called *normal-form*. A fourth class of *parameter range errors* or *typing errors* can occur at this level, like using delays with a non-bounded size, etc.  
- signal expressions are then converted in FIR (Faust Imperative Representation), a representation for state based computation (memory access, arithmetic computations, control flow, etc.), to be converted into the final target language (like C/C++, LLVM IR, Rust, WebAssembly, etc.). A fifth class of *backend errors* can occur at this level, like non supported compilation options for a given backend, etc.

Note that the current error messages system is still far from perfect, usually when the origin of the error in the DSP source cannot be properly traced. In this case the file and line number where the error occurred are not displayed, but an internal description of the expression (as a Box of a Signal) is printed.

## Syntax errors

Those errors happen when the language syntax is not respected. Here are some examples.

The following program:

```
box1 = 1
box2 = 2;
process = box1,box2;
```

will produce the following error message:

```
errors.dsp : 2 : ERROR : syntax error, unexpected IDENT
```

It means that an unexpected identifier as been found line 2 of the file test.dsp. Usually, this error is due to the absence of the semi-column `;` at the end of the previous line. 


The following program:

```
t1 = _~(+(1);
2 process = t1 / 2147483647;
```

will produce the following error message:

```
errors.dsp : 1 : ERROR : syntax error, unexpected ENDDEF

```

The parser finds the end of the definition (`;`) while searching a closing right parenthesis.

The following program:

```
process = ffunction;
```

will produce the following error message:

```
errors.dsp : 1 : ERROR : syntax error, unexpected ENDDEF, expecting LPAR
```

The parser was expecting a left parenthesis. It identified a keyword of the language that requires arguments.

The following program:

```
process = +)1);
```

will produce the following error message:

```
errors.dsp : 1 : ERROR : syntax error, unexpected RPAR
```

The wrong parenthesis has been used.

The following program:

```
process = <:+;
```

will produce the following error message:

```
errors.dsp : 1 : ERROR : syntax error, unexpected SPLIT
```

The `<:` split operator is not correctly used, and should have been written `process = _<:+;`. 

The following program:

```
process = foo;
```


will produce the following error message:

```
errors.dsp : 1 : ERROR : undefined symbol : foo
```

This happens when an undefined name is used.


## Box connection errors

[Diagram expressions](https://faustdoc.grame.fr/manual/syntax/#diagram-expressions) express how block expressions can be combined to create new ones. The connection rules are precisely defined for each of them and have to be followed for the program to be correct. Remember the [operator priority](https://faustdoc.grame.fr/manual/syntax/#diagram-composition-operations) when writing more complex expressions.   

### The five connections rules 

A second category of error messages is returned when block expressions are not correctly connected. 

#### Parallel connection

Combining two blocks `A` and `B` in parallel can never produce a box connection error since the 2 blocks are placed one on top of the other, without connections. The inputs of the resulting block-diagram are the inputs of `A` and `B`. The outputs of the resulting block-diagram are the outputs of `A` and `B`.

#### Sequencial connection error

Combining two blocks `A` and `B` in sequence will produce a box connection error if `outputs(A) != inputs(B)`. So for instance the following program:

```
A = _,_;
B = _,_,_;
process = A : B;
```

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

```
A = _,_;
B = _,_,_;
process = A <: B;
```
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

```
A = _,_;
B = _,_,_;
process = A :> B;
```

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

```
A = _,_;
B = _,_,_;
process = A ~ B;
```

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

More complex routing between blocks can also be described using the [route](https://faustdoc.grame.fr/manual/syntax/#route-primitive) primitive. Two different errors can be produced in case of incorrect coding:  

```
process = route(+,8.7,(0,0),(0,1));
```
will produce the following error message:

```
ERROR : invalid route expression, first two parameters should be blocks producing a value, third parameter a list of input/output pairs : route(+,8.7f,0,0,0,1)
```

And the second one when the parameters are not actually numbers:  

```
process = route(9,8.7f,0,0,0,button("foo"));
```
will produce the following error message:

```
ERROR : invalid route expression, parameters should be numbers : route(9,8.7f,0,0,0,button("foo"))
```
 
### Iterative constructions 

[Iterations](https://faustdoc.grame.fr/manual/syntax/#iterations) are analogous to `for(...)` loops in other languages and provide a convenient way to automate some complex block-diagram constructions. All `par`, `seq`, `sum`, `prod` expressions have the same form, take an identifier as first parameter, a number of iteration as an integer constant numerical expression as second parameter, then an arbitrary block-diagram as third parameter.

The example code:

```
process = par(+, 2, 8);
```

will produce the following syntax error, since the first parameter is not an identifier:

```
filename.dsp : xx : ERROR : syntax error, unexpected ADD, expecting IDENT
```

The example code:

```
process = par(i, +, 8);
```

will produce the following error:

```
filename.dsp : 1 : ERROR : not a constant expression of type : (0->1) : +
```

## Pattern matching errors 

Pattern matching mechanism allows to algorithmically create and manipulate block diagrams expressions. Pattern matching coding errors can occur at this level.  

### Multiple symbol definition error

This error happens when a symbol is defined several times in the DSP file:

```
ERROR : [file foo.dsp : N] : multiple definitions of symbol 'foo'
```

Since computation are done at compile time and the pattern matching language is Turing complete, even infinite loops can be produced at compile time and should be detected by the compiler.

### Loop detection error

The following (somewhat *extreme*) code: 

```
foo(x) = foo(x);
process = foo;
```

will produce the following error:

```
ERROR : stack overflow in eval
```

and similar kind of infinite loop errors can be produced with more complex code.

[TO COMPLETE]

## Signal related errors 

Signal expressions are produced from box expressions, are type annotated and finally reduced to a normal-form. Some primitives expect their parameters to follow some constraints, like being in a specific range or being bounded for instance. The domain of mathematical functions is checked and non allowed operations are signaled. 

### Automatic type promotion 

Some primitives (like [route](https://faustdoc.grame.fr/manual/syntax/#route-primitive), [rdtable](https://faustdoc.grame.fr/manual/syntax/#rdtable-primitive), [rwtable](https://faustdoc.grame.fr/manual/syntax/#rwtable-primitive)...) expect arguments with an integer type, which is automatically promoted, that is the equivalent of `int(exp)` is internally added and is not necessary in the source code. 

### Parameter range errors

#### Soundfile usage error 

The soundfile primitive assumes the part number to stay in the [0..255] interval, so for instance the following code: 

```
process = _,0 : soundfile("foo.wav", 2);
```
will produce the following error:

```
ERROR : out of range soundfile part number (interval(-1,1,-24) instead of interval(0,255)) in expression : length(soundfile("foo.wav"),IN[0])
```

####  Delay primitive error

The delay `@` primitive assumes that the delay signal value is bounded, so the following expression:

```
import("stdfaust.lib");
process = @(ba.time);
```

will produce the following error:

```
ERROR : can't compute the min and max values of : proj0(letrec(W0 = (proj0(W0)'+1)))@0+-1
        used in delay expression : IN[0]@(proj0(letrec(W0 = (proj0(W0)'+1)))@0+-1)
        (probably a recursive signal)
```

[TO COMPLETE]

### Table construction errors

The [rdtable](https://faustdoc.grame.fr/manual/syntax/#rdtable-primitive) primitive can be used to read through a read-only (pre-defined at initialisation time) table. The [rwtable](https://faustdoc.grame.fr/manual/syntax/#rwtable-primitive) primitive can be used to implement a read/write table. Both have a size computed at compiled time 


The `rdtable` primitive assumes that the table content is produced by a processor with 0 input and one output, known at compiled time. So the following expression:

```
process = rdtable(9, +, 4);
```

will produce the following error, since the `+`is not of the correct type:

```
ERROR : checkInit failed for type RSEVN interval(-2,2,-24)
```

The same kind of errors will happen when read and write indexes are incorrectly defined in a `rwtable` primitive. 

## Mathematical functions out of domain errors

Error messages will be produced when the mathematical functions are used outside of their domain, and if the problematic computation is done at compile time. If the out of domain computation may be done at runtime, then a warning can be produced using the `-me` option (see [Warning messages](#warning-messages) section).

### Modulo primitive error

The modulo `%` assumes that the denominator is not 0, thus the following code:

```
process = _%0;
```

will produce the following error:

```
ERROR : % by 0 in IN[0] % 0
```

The same kind of errors will be produced for `acos`, `asin`, `fmod`, `log10`, `log`, `remainder` and `sqrt` functions.


## FIR and backends related errors 

Some primitives of the language are not available in some backends.

The example code:
```
fun = ffunction(float fun(float), <fun.h>, "");
process = fun;
```
 
 compiled with the wast/wasm backends using: `faust -lang wast errors.dsp` will produce the following error:
 
 ```
ERROR : calling foreign function 'fun' is not allowed in this compilation mode
 ```
 
 and the same kind of errors would happen also with foreign variables or constants. 
 
 [TO COMPLETE]
 
## Compiler option errors

All compiler options cannot be used with all backends. Moreover, some compiler options can not be combined. These will typically trigger errors, before any compilation actually begins. 

[TO COMPLETE]

# Warning messages

Warning messages do not stop the compilation process, but allow to get usefull informations on potential problematic code. The messages can be printed using the `-wall` compilation option. Mathematical out-of-domain error warning messages are displayed when both `-wall` and `-me` options are used.
<script src="/faust-web-component.js" defer></script>
