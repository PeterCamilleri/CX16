# The VM Instruction Pointer

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
   * [Low Ram Virtual Instruction Pointers](#low-ram-virtual-instruction-pointers)

## Introduction

The VM Instruction Pointer's job is point into memory. It gracefully sweeps
and hops its way through the the application's code, often branching and
looping and covering a lot of ground.

On a less poetic note, it needs to do very good job at:

* Sweeping through the entire address range of the code space.
* Stepping to the next address.
* Updating it's value for absolute jumps and subroutine returns.
* Adding signed values to it to implement relative branches

The W65C02S chip behind these virtual machines is not at all into doing
graceful memory sweeps. It likes to confine data to fixed locations. It does
have two index registers which can be used to expand things, but only to 256
bytes, no further. These puny, 8-bit registers have a severely limited reach.
There are indirect addressing modes with full 16-bit ranges. They are rather
slow and have no instructions that manipulate the address as a whole.
Everything has to be coded up explicitly, wasting both code space and
clock cycles.

Yet, in a virtual machine, this simple task is performed by one of the most
crucial bits of code. Its performance reflects on all instructions. Wasted
cycles here are wasted in everything the VM does.

On the other hand, if this were easy, would there be a whole section on it?
It is precisely these difficulties that make the task of programming the
VM instruction pointer all the more interesting. This is so true that there
is even a [**famous quote**](../README.md#famous-quote) about this.

So, we face challenging questions like:

* How fast can we make the code?
* How compact?
* Are there things we can trade off to improve the code?
* How do we deal with banked RAM? Assuming that's a thing we're doing.

Speaking of banked RAM, our study of the VM instruction pointer will be
divided into two sections, one for the VM application in low ram and the
other where it resides in banked, high ram. These correspond to options 1X
and 2X in the [**sample VM layouts**](./vm_layouts.md).

The second thing that must be considered is, what, exactly is being fetched?
Here almost all VM designs fall into one of two sub-camps. In these, VM
application code consists of one of the following:

* A series of byte codes or tokens. This is by far the most common and is
typically what one thinks of in most VM architectures. The instruction may
require some additional follow-on bytes. In this case we will be putting
our fetched byte code into the A register.
* A 16-bit address. This is most often seen with threaded languages like
FORTH. The instruction may also require additional some follow-on bytes or
16-bit words. In this case we will be putting our fetched 16-bit word into
a 16-bit working register located in the zero page.

There may be other options, but they are too obscure to be considered here.

[Back to the Top](#the-vm-instruction-pointer)

## Low Ram Virtual Instruction Pointers

This section will examine VM instruction pointers that use unmapped, 16-bit
addresses to access VM application code located (almost always) in the 40K
low ram memory space. Due to its simpler nature, this category of design has
the best opportunities for optimizing both bytes of code space and clock
cycles of time that are consumed.

wip

[Back to the Top](#the-vm-instruction-pointer)
