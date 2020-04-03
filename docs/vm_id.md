# The VM Instruction Decoder

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
* [Instruction Decoders](#instruction-decoders)
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

## Design Comparisons

[Back to the Top](#the-vm-instruction-decoder)
