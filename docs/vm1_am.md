# \<name goes here\> Compiler Virtual Machine Architecture Manual

## Introduction

This document contains an overview of the \<name goes here\> Compiler Virtual
Machine Architecture Mark 1. This is a highly simplified, bare bones version
of the final version and serves as a starting point for development efforts.

The following sections detail the programmer visible aspects of the VM1
virtual machine.

## Registers

The virtual machine supports the following virtual registers:

* IP - 16 bit instruction pointer.
* RS - 8 bit return stack pointer. Data is located in page 1.
* DS - 8 bit data stack pointer. Data is located in page 4.
* FP - 16 bit frame pointer.

In addition there are these pseudo "registers", values, and operations:

* t1, t2 etc - Temporary 16 bit registers. Not programmer accessible but
mentioned since they are referenced in some of the instruction details.
* DS.pop - The result of popping a word off of the data stack.
* DS.push(value) - Push value as a word onto the data stack
* RS.pop - The result of popping a word off of the return stack.
* RS.push(value) - Push value as a word onto the return stack


## Addressing Modes

In most cases, addressing modes are specified as a suffix to the virtual
machine op code. In some cases, where there is only one option, this suffix
is omitted. The virtual machine supports the following addressing modes:

Mode       | Suffix | Description                                         | Details
-----------|:------:|-----------------------------------------------------|--------
inherent   |  none  | Operands are contained on one of the stacks.        | Varies
immediate  |  i     | Operands are constants embedded in the instruction. | Literal
local      |  l     | Operands are in the local frame                     | @(FP+ud8)
global     |  g     | Operands are global data                            | @D16
tos0       |  t     | Operands are accessed via a pointer                 | @DS.pop
tos8       |  t8    | Operands in a array, structure or pointer to same   | @(DS.pop+UD8)
tos16      |  t16   | Operands in a array, structure or pointer to same   | @(DS.pop+D16)
ip8        |  p8    | Operand string or structure constants               | @(IP+SD8)
ip16       |  p16   | Operand string or structure constants               | @(IP+D16)
proc       |  none  | Offset within the current procedure scope           | Proc_Offset8

Where UD8 is an unsigned 8 bit displacement, SD8 is a signed 8 bit
displacement and D16 is a 16 bit displacement.

## Data Types

Many op codes can deal with more than one type of data. Like addressing modes
this takes the form of a suffix. The following primitive data types are
supported:

Type    | Suffix | Description
--------|:------:|------------------------------
byte    |  b     | An 8 bit unsigned value
word    |  w     | A 16 bit value
address |  ea    | A 16 bit address of an operand
implied |  none  | The data type is implied by the op code

## Putting it together

VM1 assembly instructions (assuming an assembler ever exists) are composed
of up to four parts, joined together. These are:

    "vm_" <operation> {<data_type>} {<addressing mode>}

Notes:
* The prefix "vm_" ensures that virtual machine opcodes will not conflict
with any native keywords of the assembler.
* The \<data_type\> and \<addressing mode\> are not needed for many
operations. In those cases they are omitted. When they are needed, they
are mandatory.

## Operations Reference

The VM1 supports the following operations:

Note that the operation details are meant to express the semantics of each
operation rather than the exact details of its implementation. Actual code
will act as described in the details, even though they may be optimized
to save time and code space.

## Add

Add word sized data on the data stack. Note that since byte sized data is
automatically "promoted" to a word when loaded, this operation also serves
to add bytes.

* DataTypes: Implied
* Addressing Modes: Implied
* Valid combinations: _vm\_add_

#### Operation Details:
<pre><code>t1 &larr; DS.pop
t2 &larr; DS.pop
DS.push(t2+t1)
</code></pre>

