# The branches.i65 file

[Back to CX16 Root](../README.md)

## Contents

* [Introduction](#introduction)
* [Supported Operations](#supported-operations)
   * [Simple Branches](#simple-branches)
   * [Composite Branches](#composite-branches)
* [Fun with Flags](./fun_with_flags.md)

## Introduction

This is a top level include file that includes files full of macros that
assist CX16 programmers in enhancing the branch instructions of the 65C02
processor. It consists of a number of utility macros that are normally
included in a source file with the following line of code:

    .include "branches.i65"

This will include all of the macros of the library. Alternatively, the
programmer may opt to use the lower level include files (see below)
and only load in those components required by their application. This may save
some time in assembling the program.

Note that none of the code in this file has any dependency on any ROMs, entry
points, or other software in the system. It can be used with any 65C02 system.

The 6502 family comes with a spartan limited set of branch instructions for
most bits in the Processor Status Register (P). The 65C02 helps this a little
bit by adding in the unconditional branch alway or "bra". There are still
glaring omissions. Other 8-bit microprocessors, notably the 6809, expand on
this basic set with several improvements. To add flexibility, the branches
macros expand on the basics.

An analysis of the cost of these macros in memory space and clock cycles is
contained in the [**stats**](../stats.pdf) file.

[Back to the Top](#the-branchesi65-file)

## Supported Operations

The following tables show the enhanced set of branch operations provided by
the branches macro library. Note that entries in *italics* are actually
standard 65C02 instructions.

[Back to the Top](#the-branchesi65-file)

#### Simple Branches

These are branches based directly on the P register bits.
The short versions of these are the built-in standard branches and are
mentioned here only for the sake of completeness. The long versions are
contained in "l_branches.i65".

Condition        | Short | Long  |
-----------------|:-----:|:-----:|
Always           | *bra* | lbra  |
Carry Cleared    | *bcc* | lbcc  |
Carry Set        | *bcs* | lbcs  |
Zero Cleared     | *bne* | lbne  |
Zero Set         | *beq* | lbeq  |
Negative Cleared | *bpl* | lbpl  |
Negative Set     | *bmi* | lbmi  |
Overflow Cleared | *bvc* | lbvc  |
Overflow Set     | *bvs* | lbvs  |

Note: The native short branch instructions have the property that they are
position independent. This means they reach the same (relative) address no
matter if the code is relocated. The long branch version use the jump (jmp)
instruction "under the hood". This means that they are *not* position
independent. Usually this does not matter since the code is normally assembled
for the address where it will be run, but if code is copied from one region
of memory (like a ROM) to another region (like RAM), this could cause
some nasty problems.

[Back to the Top](#the-branchesi65-file)

#### Composite Branches

Composite branches are used to make decisions about unsigned (u) and signed
(s) data. In general, these instructions are meant to be used after a subtract
(_sbc_) instruction or a compare (_cmp_, for unsigned data only) instruction
or the compare macro (cmp_16) from the assist_16 library. The short versions
are contained in "u_branches.i65" and "s_branches.i65" and the long versions
in "lu_branches.i65" and "ls_branches.i65". Exceptions are *beq* and *bne*
which are native instructions and lbeq and lbne  which are part of
"l_branches.i65".

Condition | Short | Long  | Short | Long  |
:--------:|:-----:|:-----:|:-----:|:-----:|
a <  b    | bult  | lbult | bslt  | lbslt |
a &le; b  | bule  | lbule | bsle  | lbsle |
a = b     | *beq* | lbeq  | *beq* | lbeq  |
a &ne; b  | *bne* | lbne  | *bne* | lbne  |
a &ge; b  | buge  | lbuge | bsge  | lbsge |
a > b     | bugt  | lbugt | bsgt  | lbsgt |

[Back to the Top](#the-branchesi65-file)

## Optional Extras

For more information, a deeper dive into the flags of the 65C02 is presented
in the file I call [Fun with Flags](./fun_with_flags.md)

[Back to the Top](#the-branchesi65-file)
