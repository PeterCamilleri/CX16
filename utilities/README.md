# Utilities

The utilities section of this repository covers various macros, subroutines,
and tools that may be of help to the development of CX16 programs. These are
described below:

## The utilities.i65 file

This is an include file full of macros that assist in the writing of CX16
programs in 65C02 assembly language. One area missing in the 65C02 instruction
set are operations that manipulate 16 bit quantities in memory. This table
lists the options provided by this utilities package.

Operation/Mode | var        | zpp        | zpy
---------------|------------|------------|------------
Initialize     | set_var_16 | set_zpp_16 | set_zpy_16
Increment      | inc_var_16 | inc_zpp_16 | inc_zpy_16
Decrement      | dec_var_16 | dec_zpp_16 | dec_zpy_16
Adjust         | adj_var_16 | adj_zpp_16 | adj_zpy_16

#### set_var_16

A macro to initialize a 16 bit variable in memory with a value.

*Parameters:*
* var - the name of a zero page or absolute addressed 16 bit variable.
* value - a value used to initialize var.

*Notes:*
* Often clobbers the A register, Z and N flags.
* Optimized for special case values like 0, $00xx, and $xx00

*Example:*

    .zeropage
    my_var: .res  2   ; My variables in the zero page for this example.
    root:   .res  2

    .import root_array:absolute  ; Import a reference to an array in another file.

    .code
    ; stuff omitted.
    set_var_16 my_var, 0
    set_var_16 root, root_array

#### set_zpp_16


#### set_zpy_16


#### inc_var_16

A macro to increment a 16 bit variable in memory.

*Parameters:*
* var - the name of a zero page or absolute addressed 16 bit variable.

*Notes:*
* Clobbers the Z and N flags.

*Example:*

    .zeropage
    my_var: .res  2   ; My variable in the zero page in this example.

    .code
    ; stuff omitted.
    inc_var_16 my_var ; Step to the next.

#### inc_var_16


#### inc_zpp_16


#### inc_zpy_16


#### dec_var_16


#### dec_zpp_16


#### dec_zpy_16


#### adj_var_16


#### adj_zpp_16


#### adj_zpy_16

### Usage

The utility macros are normally be included in a source file with the following
line of code:

    .include "utilities.i65"

The macros can then be used at will by the programmer.
