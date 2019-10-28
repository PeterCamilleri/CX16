# A Deeper Dive

This file contains a more detailed look at how the assist_16 macro file works
and some of its more interesting features. This is presented separately from
the main readme file to avoid that file being overly long and burdensome to
the reader.

## Using Macros

One area missing in the 65C02 instruction set are operations that manipulate
16-bit quantities in memory. The goal here is not to replace the 65C02 with a
virtual dream machine. Rather, it is to augment the processor with those very
basic 16-bit operations that always seem so hard to do normally.

There are several possible strategies that may be employed in achieving this
goal:

1. The programmer can code up each case as needed. This give full control to
the programmer, but is highly distracting from the flow of the code and the
development process.
2. Place the code in a subroutine and call it using a _jsr_ instruction. This
reduces clutter. The programmer still needs to write the subroutine and any
code needed to pass in parameters that may be required. This is in addition to
the overhead of the _jsr_/_rts_ instructions.
3. Place the code in a macro. This reduces clutter and macros easily handle the
passing of parameters at assembly time. The downside is that macros can work
too well and hide important details. They can also use a lot of memory space.

## Clobbering Registers

Another issue is dealing with the fact that these operations will, as
side-effects, modify the values of registers not obviously involved in the
operation. These registers are said to have been "clobbered". There are two
main camps for dealing with this problem:

1. The routine can preserve any affected registers by using appropriate push
and pop instructions to preserve values and then restore them. While this wraps
the problem up neatly, it is wasteful since it often preserves registers that
the caller doesn't care about or can do so at a point in the code that is
inefficient.
2. The user of the routine can preserve registers by using appropriate push
and pop instructions to preserve values and then restore them. This exposes
the required code and adds some clutter. However the caller knows which
registers it needs and can save only those. Further it can place the push and
pop instructions at the optimum location (for example outside a loop).

The approach taken here is to wrap the required code in macros that expand the
code in-line. The caller is responsible for saving any required registers that
may be "clobbered" during processing.

## Library Subsets

The assist_16 file is normally included in a source file with the following
line of code:

    .include "assist_16.i65"

This will include all of the macros of the library. Alternatively, the
programmer may opt to use the lower level include files (see the table below)
and only load in those components required by their application. This may save
some time in assembling the program.

This table lists the files containing the assist_16 package.

Operation        | Macro  | Source File   | Test File(s)
-----------------|--------|---------------|----------------
Initialize       | set_16 | set_16.i65    | t65_set_16.a65
Increment        | inc_16 | inc_16.i65    | t65_inc_16.a65
Decrement        | dec_16 | dec_16.i65    | t65_dec_16.a65
Add a step       | adj_16 | adj_16.i65    | t65_adj_16.a65
Test             | tst_16 | tst_16.i65    | t65_tst_16.a65
Equal            | eql_16 | eql_16.i65    | t65_eql_16.a65
Greater or Equal | gte_16 | gte_16.i65    | t65_gte_16?.i65 ?=[ab]
Compare          | cmp_16 | cmp_16.i65    | t65_cmp_16?.i65 ?=[abcdef]


## Macro Operation

Just as the files in assist_16 are split into a two level hierarchy, each
operation in the assist_16 library consists of a two level macro. The layout
of these macros is a top level macro responsible for determining which
addressing mode is in use and five macro, each dedicated to the various
addressing modes.

Now the parser took a fair bit of effort to create and a lot of study into
the ca65 assembler and some of its more esoteric functions.

Here is a typical example, the top macro for the inc_16 operation:

    .macro inc_16 dst
      .if (.match({dst}, {(name)}))
        _inc_zpp_16 .mid(1, 1, {dst})
      .elseif (.match({dst}, {(name),y}))
        _inc_zpy_16 .mid(1, 1, {dst})
      .elseif (.match({dst}, {name,x}))
        _inc_vax_16 .mid(0, 1, {dst})
      .elseif (.match({dst}, {name,y}))
        _inc_vay_16 .mid(0, 1, {dst})
      .else
        _inc_var_16 {dst}
      .endif
    .endmacro

As can be seen, it consists of a chained series of _if_ statements, one clause
for each addressing mode. The operative parsers all look like:

    (.match({dst}, {(name)}))

The star of the show (besides Lady Ada) is the _.match_ function. Now, a major
source of misunderstanding, for me, was that much of the assembler deals not
with strings but language tokens instead. This is true of _.match_ which takes
two lists of tokens.

Before going further, we now need to get to the role of the braces. These are
used to group together tokens that would otherwise be split because they
contain a comma or other separator character. So if the argument is "a,y"
then {a,y} is one argument, namely a,y and without braces it is two arguments,
a and y.

So let's look at the two arguments: {dst} wraps up the macro dst argument as a
list of tokens and {(name)} creates a list of three tokens: left_parenthesis,
identifier, value="name", and a right_parenthesis.

Now for the next level of weirdness, the _.match_ function only examines the
type of token and not its value. Thus the second argument reduces to:
left_parenthesis, identifier, and a right_parenthesis. The name is simply a
placeholder for any identifier. So this pattern will match any argument
consisting of a identifier in parenthesis.

Given this level of understanding, let's see how these patterns relate to the
supported addressing modes.

Pattern    | Tokens
-----------|----------
{(name)}   | left_parenthesis identifier right_parenthesis
{(name),y} | left_parenthesis identifier right_parenthesis comma register_y
{name,x}   | identifier comma register_x
{name,y}   | identifier comma register_y

If the argument matches no pattern, it is assumed to be either a zero page or
absolute variable.

*Note:* The only unsupported memory addressing mode is the zero page indexed
by X indirect mode, ie: (var,x). This is not due to parsing issues, but rather
the complexity of trying to cleanly wrap 16 bit operations around this complex
addressing mode.

### Parser Limitations

While the macro parser can determine the addressing mode in use, it is less
capable than the main parser used by the ca65 assembler. To make the parse
work, addressing modes except for zp and abs require that simple identifiers
be used. For example, these are OK:

    set_16 myvar,42          ; Simple identifier
    set_16 myvar+2,44        ; Allowed for zp addressing mode
    set_16 (myptr),46        ; Simple identifier
    set_16 {(myptr),y},46    ; Simple identifier

and these are not OK:

    set_16 ($F0),46          ; Not an identifier
    set_16 (myptr+2),46      ; Complex expression
    set_16 {(myptr+2),y},46  ; Complex expression

One way around this is to use a temporary assembly time variable to hold the
computed expression. This is demonstrated in the set_16 test code and is
extracted here:

    zpvp2 = zpv+2            ; Compute a temporary variable.
    set_16 zpvp2,$FF00       ; Set up the pointer
    set_16 (zpvp2),$1234     ; Set up the pointee
    ; The balance of the test omitted.

Note that the "extra" code is evaluated as the code is being assembled and
does not generate any extra machine language code or take up any execution
time (clock cycles).

For those cases where the use of such a variable is not desired, it is
possible to bypass the parser level and use the lower level macros directly.
The arguments to this level are just the labels or expressions without the
addressing mode syntax. The changes in the syntax are described below, where
symbol is just a simple label and expression is any valid combination of
labels, numbers and operators.

Addressing Mode                   | High Level   | Low Level
----------------------------------|--------------|------------
Zero page                         | expression   | expression
Zero page indexed with X          | {symbol,x}   | expression
Zero page indexed with Y          | {symbol,y}   | expression
Absolute                          | expression   | expression
Absolute indexed with X           | {symbol,x}   | expression
Absolute indexed with Y           | {symbol,y}   | expression
Zero page indirect                | (symbol)     | expression
Zero page indirect indexed with Y | {(symbol),y} | expression

Here are those lower level macros:

Operation/Mode   | zp or abs   | zx or abx   | zy or aby   | zpi         | zpy
-----------------|:-----------:|:-----------:|:-----------:|:-----------:|:-----------:
Initialize       | _set_var_16 | _set_vax_16 | _set_vay_16 | _set_zpp_16 | _set_zpy_16
Increment        | _inc_var_16 | _inc_vax_16 | _inc_vay_16 | _inc_zpp_16 | _inc_zpy_16
Decrement        | _dec_var_16 | _dec_vax_16 | _dec_vay_16 | _dec_zpp_16 | _dec_zpy_16
Add a step       | _adj_var_16 | _adj_vax_16 | _adj_vay_16 | _adj_zpp_16 | _adj_zpy_16
Test             | _tst_var_16 | _tst_vax_16 | _tst_vay_16 | _tst_zpp_16 | _tst_zpy_16
Equal            | _eql_var_16 | _eql_vax_16 | _eql_vay_16 | _eql_zpp_16 | _eql_zpy_16
Greater or Equal | _gte_var_16 | _gte_vax_16 | _gte_vay_16 | _gte_zpp_16 | _gte_zpy_16
Compare          | _cmp_var_16 | _cmp_vax_16 | _cmp_vay_16 | _cmp_zpp_16 | _cmp_zpy_16
