# Utilities

The utilities section of this repository covers various macros, subroutines,
and tools that may be of help to the development of CX16 programs. These are
described below:

## The assist_16.i65 file

This is an include file full of macros that assist CX16 programmers in handling
16 bit values in 65C02 assembly language. It consists of a number of utility
macros that are normally included in a source file with the following line of
code:

    .include "assist_16.i65"

See the readme file in the assist_16 folder for more information.

## The branches.i65 file

This is a file full of macros that enhance the branch capability of assembly
language the 65C02 with long branches and branches on composite condition
codes. These are included in the source file with the following line of
code:

    .include "branches.i65"

See the readme file in the branches folder for more information.
