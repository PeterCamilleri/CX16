# Implementing VM Stacks

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
* [Stack Options](#stack-options)
   * [The System Stack](#the-system-stack)

## Introduction

This section will focus on the options available for providing stack support.
This means test cases will be designed with the goal of making the best use
of the limited resources of the W65C02S. Studies will note the resources of
memory and clock cycles used by each design.

To compare the designs, the following uses for stacks are examined:

1. Holding subroutine return addresses.
2. Passing parameters to a function or procedure.
3. Accessing parameters to this function or procedure.
4. Setting the return value for this function.
5. Getting return values back from functions.
6. Allocation of local variables.
7. Accessing those local variables.
8. Preserving native registers and variables when necessary for internal
virtual machine code.

[Back to the Top](#implementing-vm-stacks)

## Stack Options

In this section, let's take a look at the sorts of stacks available for use.
In very general terms these fall into one of two camps:

* Small stacks of 256 bytes or less.
* Larger stacks with no 256 byte size limit.

Now let's look at what low level operations fit our use cases:

* Pushing data onto the stack.
* Popping data from the stack.
* Creating stack frames.
* Destroying stack frames.
* Accessing data in the frame using a frame pointer and an
offset.
* Performing arithmetic and logic operations on stack data.

And as if that weren't enough there are still more considerations:

* Are there any special alignment requirements to use the stack?
* Can the stacks be moved around for efficient multi-threading?
* Can the stack share space with a heap to support dynamic memory allocation?
* When we index from the stack pointer, does the offset value need to be
signed, or can we make do with an unsigned offset?
* Can we divide the tasks of our stack into multiple stack types, each better
suited to the tasks assigned to it?

There are actually a lot of variations of the code that can be used to
implement the functionality of a stack. The following sections examine a
few of these possibilities:

[Back to the Top](#implementing-vm-stacks)

### The System Stack

The W65C02S stack pointer (S) is used to provide a small stack (256 bytes)
with a fixed location in memory page 1. It is reasonably good at pushing and
popping data, especially with the enhanced instruction set of the CMOS
version of the chip:

```
  php                    ; Push the processor status register.
  phy                    ; Push Y (Enhancement)
  phx                    ; Push X (Enhancement)
  pha                    ; Push A

  pla                    ; Pull A
  plx                    ; Pull X (Enhancement)
  ply                    ; Pull Y (Enhancement)
  plp                    ; Pull the processor status register.
```

No other operations are available for data on the stack. In particular it is
not possible to use the S register in any sort of indexed addressing mode. It
is possible to simulate this however, as shown in this example:

```
  ; Add the last two bytes pushed onto the stack.
  pla                    ; Get the last byte pushed
  tsx                    ; X mirrors S
  clc                    ; Prepare to add.
  adc $101,x             ; Add in the byte above.
  sta $101,x             ; Save result.
```

While the system stack is well suited to the task of pushing and pulling
values, it's small size makes it unsuitable for holding stack frames. It is
a candidate for use as an evaluation stack, but again, its small size can
make things a bit cramped. It is fixed in page 1, meaning that multi-threading
systems are forced to carve up the tiny space available, or a lot of data
needs to be copied to move stacks.

Notes:
* The system stack is naturally page aligned in page 1.
* The pull instructions all modify the P register. So in any sequence
that seeks to preserve that register, its pull instruction must be the last
one in the sequence. One such sequence is shown above.
* In addition, since the system stack is used during interrupt processing, no
data should ever be placed or accessed from addresses less than the address
$101 + S.

[Back to the Top](#implementing-vm-stacks)
