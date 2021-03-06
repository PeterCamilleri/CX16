# Sweet-16

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
* [Co-Virtual Machine](#co-virtual-machine)
* [The Sweet-16 Architecture](#the-sweet-16-architecture)
* [Mode Control](#mode-control)
* [Sweet-16 Instruction Set](#sweet-16-instruction-set)
   * [Pre Auto Increment vs. Post Auto Decrement](#pre-auto-increment-vs-post-auto-decrement)
   * [ADD -- Add Word Register to the Accumulator](#add----add-word-register-to-the-accumulator)
   * [BC -- Branch If Carry Set](#bc----branch-if-carry-set)
   * [BM -- Branch If Negative](#bm----branch-if-negative)
   * [BM1 -- Branch If Minus One](#bm1----branch-if-minus-one)
   * [BNC -- Branch If Carry Clear](#bnc----branch-if-carry-clear)
   * [BNM1 -- Branch If Not Minus One](#bnm1----branch-if-not-minus-one)
   * [BNZ -- Branch If Not Zero](#bnz----branch-if-not-zero)
   * [BP -- Branch If Positive](#bp----branch-if-positive)
   * [BR -- Branch](#br----branch)
   * [BRK -- Invoke the _brk_ Interrupt](#brk----invoke-the-brk-interrupt)
   * [BS -- Branch to a Subroutine](#bs----branch-to-a-subroutine)
   * [BZ -- Branch If Zero](#bz----branch-if-zero)
   * [CPR -- Compare Word Register with the Accumulator](#cpr----compare-word-register-with-the-accumulator)
   * [DCR -- Decrement Word Register](#dcr----decrement-word-register)
   * [INR -- Increment Word Register](#inr----increment-word-register)
   * [LD -- Transfer Word Register to Accumulator](#ld----transfer-word-register-to-accumulator)
   * [LD @ -- Transfer Memory Byte to Accumulator](#ld-----transfer-memory-byte-to-accumulator)
   * [LDD @ -- Transfer Memory Word to Accumulator](#ldd-----transfer-memory-word-to-accumulator)
   * [POP -- Transfer Memory Byte to Accumulator](#pop----transfer-memory-byte-to-accumulator)
   * [POPD -- Transfer Memory Word to Accumulator](#popd----transfer-memory-word-to-accumulator)
   * [RS -- Return from a Subroutine](#rs----return-from-a-subroutine)
   * [RTN -- Resume 6502 Native Code](#rtn----resume-6502-native-code)
   * [SET -- Load Register Immediate Word](#set----load-register-immediate-word)
   * [ST -- Transfer Word Accumulator to Register](#st----transfer-word-accumulator-to-register)
   * [ST @ -- Transfer Accumulator Byte to Memory](#st-----transfer-accumulator-byte-to-memory)
   * [STD @ -- Transfer Accumulator Word to Memory](#std-----transfer-accumulator-word-to-memory)
   * [STP @ -- Transfer Accumulator Byte to Memory](#stp-----transfer-accumulator-byte-to-memory)
   * [SUB -- Subtract Word Register from the Accumulator](#sub----subtract-word-register-from-the-accumulator)
* [Sweet-16 Extensions](#sweet-16-extensions)
   * [JUMP -- Jump to a new location](#jump----jump-to-a-new-location)
   * [JS -- Jump to a Subroutine](#js----jump-to-a-Submarine)
   * [MOV -- Move Register to Register](#mov----move-register-to-register)
      * [Macro Problems](#macro-problems)
   * [Exit Simulation](#exit-simulation)
* [The Future](#the-future)
* [References](#references)

## Introduction

This file describes the port of the Sweet-16 covirtual machine to the W65C02S,
the ca65 assembler, and the Commander X 16 computer.

The Sweet-16 VM was part of the Apple \]\[ Integer Basic ROMs. Its primary
goal was to save code space, trading of speed for space. It achived this by
encoding instructions in 1, 2, or 3 bytes that often replaced native code
sequences of 6 to 12 (or more) bytes. And while the VM added an overhead of
about 300 bytes, if it was used often enough, it could have a net savings of
memory space.

Sweet-16 was first described in the May 1977 issue of Byte magazine with a
follow-up article in November going into much more detail as to how the code
worked. It was my first introduction to byte code interpreters and had a
profound influence on my thinking about computers, software design, and
layered architectures.

That is why I have chosen to port the Sweet-16 to the Commander X 16 computer.
I also felt the code was in desperate need of a face-lift and "modernization".
This reflects the fact that we no longer need to program in upper case only
and we now have a more current macro assembler (ca65) and linker (ld65).
We are also allowed to have blank lines and other nice things too. Further
we've replaced the old battered MOS 6502 with the slightly less ancient
W65C02S. I plan to take full advantage of all of these over the course of time.

Support for the Sweet-16 VM consists of the following files in this repository:

File | Folder |Description
-----|--------|------
sweet_16.md  | docs | This markdown file.
sweet_16.a65 | SW16 | The assembly source code.
sweet_16.i65 | asminc | The assembly include file.
sweet_16_test.i65 | asminc | The assembly include file for simulation testing.
t65_sweet_16.a65 | t65 | The assembly source code for unit tests of the Sweet-16 VM.

[Back to the Top](#sweet-16)

## Co-Virtual Machine

I call Sweet-16 a co-virtual machine (CVM) because it is intended to be used
embedded in native 6502 code. This is analogous to the old
[**8087**](https://en.wikipedia.org/wiki/Intel_8087) floating point
coprocessor that allowed in-line access to higher math functions.

The classic (with updated syntax) example of this from way back is:

              lda in,y       ; Get a char.
              cmp #"M"       ; Is it "M" for move?
              bne nomove     ; No, skip move.

              begin_sw16     ; Yes, call sweet16
    mloop:    ld  @R1        ; R1 holds source address
              st  @R2        ; R2 holds dest. address
              dcr R3         ; Decrement length.
              bnz mloop      ; Loop until done.
              end_sw16       ; Return to 6502 mode.

    nomove:   cmp "E"        ; Is it "E" for exit?
              beq exit       ; Des, exit.

Note how Sweet-16 code can be used in-line with native code. This ease of
transition between the two modes is the secret of the success of the Sweet-16
programming tool.

[Back to the Top](#sweet-16)

## The Sweet-16 Architecture

The Sweet-16 processor was inspired by the old RCA 1802 chip. Like that chip
it has 16 registers of 16 bits each. Some of these registers have special
uses. This is shown below:

Register | Notes
:-------:|----------
 R0      | The Accumulator
 R1      | General Purpose Register
 R2      | General Purpose Register
 R3      | General Purpose Register
 R4      | General Purpose Register
 R5      | General Purpose Register
 R6      | General Purpose Register
 R7      | General Purpose Register
 R8      | General Purpose Register
 R9      | General Purpose Register
 R10     | General Purpose Register
 R11     | General Purpose Register
 R12     | The Stack Pointer
 R13     | The Result of all Comparisons for Branch Testing
 R14     | The Status Register
 R15     | The Program Counter

Now some of these could stand some further description.

* R0 - Sweet-16 operations only specify one argument. For two argument
operations the Accumulator is the implicit first argument and the register
in the operation is the second argument.
* R12 - The Stack Pointer needs to be initialized to point to the top of a
region of memory that serves as the Sweet-16 stack. If this is not done,
subroutines cannot be utilized.
* R13 - The compare instruction is in essence a subtract instruction that uses
R13 as the destination. That is:
<pre><code>R13 &larr; R0 - Rn</code></pre>
* R14 - The status data consists of two fields, the index of the last register
result and the carry bit. These are stored in the lower five bits of the high
byte of R14.
* R15 - The Sweet-16 program counter is a little odd in that it normally points
to the previous byte value rather than the current instruction byte. This is
a consequence of the quirky behavior of the 6502 _jsr_/_rts_ pair.
See [**quirks**](../quirks/README.md) for more.

[Back to the Top](#sweet-16)

## Mode Control

In order to make Sweet-16 mode easier to use, the file "sweet_16.i65" defines
two helper macros. These are:

Macro | Description
------|---------------
begin_sw16 | Call the Sweet-16 interpreter and set the assembler to Sweet-16 mode.
end_sw16 | Execute a return to native mode and set the assembler to W65C02S mode.

Note there are cases where the "helpful" extra actions get in the way because
you just want to define some Sweet-16 code without adding pre and post-amble
code. In those cases use:

Code  | Description
------|---------------
.setcpu "sweet16" | Set the assembler to Sweet-16 mode.
.pc02 | Set the assembler back to W65C02S mode.

[Back to the Top](#sweet-16)

## Sweet-16 Instruction Set

This section will focus on the use of the various Sweet-16 instructions. It
will focus on the user's view of these instructions rather than the
implementer's point of view. Further it will attempt to avoid the confusion
created by some of the archaic terminology used in existing documentation:

Old     | New  | Description
--------|------|---------------
Double  | Word | A 16 bit word
implied | Byte | An 8 bit byte

[Back to the Top](#sweet-16)

### Pre Auto Increment vs. Post Auto Decrement

Several instructions in the Sweet-16 have the characteristic that they either
increment the address register after performing a memory operation or they
decrement the address register before performing a memory operation. This is
conveyed with a very confusing naming convention. To make this easier to
figure out, this table should be of some help:

Operation    |  Pre-decrement | Post-increment
-------------|:--------------:|:-------------:
Read a byte  | POP @Rx        | LD @Rx
Read a word  | POPD @Rx       | LDD @Rx
Write a byte | STP @Rx        | ST @Rx
Write a word | ---            | STD @Rx

The convention is to use "pop" to represent pre auto decrement with post auto
increment being implied. This is most confusing because "pop" is almost always
paired with a "push", but not in the Sweet-16.

Note: There is no "STDP" instruction, so words cannot be written with pre auto
decrement.

[Back to the Top](#sweet-16)

### ADD -- Add Word Register to the Accumulator

Add the word register to the accumulator.
<pre><code>R0 &larr; R0 + Rn</code></pre>

Example:

    add R5         ; Add R5 to R0

Notes:
* The status and carry bit are set for testing.


[Back to the Top](#sweet-16)

### BC -- Branch If Carry Set

Branch if carry set
<pre><code>if (carry == 1) then R15 &larr; R15 + 2 + sign_extend(displacement) endif</code></pre>

Example:

    bc skip_item11  ; If carry set, skip around


[Back to the Top](#sweet-16)

### BM -- Branch If Negative

Branch if the register recorded in the status register (R14H) is < 0
<pre><code>if (R[status] < 0) then R15 &larr; R15 + 2 + sign_extend(displacement) endif</code></pre>

Example:

    bm dead_monster ; If monster expired, points!


[Back to the Top](#sweet-16)

### BM1 -- Branch If Minus One

Branch if the register recorded in the status register (R14H) is -1
<pre><code>if (R[status] = -1) then R15 &larr; R15 + 2 + sign_extend(displacement) endif</code></pre>

Example:

    bm1 skip_item12  ; Skip over "special" items

[Back to the Top](#sweet-16)

### BNC -- Branch If Carry Clear

Branch if carry clear
<pre><code>if (carry == 0) then R15 &larr; R15 + 2 + sign_extend(displacement) endif</code></pre>

Example:

    bnc skip_item13  ; If no carry, skip around

[Back to the Top](#sweet-16)

### BNM1 -- Branch If Not Minus One

Branch if the register recorded in the status register (R14H) is not -1
<pre><code>if (R[status] &ne; -1) then R15 &larr; R15 + 2 + sign_extend(displacement) endif</code></pre>

Example:

    bnm1 skip_item14  ; Skip over if not a "special" item

[Back to the Top](#sweet-16)

### BNZ -- Branch If Not Zero

Branch if the register recorded in the status register (R14H) is not 0
<pre><code>if (R[status] &ne; 0) then R15 &larr; R15 + 2 + sign_extend(displacement) endif</code></pre>

Example:

    bnz skip_item15  ; Skip non-empty items

[Back to the Top](#sweet-16)

### BP -- Branch If Positive

Branch if the register recorded in the status register (R14H) is &ge; 0
<pre><code>if (R[status] &ge; 0) then R15 &larr; R15 + 2 + sign_extend(displacement) endif</code></pre>

Example:

    bp skip_item16  ; If above the grass, skip around

[Back to the Top](#sweet-16)

### BR -- Branch

The unconditional branch instruction.
<pre><code>R15 &larr; R15 + 2 + sign_extend(displacement)</code></pre>

Example:

    br next_item   ; Branch to the top of the loop

[Back to the Top](#sweet-16)

### BRK -- Invoke the _brk_ Interrupt

This instruction executes a 6502 _brk_ instruction that vectors through the
interrupt vector. The results of this depend on the nature of the interrupt
handler and are beyond the scope of this document.

Note:
* At this time this instruction is disabled and performs no operation.

[Back to the Top](#sweet-16)

### BS -- Branch to a Subroutine

Push R15 onto the R12 stack and then branch.
<pre><code>memory_word[R12] &larr; R15
R12 &larr; R12 + 2
R15 &larr; R15 + 2 + sign_extend(displacement)</code></pre>

For an example, see RS below.

Note:
* The status is set to point to R0 with carry cleared.

[Back to the Top](#sweet-16)

### BZ -- Branch If Zero

Branch if the register recorded in the status register (R14H) is 0
<pre><code>if (R[status] = 0) then R15 &larr; R15 + 2 + sign_extend(displacement) endif</code></pre>

Example:

    bz skip_item17  ; Skip empty items

[Back to the Top](#sweet-16)

### CPR -- Compare Word Register with the Accumulator

Subract the word register from the accumulator and store the result in R13.
<pre><code>R13 &larr; R0 - Rn</code></pre>

Example:

    cpr R5         ; Compare R0 with R5

Notes:
* The status and carry bit are set for testing.
* Since the Sweet-16 VM has no overflow flag, the comparison of signed values
is prone to error due to overflow conditions that are not detected.

[Back to the Top](#sweet-16)

### DCR -- Decrement Word Register

Subtract 1 from the selected word register.
<pre><code>Rn &larr; Rn - 1</code></pre>

Example:

    dcr R5         ; Decrement R5

Notes:
* The status is set for testing, the carry bit is cleared.

[Back to the Top](#sweet-16)

### INR -- Increment Word Register

Add 1 to the selected word register.
<pre><code>Rn &larr; Rn + 1</code></pre>

Example:

    inr R5         ; Increment R5

Notes:
* The status is set for testing, the carry bit is cleared.

[Back to the Top](#sweet-16)

### LD -- Transfer Word Register to Accumulator

Load the specified register into the accumulator:
<pre><code>R0 &larr; Rn</code></pre>

Example:

    ld  R7         ; Copy R7 to R0

Notes:
* The status is set for testing, the carry bit is cleared.

[Back to the Top](#sweet-16)

### LD @ -- Transfer Memory Byte to Accumulator

Fetch the byte addressed by the specified register into the accumulator. Then
the specified register is incremented by 1.
<pre><code>R0 &larr; $00::memory_byte[Rn]
Rn &larr; Rn + 1</code></pre>

Example:

    ld @R5         ; Transfer the byte pointed to by R5 to R0 and step R5

Notes:
* The status is set for testing, the carry bit is cleared. The result is never
negative.

[Back to the Top](#sweet-16)

### LDD @ -- Transfer Memory Word to Accumulator

Fetch the word addressed by the specified register into the accumulator. The
the specified register is incremented by 2.
<pre><code>R0 &larr; memory_word[Rn]
Rn &larr; Rn + 2</code></pre>

Example:

    ldd @R5        ; Transfer the word pointed to by R5 to R0 and step R5

Notes:
* The status is set for testing, the carry bit is cleared.

[Back to the Top](#sweet-16)

### POP -- Transfer Memory Byte to Accumulator

The specified register is decremented by 1. Then fetch the byte addressed by
the that register into the accumulator.
<pre><code>Rn &larr; Rn - 1
R0 &larr; $00::memory_byte[Rn]</code></pre>

Example:

    pop @R5         ; Step R5 back and transfer the byte pointed to by R5 to R0

Notes:
* The status is set for testing, the carry bit is cleared. The result is never
negative.

[Back to the Top](#sweet-16)

### POPD -- Transfer Memory Word to Accumulator

The specified register is decremented by 2. Then fetch the word addressed by
the that register into the accumulator.
<pre><code>Rn &larr; Rn - 2
R0 &larr; memory_word[Rn]</code></pre>

Example:

    popd @R5        ; Step R5 back and transfer the word pointed to by R5 to R0

Notes:
* The status is set for testing, the carry bit is cleared.

[Back to the Top](#sweet-16)

### RS -- Return from a Subroutine


Set R15 to word popped off of the R12 stack.
<pre><code>R12 &larr; R12 - 2
R15 &larr; memory_word[R12]</code></pre>

Example:

      bs fib_step
      ; stuff omitted

    fib_step:
      ; Exchange R0 and R1
      st  R2
      ld  R1
      st  R3
      ld  R2
      st  R1
      ld  R3
      ; Add R1 to R0
      add R1
      rs

[Back to the Top](#sweet-16)

### RTN -- Resume 6502 Native Code

This instruction causes the processor to resume executing native W65C02S code.

Example:

    rtn            ; Go back to native code.

Notes:
* The native CPU registers are restored to their state before Sweet-16 code
execution began.
* The Sweet-16 registers should be preserved. This is generally not hard to do.
Just don't demolish the zero-page.

[Back to the Top](#sweet-16)

### SET -- Load Register Immediate Word

Load the specified register with a 16 bit literal value:
<pre><code>Rn &larr; literal value</code></pre>

This instruction is used to initialize registers with starting values.
Example:

    set R5,$1234   ; Set R5 to $1234

Notes:
* The status is set for testing, the carry bit is cleared.
* It is not possible to use this instruction to set R15.

[Back to the Top](#sweet-16)

### ST -- Transfer Word Accumulator to Register

Store the accumulator into the specified register:
<pre><code>Rn &larr; R0</code></pre>

Example:

    st  R7         ; Copy R0 to R7

Notes:
* The status is set for testing, the carry bit is cleared.

[Back to the Top](#sweet-16)

### ST @ -- Transfer Accumulator Byte to Memory

Store the lower byte of the accumulator into the memory addressed by the
specified register. That register is incremented by 1.
<pre><code>memory_byte[Rn] &larr; low_byte(R0)
Rn &larr; Rn + 1</code></pre>

Example:

    st @R5         ; Transfer the low byte of R0 to memory pointed to by R5, step R5

Notes:
* The status is set for testing, the carry bit is cleared. The status reflects
the full value of R0, not just the low byte.

[Back to the Top](#sweet-16)

### STD @ -- Transfer Accumulator Word to Memory

Store the word in the accumulator to the memory addressed by the specified
register. That register is incremented by 2.
<pre><code>memory_word[Rn] &larr; R0
Rn &larr; Rn + 2</code></pre>

Example:

    std @R5        ; Transfer R0 to the memory word pointed to by R5, step R5

Notes:
* The status is set for testing, the carry bit is cleared.

[Back to the Top](#sweet-16)

### STP @ -- Transfer Accumulator Byte to Memory

The specified register is decremented by 1. Then the lower byte of the
accumulator is stored into the memory addressed by that register.
<pre><code>Rn &larr; Rn - 1
memory_byte[Rn] &larr; low_byte(R0)</code></pre>

Example:

    stp @R5        ; Step R5 back and transfer the low byte of R0 to memory pointed to by R5

Notes:
* The status is set for testing, the carry bit is cleared. The status reflects
the full value of R0, not just the low byte.

[Back to the Top](#sweet-16)

### SUB -- Subtract Word Register from the Accumulator

Subtract the word register from the accumulator.
<pre><code>R0 &larr; R0 - Rn</code></pre>

Example:

    sub R5         ; Subtract R5 from R0

Notes:
* The status and carry bit are set for testing.

[Back to the Top](#sweet-16)

## Sweet-16 Extensions

The Sweet-16 code lends itself to enhancement by adding new instructions. Three
non-register opcodes: $0D, $0E, and $0F are reserved for this purpose. This
port of the Sweet-16 adds the following:

[Back to the Top](#sweet-16)

### JUMP -- Jump to a new location

This is not actually a new operation code. It's just the old SET instruction
with a twist. The thing is, the old implementation of SET did not work if the
destination register was R15. The interpreter would mess up because it would
be incrementing R15 as it was being loaded. In order to emulate a jump
instruction the required incantation was:

    SET R0, target-1
    ST  R15

This not only needed two instructions, it clobbered R0 as well. With the new
code, all you need to do is:

    SET R15, target-1

By the way, the old school way of doing things still works so no code should
be broken.

The -1 in the "target-1" comes from the fact that the PC is incremented before
fetching op-codes, so we need to be one byte before our target. Or, you can
ignore all of that and just use the easy macro:

    JUMP label

Which generates the following enhanced Sweet-16 code:

    .byte $1F
    .byte <(target-1)
    .byte >(target-1)

[Back to the Top](#sweet-16)

### JS -- Jump to a Submarine

The Jump to a Subroutine (JS) op code is mapped into unused op-code $0D. It
works similar to the existing Branch to a Subroutine (BS) except with a full
16-bit address. Using it is simple:

    js target

Which generates the following extended Sweet-16 code:

    .byte $0D
    .byte <(target-1)
    .byte >(target-1)

Note:
* The status is set to point to R0 with carry cleared.

[Back to the Top](#sweet-16)

### MOV -- Move Register to Register

In the Sweet-16, R0 is very often a bottle-neck. The move instruction allows
data to be moved from one register to another without involving R0. Here's
how it's done:

    mov r_1, r_2   ; Move R1 to R2

Which given a source register (src) and a destination register (dst),
generates the following extended Sweet-16 code:

    .byte $0E
    .byte (src*16)+dst

To see how this can be of use, consider the following example from the test
file. Consider this subroutine that computes next entry in the Fibonacci
sequence. First using only old Sweet-16 code:

    fib:
      ; Swap R0 and R1
      st R2
      ld R1
      st R3
      ld R2
      st R1
      ld R3

      ; Add R1 to R0
      add R1
      rs

Clearly, R0 is a bottleneck. And now with the new _mov_ instruction:

    fib:
      ; Swap R0 and R1
      mov r_1,r_2
      st R1
      ld R2

      ; Add R1 to R0
      add R1
      rs

[Back to the Top](#sweet-16)

#### Macro Problems

Most readers will have noticed something odd about our example above. What's
with the weird register names? The issue at this time is with the ca65
assembler. The _mov_ instruction is implemented with a macro. I currently do
not know how to convert tokens like R4 to the number 4 so that my macro can
emit the correct code.

The symbols "r_x" all map to the number "x". This means that you could just
use numbers and skip the symbols, but I do not advise this. At some future
time, the code will be updated when macros can manipulate Sweet-16 register
tokens. At that time, code using "r_x" will still work, but code using just
"x" will break.

I spent a lot of time pounding on sand trying to crack this issue. For now
this is the best I got.

[Back to the Top](#sweet-16)

### Exit Simulation

In order to facilitate testing code with the sim65, an op code has been added
to access the simulation exit point. In native code, a _jmp_ to the label exit
will exit the simulation with a return code equal to the value in the A
register. In Sweet-16 code this is accomplished with the $0F op-code with the
following byte being the return code for test run.

Since this is a "new" op-code, the assembler does not directly support it.

Further, support for this instruction is optional. There are four steps to
gaining access to this testing facility:

1. Include the line:
```
sw16_sim_support = 1
```

2. The include file "sweet_16_test.i65" contains macros to make this facility
easier to use. This file must be included after "sweet_16.i65" or
"sweet_16.a65" are included.

3. If linking to a Sweet-16 object file, it must also have been assembled with
the symbol "sw16_sim_support" defined. This also applies if the object file is
part of a library.

4. Run the code using the sim65 simulator. For example, in my tests, this
looks like this:
```
sim65 t65_sweet_16.out
```

To support this instruction, these are the macros that are added:

Macro | Description
------|--------------
sw16_tests_pass | Exit the simulation with a 0 return code (success).
sw16_tests_fail err_code | Exit the simulation with an err_code (2..255).
sw16_fail_ne err_code | Exit the simulation with an err_code (2..255) if not zero.
sw16_fail_eq err_code | Exit the simulation with an err_code (2..255) if zero.
sw16_fail_cc err_code | Exit the simulation with an err_code (2..255) if no carry.
sw16_fail_cs err_code | Exit the simulation with an err_code (2..255) if carry.
sw16_fail_p err_code | Exit the simulation with an err_code (2..255) if positive.
sw16_fail_m err_code | Exit the simulation with an err_code (2..255) if negative.
sw16_fail_nm1 err_code | Exit the simulation with an err_code (2..255) if not -1.
sw16_fail_m1 err_code | Exit the simulation with an err_code (2..255) if -1.

Note that to use these macros, the Sweet-16 CPU must be selected. Otherwise
an assembly error will be reported.

[Back to the Top](#sweet-16)

## The Future

I have some ideas to "improve" the Sweet-16, mostly to speed it up or save some
memory or to improve its versatility and capabilities. Here they are in no
particular order:

* The carry bit could be moved from R14H to R14L. Let's face it, R14L is
useless. With R14H being trashed all the time there is no way to use it. Moving
the carry bit here would simplify the code that relies on the "result"
register. This could save time and space

* Detecting the stored carry bit directly via the _bbc_ and _bbs_ instructions
for saved space, time, and code clarity.

* Adding an overflow bit to allow for reliable signed comparisons. This would
add a few bytes of code and slow things down a bit in exchange for a useful
(?) capability. The problem with this is that it would require additional
operations to utilize this new flag. Given that we are pretty much out of
op codes, this seems unlikely.

* Add the ability to call native code as a subroutine from Sweet-16 code. This
would allow reverse-embedding of code with lower overhead. It would give the
VM a sort of user defined micro-code. This would replace the seldom (?)
used _bk_ instruction. The simple implementation would be to encode a 16 bit
subroutine address, but other ideas include using a single post byte to index
into a table of subroutines. It might even be possible to add banked memory
support. Not sure how that would work and on sober reflection, simpler seems
to be better.

[Back to the Top](#sweet-16)

## References

* The Apple-II: A tour of the computer with a brief discussion of Sweet-16 in
[**May 1977 Byte**](https://archive.org/download/byte-magazine-1977-05/1977_05_BYTE_02-05_Interfacing.pdf).
* A follow on article with a much more in-depth look at the Sweet-16 was in
[**November 1977 Byte**](https://archive.org/download/byte-magazine-1977-11/1977_11_BYTE_02-11_Memory_Mapped_IO.pdf).
* The origin of the machine readable code, plus a great deal of useful
information about the Sweet-16 is found at 6502.org page
[**Porting Sweet 16**](http://www.6502.org/source/interpreters/sweet16.htm).
* Further information is also available from this article in
[**Wikipedia**](https://en.wikipedia.org/wiki/SWEET16).

[Back to the Top](#sweet-16)
