# Utilities

The utilities section of this repository covers various macros, subroutines,
and tools that may be of help to the development of CX16 programs. These are
described below:

## utilities.i65

This is an include file full of macros that assist in the writing of CX16
programs in 65C02 assembly language.

To use this file, there are a number of options for locating this file:

* In the same folder as the file(s) that use it.
* In a folder named in the "-I <folder>" option on the command line.
* In a folder listed in the environment variable CA65_INC.
* In a folder named "asminc" of the folder defined in the environment variable
CC65_HOME.

In source files it will then be included by the statement:

    .include "utilities.i65"
