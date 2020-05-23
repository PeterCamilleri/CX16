# \<name goes here\> Compiler Virtual Machine Architecture Manual


## Contents

* [Introduction](#introduction)
   * [Design Choices](#design_choices)
   * [Registers](#registers)
   * [Addressing Modes](#addressing_modes)
   * [Data Types](#data_types)
   * [Putting it together](#putting_it_together)
* [Operations Reference](#operations_reference)
   * [Add](#add)
   * [Subtract](#subtract)

## Introduction

This document contains an overview of the \<name goes here\> Compiler Virtual
Machine Architecture Mark 1. This is a highly simplified, bare bones version
of the final version and serves as a starting point for development efforts.

The following sections detail the programmer visible aspects of the VM1
virtual machine.

### Design Choices

This project has already undertaken an examination of virtual machine design
choices available to the Commander X16 and its W65C02S processor. This section
links back to some of those design options in other parts of the CX16 project.
For your reference these choices are listed below:

* Instruction Pointer uses [Option 2](./vm_ip.md#option-2)
* Instruction Decoder uses [Decoder 8](./vm_id.md#decoder-8)
* Data Stack uses a [Page Stack](./vm_sp.md#the-page-stack)
* Return Stack uses the [System Stack](./vm_sp.md#the-system-stack)

### Registers

The virtual machine supports the following virtual registers:

* PB - 16 bit procedure base. Part of the instruction pointer.
* PO - 8 bit procedure offset. Part of the instruction pointer.
* RS - 8 bit return stack pointer. This stack is located in page 1.
* DS - 8 bit data stack pointer. This stack is located in page 4.
* FP - 16 bit frame pointer. Points to the base of the local frame.

In addition there are these pseudo "registers", values, and operations:

* t1, t2 etc - Temporary 16 bit registers. Not programmer accessible but
mentioned since they are referenced in some of the instruction details.
* DS.pop - The result of popping a word off of the data stack.
* DS.push(value) - Push value as a word onto the data stack
* RS.pop - The result of popping a word off of the return stack.
* RS.push(value) - Push value as a word onto the return stack

In addition the following operators are employed:

| Expression     | Description
|:--------------:|-------------------
|a + b           | a plus b
|a - b           | a minus b
|a \* b          | a times b
|a &divide; b    | a divided by b (signed)
|a U&divide; b   | a divided by b (unsigned)
|a % b           | a modulus b (signed)
|a U% b          | a modulus b (unsigned)
|a & b           | a bit-wise AND b
|a \| b          | a bit-wise OR b
|a &oplus; b     | a bit-wise XOR b
|a = b           | does a = b?
|a &ne; b        | is a &ne; b?
|a > b           | is a > b? (signed)
|a U> b          | is a > b? (unsigned)
|a &ge; b        | is a &ge; b? (signed)
|a U&ge; b       | is a &ge; b? (unsigned)
|a < b           | is a < b? (signed)
|a U< b          | is a < b? (unsigned)
|a &le; b        | is a &le; b? (signed)
|a U&le; b       | is a &le; b? (unsigned)

### Addressing Modes

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
ip8        |  p8    | Operand string or structure constants               | @(PB+ND8)
ip16       |  p16   | Operand string or structure constants               | @(PB+D16)
proc       |  none  | Offset within the current procedure scope           | Proc_Offset8

Where UD8 is an unsigned 8 bit displacement, ND8 is a negative 8 bit
displacement and D16 is a 16 bit displacement.

### Data Types

Many op codes can deal with more than one type of data. Like addressing modes
this takes the form of a suffix. The following primitive data types are
supported:

Type    | Suffix | Description
--------|:------:|------------------------------
byte    |  b     | An 8 bit unsigned value
word    |  w     | A 16 bit value
address |  ea    | A 16 bit address of an operand
implied |  none  | The data type is implied by the op code

### Putting it together

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

Notes:
* The operation details are meant to express the semantics of each
operation rather than the exact details of its implementation. Actual code
will act as described in the details, even though they may be optimized
to save time and code space.
* The operation details do not describe low-level details about the fetching
of instructions or pushing and popping of data with stacks.

### Add

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

### Load

Load data onto the data stack.

* DataTypes: Byte, Word, Effective Address
* Addressing Modes: immediate, local, global, tos0, tos8, tos16, ip8, and ip16
* Valid combinations:

|       | immediate | local    | global  | tos0    | tos8      | tos16      | ip8       | ip16      |
|-------|:---------:|:--------:|:-------:|:-------:|:---------:|:----------:|:---------:|:---------:|
|Byte   |_vm\_lbi_  |_vm\_lbl_ |_vm\_lbg_|_vm\_lbt_|_vm\_lbt8_ |_vm\_lbt16_ |_vm\_lbp8_ |_vm\_lbp8_ |
|Word   |_vm\_lwi_  |_vm\_lwl_ |_vm\_lwg_|_vm\_lwt_|_vm\_lwt8_ |_vm\_lwt16_ |_vm\_lwp8_ |_vm\_lwp8_ |
|EA     |           |_vm\_leal_|         |         |_vm\_leat8_|_vm\_leat16_|_vm\_leap8_|_vm\_leap8_|

### Subtract

Subtract word sized data on the data stack. Note that since byte sized data is
automatically "promoted" to a word when loaded, this operation also serves
to add bytes.

* DataTypes: Implied
* Addressing Modes: Implied
* Valid combinations: _vm\_sub_

#### Operation Details:
<pre><code>t1 &larr; DS.pop
t2 &larr; DS.pop
DS.push(t2-t1)
</code></pre>
