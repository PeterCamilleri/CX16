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

* Byte Code Interpreter (a general name).
* P-Code Interpreter for UCSD Pascal.
* TIL - Threaded Interpretive Language, the most prominent being FORTH.
* YARV - Yet Another Ruby Virtual machine, introduced in Ruby 1.9.0
* JVM - Java Virtual Machine. Famous for running on many hosts.
* EVM - Erlang Virtual Machine. Noteworthy in support of functional programming.
* LLVM - formally known as the Low Level Virtual Machine, which is not really
a virtual machine as it is more a mid level abstract compiler construct.
* MetaProcessor - the label given to the Sweet-16 virtual coprocessor for the
Apple \]\[.

This is just a sample. There too many to list here, this is a powerful and
popular programming tool.
