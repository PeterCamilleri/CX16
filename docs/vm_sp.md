# Implementing VM Stacks

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
* [Stack Options](#stack-options)

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

* Can the stacks be moved around for efficient multi-threading?
* Can the stack share space with a heap to support dynamic memory allocation?
* When we index from the stack pointer, does the offset value need to be
signed, or can we make do with an unsigned offset?
* Can we divide the tasks of our stack into multiple stack types, each better
suited to the tasks assigned to it?

[Back to the Top](#implementing-vm-stacks)
