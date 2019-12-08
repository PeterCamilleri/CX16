# Virtual Machines

The [**Wikipedia**](https://en.wikipedia.org/wiki/Virtual_machine) defines a
virtual machine as:

_In computing, a virtual machine (VM) is an emulation of a computer system.
Virtual machines are based on computer architectures and provide functionality
of a physical computer. Their implementations may involve specialized hardware,
software, or a combination._

In this study we will focus on software based virtual machines for the
W65C02S processor in the Commander X 16 neo-retro computer.

The above definition states that a VM allows one computer system to emulate
another. What it does not mention is that the machine being emulated may not
actually exist. Contrary to the definition, it is often desirable to emulate
machines that are in fact purely hypothetical in nature. This can allow the
emulation of a processor more ideally suited to a specific task than any
"real" system.

This dove tails nicely with the "onion" system model, where hardware and
software are composed of many layers like an onion; Each layer of the system
"wrapping up" the layers below it. A VM is just such a layer.

VMs take many forms so that it is no surprise that over the years, many names
have been given to this concept. Some alternatives are:

* Byte Code Interpreter - a subclass of virtual machines with byte codes.
* P-Code Interpreter - The VM for UCSD Pascal.
* TIL - Threaded Interpretive Language, the most prominent being FORTH.
* YARV - Yet Another Ruby Virtual machine, introduced in Ruby 1.9.0
* JVM - Java Virtual Machine. Famous for running on many hosts.
* EVM - Erlang Virtual Machine. Noteworthy in support of functional programming.
* LLVM - formally known as the Low Level Virtual Machine. Not really a virtual
machine at all. It is much more a mid level abstract compiler construct.
* MetaProcessor - the label given to the  virtual coprocessor for the
Apple \]\[. Also called the Pseudo Machine Interpreter. (See below)

This is just a sample. There too many to list here, this is a powerful and
popular programming tool.

The CX16 Repository contains the following Virtual Machine implementations that
are intended for use in the Commander X 16 computer system.

## Virtual Machines

These are virtual machines that are largely ready to be used in the Commander
X 16 system or it's emulator. At a minimum, they have passed simulation
testing and the code seems to work. They may be lacking enhancements needed
to work better in the X16, but that will require community feedback to move
forward on that front.

This list should grow over time.

### Sweet-16

This famous virtual machine was built into the Integer Basic of the Apple \]\[.
It is such a famous virtual machine that this repository contains a port of
it to the ca65 assembler with a W65C02S processor. Take a look at
[**Sweet-16**](./sweet_16.md) for more information on this VM.

## Work In Progress

These are ideas that are still being developed. If there any suggestions for
new ideas, this would be most appreciated. You can make a suggestion by raising
an issue on Github.

### AcheronVM

The [**Acheron VM**] is an interesting effort to maximize VM performance on a
6502 system. It is described in this
[**Amazing Video**](https://youtu.be/zdJnz6-d060). I intend to look into
porting it to the X16 and maybe placing it into one of the language ROM banks.

### Address Indirect Interpreter

The classic threaded interpreter for FORTH. My vision is of a language that
fully supports the X16 and it's banked memory with support for the kernel,
Vera video, sound (tbd), and other peripherals. That at least is the goal.
