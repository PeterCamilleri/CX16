# Utilities

The utilities section of this repository covers various macros, subroutines,
and tools that may be of help to the development of CX16 programs. These are
described below:

## utilities.i65

This is an include file full of macros that assist in the writing of CX16
programs in 65C02 assembly language.

One area missing in the 65C02 instruction set are operations that manipulate
16 bit quantities in memory. This table lists the options provided by this
utilities package.

Operation    | var    | zpp        | zpy
-------------|--------|------------|------------
Add 1        | inc_16 | inc_zpp_16 | inc_zpy_16
Subtract 1   | dec_16 | dec_zpp_16 | dec_zpy_16
Add a number | adj_16 | adj_zpp_16 | adj_zpy_16
