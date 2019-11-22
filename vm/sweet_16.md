# Sweet-16

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
we've replaced the old battered M6502 with a less dented W65C02S. I plan to
take full advantage of all of these over the course of time. And one last
note, don't ask about the miserable, terse, confusing labels. Just don't!

## Co-Virtual Machine

I call Sweet-16 a co-virtual machine (CVM) because it is intended to be used
embedded in native 6502 code. This is analogous to the old
[**8087**](https://en.wikipedia.org/wiki/Intel_8087) floating point
coprocessor that allowed in-line access to higher math functions.

The classic (with updated syntax) example of this from way back is:

              lda in,y       ; Get a char.
              cmp #"M"       ; Is it "M" for move?
              bne nomove     ; No, skip move.
              jsr sw16       ; Yes, call sweet16
    mloop:    ld  @R1        ; R1 holds source address
              st  @R2        ; R2 holds dest. address
              dcr R3         ; Decrement length.
              bnz mloop      ; Loop until done.
              rtn            ; Return to 6502 mode.
    nomove:   cmp "E"        ; Is it "E" for exit?
              beq exit       ; Des, exit.

Note how Sweet-16 code can be used in-line with native code. This ease of
transition between the two modes is the secret of the success of the Sweet-16
programming tool.

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


## Sweet-16 Instruction Set

This section will focus on the use of the various Sweet-16 instructions. It
will focus on the user's view of these instructions rather than the
implementer's point of view. Further it will attempt to avoid the confusion
created by some of the archaic terminology used in existing documentation:

Old     | New  | Description
--------|------|---------------
Double  | Word | A 16 bit word
implied | Byte | An 8 bit byte

### ADD -- Add Word Register to the Accumulator

Add the word register to the accumulator.
<pre><code>R0 &larr; R0 + Rn</code></pre>

Example:

    add R5         ; Add R5 to R0

Notes:
* The status and carry bit are set for testing.


### CPR -- Compare Word Register with the Accumulator

Subract the word register from the accumulator and store the result in R13.
<pre><code>R13 &larr; R0 - Rn</code></pre>

Example:

    cpr R5         ; Compare R0 with R5

Notes:
* The status and carry bit are set for testing.


### INR - Increment Word Register

Add 1 to the selected word register.
<pre><code>Rn &larr; Rn + 1</code></pre>

Example:

    inr R5         ; Increment R5

Notes:
* The status is set for testing, the carry bit is cleared.


### LD -- Transfer Word Register to Accumulator

Load the specified register into the accumulator:
<pre><code>R0 &larr; Rn</code></pre>

Example:

    ld  R7         ; Copy R7 to R0

Notes:
* The status is set for testing, the carry bit is cleared.


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


### LDD @ -- Transfer Memory Word to Accumulator

Fetch the word addressed by the specified register into the accumulator. The
the specified register is incremented by 2.
<pre><code>R0 &larr; memory_word[Rn]
Rn &larr; Rn + 2</code></pre>

Example:

    ldd @R5        ; Transfer the word pointed to by R5 to R0 and step R5

Notes:
* The status is set for testing, the carry bit is cleared.


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


### POPD -- Transfer Memory Word to Accumulator

The specified register is decremented by 2. Then fetch the word addressed by
the that register into the accumulator.
<pre><code>Rn &larr; Rn - 2
R0 &larr; memory_word[Rn]</code></pre>

Example:

    pop @R5         ; Step R5 back and transfer the word pointed to by R5 to R0

Notes:
* The status is set for testing, the carry bit is cleared.


### SET -- Load Register Immediate Word

Load the specified register with a 16 bit literal value:
<pre><code>Rn &larr; literal value</code></pre>

This instruction is used to initialize registers with starting values.
Example:

    set R5,$1234   ; Set R5 to $1234

Notes:
* The status is set for testing, the carry bit is cleared.
* It is not possible to use this instruction to set R15.


### ST -- Transfer Word Accumulator to Register

Store the accumulator into the specified register:
<pre><code>Rn &larr; R0</code></pre>

Example:

    st  R7         ; Copy R0 to R7

Notes:
* The status is set for testing, the carry bit is cleared.


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


### STD @ -- Transfer Accumulator Word to Memory

Store the word in the accumulator to the memory addressed by the specified
register. That register is incremented by 2.
<pre><code>memory_word[Rn] &larr; R0
Rn &larr; Rn + 2</code></pre>

Example:

    std @R5        ; Transfer R0 to the memory word pointed to by R5, step R5

Notes:
* The status is set for testing, the carry bit is cleared.


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


### SUB -- Subtract Word Register from the Accumulator

Subtract the word register from the accumulator.
<pre><code>R0 &larr; R0 - Rn</code></pre>

Example:

    sub R5         ; Subtract R5 from R0

Notes:
* The status and carry bit are set for testing.


## References:

* The Apple-II, discusses the computer with a brief discussion of Sweet-16 in
[**May 1977 Byte**](https://archive.org/download/byte-magazine-1977-05/1977_05_BYTE_02-05_Interfacing.pdf).
* A follow on article with a much more in-depth look at the Sweet-16 was in
[**November 1977 Byte**](https://archive.org/download/byte-magazine-1977-11/1977_11_BYTE_02-11_Memory_Mapped_IO.pdf).
* The origin of the machine readable code, plus a great deal of useful
information about the Sweet-16 is found at 6502.org page
[**Porting Sweet 16**](http://www.6502.org/source/interpreters/sweet16.htm).
[**Wikipedia**](https://en.wikipedia.org/wiki/SWEET16)
