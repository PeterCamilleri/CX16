# The branches.i65 file

This is an include file full of macros that assist CX16 programmers in
enhancing the branch instructions of the 65C02 processor. It consists of a
number of utility macros that are normally included in a source file with the
following line of code:

    .include "branches.i65"

This will include all of the macros of the library. Alternatively, the
programmer may opt to use the lower level include files (see the tables below)
and only load in those components required by their application. This may save
some time in assembling the program.

Note that none of the code in this file has any dependency on any ROMs, entry
points, or other software in the system. It can be used with any 65C02 system.

The 6502 family comes with a spartan limited set of branch instructions for
most bits in the Processor Status Register (P). The 65C02 helps this a little
bit by adding in the unconditional branch alway or "bra". There are still
glaring omissions. Other 8-bit microprocessors, notably the 6809, expand on
this basic set with several improvements:

**Long Branches:** The standard branch instruction only has an 8-bit range. This
means that it can only reach so far before you encounter the following error:

    mysh>ca65 -l tools\too_far.lst tools\too_far.a65
    tools\too_far.a65(5): Error: Range error (128 not in [-128..127])

Long branches can be used to get around this problem. Too bad the 6502 doesn't
have any.

**Composite Unsigned Branches:** Some conditions resulting from subtraction or
comparison of unsigned values require more that one status bit to be examined.
These conditions are "less than or equal" to (&le;) and "greater than" (>)
Instructions that test for these unsigned conditions are absent in the 6502.

**Composite Signed Branches:** Most conditions resulting from subtraction or
comparison of signed values require more that one status bit to be examined.
These conditions are "less than" (<), "less than or equal" to (&le;),
"greater than or equal to" (&ge;), and "greater than" (>). Instructions that
test for these unsigned conditions are absent in the 6502.

**Long Composite Unsigned Branches:** Long versions of the above.

**Long Composite Signed Branches:** Long versions of the above.

## Supported Operations

The following tables show the enhanced set of branch operations provided by
the branches macro library. Note that entries in *italics* are actually
standard 65C02 instructions.

**Simple Branches:** These are branches based directly on the P register bits.
The short versions of these are the built-in standard branches and are
mentioned here only for the sake of completeness. The long versions are
contained in "l_branches.i65".

Condition        | Short | Long
-----------------|-------|-------
Always           | *bra* | lbra
Carry Cleared    | *bcc* | lbcc
Carry Set        | *bcs* | lbcs
Zero Cleared     | *bne* | lbne
Zero Set         | *beq* | lbeq
Negative Cleared | *bpl* | lbpl
Negative Set     | *bmi* | lbmi
Overflow Cleared | *bvc* | lbvc
Overflow Set     | *bvs* | lbvs

**Composite Branches:**

Composite branches are used to make decisions about unsigned (u) and signed
(s) data. In general, these instructions are meant to be used after a subtract
(sbc) instruction or a compare (cmp) instructon or a compare macro (cmp_var_16,
cmp_zpp_16, or cmp_zpy_16) from the assist_16 library. The short versions are
contained in "u_branches.i65" and "s_branches.i65" and the long versions in
"lu_branches.i65" and "ls_branches.i65". Two exceptions are lbeq and lbne
which are part of "l_branches.i65".

Condition | Short | Long  | Short | Long
----------|-------|-------|-------|-------
a <  b    | bult  | lbult | bslt  | lbslt
a &le; b  | bule  | lbule | bsle  | lbsle
a = b     | *beq* | lbeq  | *beq* | lbeq
a &ne; b  | *bne* | lbne  | *bne* | lbne
a &ge; b  | buge  | lbuge | bsge  | lbsge
a > b     | bugt  | lbugt | bsgt  | lbsgt

## Fun with Flags (Optional)

This installment of Fun with Flags is not presented by Dr Sheldon Cooper.

In order to get a better understanding of branch instructions and macros based
on one or more flags, it is very useful to understand the flags themselves. In
particular, this section will examine how flags are used to convey the results
of comparing two numbers.

The P register contains eight bits, four of which are involved in the
comparison process. These flags (in bold) are:

Bit # | Name  | Description
------|-------|--------------
**0** | **C** | **The carry/borrow bit.**
**1** | **Z** | **The zero bit.**
2     | I     | The interrupt disable bit.
3     | D     | The decimal mode bit.
4     | B     | The break interrupt bit.
5     | 1     | Unused bit, always 1.
**6** | **V** | **The overflow bit.**
**7** | **N** | **The negative bit.**
