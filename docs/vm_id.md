# The VM Instruction Decoder

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
* [Instruction Decoders](#instruction-decoders)
   * [Acheron](#acheron)
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


[Back to the Top](#the-vm-instruction-decoder)

## Design Comparisons

Decoder   | Clocks | Target       | Notes
----------|:------:|--------------|-------
Acheron   | 11     | 128 + Carry  | Not ROM friendly
Acheron C | wip    | wip          | wip


[Back to the Top](#the-vm-instruction-decoder)
