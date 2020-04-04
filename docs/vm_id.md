# The VM Instruction Decoder

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
* [Instruction Decoders](#instruction-decoders)
   * [Acheron](#acheron)
   * [Acheron C](#acheron-c)
   * [Decoder 8](#decoder-8)
* [Design Comparisons](#design-comparisons)

## Introduction

Perhaps the most overlooked aspect of most processors is the instruction
decoder. It does not even have any programmer visible registers and is
usually a nondescript block in high level diagrams of the CPU, if it even
appears at all.

And yes, in our virtual machine designs instruction decoding has a huge
impact, not only on the instructions we implement but also the addressing
modes available. Providing these adequately and efficiently is quite a
challenge.

Thus, this is the point of focus of this document.

Instruction decoding is the task of taking an op code and using it to connect
to the appropriate actions. For virtual machines, this takes the form of
selecting the required piece of native code to perform the actions of the
instruction.

In "real" processors, there are two main camps for accomplishing this:

* Random Logic - the op code is the input to an array of logic that determines
what circuitry is needed to execute the instruction, and in what order.
* Table Lookup - the op code is the index into a dedicated memory array that
contains the address of a lower level micro-code that controls the circuitry
needed to execute the instruction.

Further, most real processors contain aspects of both of these approaches. So
with virtual machines, most instruction decoders have aspects of both:

* Random Logic - typically takes the form of bit manipulations, bit tests,
shifts, and rotates of the op code(s) followed by branches to the needed
native code.
* Table Lookup - primarily taking the form of tables of addresses, indexed by
the possibly modified op code, pointing to native code routines.

As with real machines, most virtual machines have elements of both.

[Back to the Top](#the-vm-instruction-decoder)

## Instruction Decoders

As you may have surmised by now, there are a lot of ways to create an
instruction decoder. Here we will examine a few ideas for both byte code
and threaded instruction decoders. These will all be general purpose
designs, suitable for a wide array of applications, but not necessarily
any specific or your application. The will probably need to be adapted,
configured, and above all tested to each use case.

[Back to the Top](#the-vm-instruction-decoder)

### Acheron

Again, if you haven't already taken a look, here is a link to the
[**Acheron VM**](https://github.com/AcheronVM/acheronvm). It is described in
this [**Amazing Video**](https://youtu.be/zdJnz6-d060).

The Acheron VM is a byte code machine where each byte contains a seven bit
op code and the eighth bit serves as an option bit. The decoder itself looks
like:

```
  asl                    ; Force the op code to be even.
  sta  pivot+1           ; Modify the _jmp_ target.

pivot:
  jmp (table_base)       ; Jump to the target.

.align 2                 ; Patch for 6502 bug.
                         ; Make sure we never cross a page boundary.
table_base:
  ; 128 entries for the op code table.
  .word  vm_add          ; Add integers
  .word  vm_sub          ; Subtract integers
  ;etc etc etc           ; Inverse Hyperbolic Cosine

```

On arrival at our selected target code, the carry flag is set if the high bit
of the op code was set, and cleared if it was cleared. So for example, both
$21 and $A1 will go to the same code handler, the former will have carry
cleared and the latter will have it set.

This code is very compact and quick, using just 7 code bytes plus 256 bytes
for the op code table and only 11 clock cycles. On the downside, it modifies
its own code while running. This means that this decoder is not a candidate
for being in a ROM where such modification is not allowed.

Another issue relates to bugs in the 6502 implementation of the _jmp_
instruction that causes it to fail if the address of the indirected pointer
crosses a page boundary. This is why the table_base label is preceded by the
align 2 directive. The W65C02S has no such bug.

While the code could be copied from ROM into RAM, this complicates matters
more than necessary. A simpler alternative exists and is our next candidate.

One last thing, the modified _jmp_ instruction represents additional system
state that may need to be saved/restored in some multi-tasking designs and
interrupt service routines. Assuming those things are to be supported.

[Back to the Top](#the-vm-instruction-decoder)

### Acheron C

This instruction decoder is based on the Acheron decoder with the addition of
being written for the newer W65C02S processor chip. This allows us to avoid
the use of self-modifying code to create the following:

```
  asl                    ; Force the op code to be even.
  tax                    ; Put the op code in X
  jmp (table_base,X)     ; Jump to the target.

table_base:
  ; 128 entries for the op code table.
  .word  vm_add          ; Add integers
  .word  vm_sub          ; Subtract integers
  ;etc etc etc           ; Inverse Hyperbolic Cosine

```

The behavior of the carry bit is identical to that of the original Acheron
instruction decoder. One difference is that the X register is used. With so
few registers to use, this could prove problematic in some cases.

This code is very compact and quick, using just 5 code bytes plus 256 bytes
for the op code table and only 9 clock cycles. On the downside, it does use
the X register.

[Back to the Top](#the-vm-instruction-decoder)

### Decoder 8

This instruction gets past the limit of 128 instruction, 7 bit op codes by
using two op code tables:

```
  asl                    ; Force the op code to be even.
  tax                    ; Put the op code in X
  bcs :+
  jmp (table_low,X)      ; Jump to the target for low op codes.
: jmp (table_high,X)     ; Jump to the target for high op codes.

table_low:
  ; 128 entries for the low op code table.
  .word  vm_add          ; Add integers
  .word  vm_sub          ; Subtract integers
  ;etc etc etc           ; Inverse Hyperbolic Cosine

table_high:
  ; 128 entries for the high op code table.
  .word  vm_xor          ; Xor integers
  .word  vm_and          ; And integers
  ;etc etc etc           ; Fast Fourier Transform
```

This code is very compact and quick, using just 10 code bytes plus two tables
of 256 bytes each for the op code tables and only 11 or 12 clock cycles. On
the downside, it also uses the X register.

One potential plus of having two tables is that they do not need to be
co-located. For example, the low table could be in ROM for standard
instructions while the high table could be in RAM for application specific
operations.

[Back to the Top](#the-vm-instruction-decoder)

## Design Comparisons

Decoder    | Clocks | Target Codes | Notes
-----------|:------:|:------------:|-------
Acheron    | 11     | 128 + Carry  | Not ROM friendly
Acheron C  | 9      | 128 + Carry  | Uses the X register
Decoder 8  | 11/12  | 2 \* 128     | Split tables, uses the X register

[Back to the Top](#the-vm-instruction-decoder)
