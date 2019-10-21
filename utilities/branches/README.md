# The branches.i65 file

This is a top level include file that includes files full of macros that
assist CX16 programmers in enhancing the branch instructions of the 65C02
processor. It consists of a number of utility macros that are normally
included in a source file with the following line of code:

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
means that it can only reach so far before you encounter the following dreaded
error:

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

Note: The native short branch instructions have the property that they are
position independent. This means they reach the same (relative) address no
matter if the code is relocated. The long branch version use the jump (jmp)
instruction "under the hood". This means that they are *not* position
relative. Usually this does not matter since the code is normally assembled
for the address where it will be run, but if code is copied from one region
of memory (like a ROM) to another region (like RAM), this could cause
some nasty problems.

**Composite Branches:**

Composite branches are used to make decisions about unsigned (u) and signed
(s) data. In general, these instructions are meant to be used after a subtract
(_sbc_) instruction or a compare (_cmp_, for unsigned data only) instruction
or the compare macro (cmp_16) from the assist_16 library. The short versions
are contained in "u_branches.i65" and "s_branches.i65" and the long versions
in "lu_branches.i65" and "ls_branches.i65". Exceptions are *beq* and *bne*
which are native instructions and lbeq and lbne  which are part of
"l_branches.i65".

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
5     | 1     | Always 1.
**6** | **V** | **The overflow bit.**
**7** | **N** | **The negative bit.**

Now a lot of instructions and even inputs to the CPU can have an affect on
these flag bits. However, we are interested in those instructions that can be
used to compare data. That is those instructions that perform subtraction.
These are the _sbc_ and _cmp_ instructions which are subtract with carry and
compare respectively.

### The Carry Flag:

Despite its many other uses, the carry flag is named after the task of keeping
track of the _carry_ between bytes in multi-byte addition. A _high_ (1) state
indicates that a carry has been generated by the addition. This is why, before
adding numbers, one usually uses the clc instruction since there is no
previous carry and the 6502 lacks an instruction to add without carry.

In spite of this, its use in subtraction is the exact opposite. In
subtraction, this flag is used to represent a _borrow_ condition. To make
things more interesting, a borrow exists when this flag is _low_ (0) state.
This is why, before subtracting numbers, one usually uses the sec instruction
to set the carry (and thus clear the borrow)  since there is no previous
borrow and again, the spartan 6502 processor lacks an instruction to subract
without borrow.

The _cmp_ instruction is special because it sets up the no borrow condition on
its own without the need for extra code. Further, since it does not change the
value of the A register, multiple values can be tested with ease. So _cmp_ is
better than _sbc_ right? Not always, keep reading.

The borrow bit is used with unsigned values. After a comparison instruction, a
borrow (which is carry clear) condition represents a less-than state while a
no borrow (which is carry set) represents a greater-than-or-equal-to state.


### The Zero Flag:

If the result of an operation is zero, this flag is set. If the result is not
zero, this flag is cleared. After a comparison operation, a zero result (Z set)
means the two values were equal. An non-zero result means that they were not
equal. This is reflected in the branch operations that use this flag, namely
_beq_ and _bne_ for branch if equal and branch if not-equal respectively.

Unlike the other flags described here, this holds true whether that data
involved are signed or unsigned.

### The Overflow Flag:

The Overflow (V) flag is one of the most confusing aspects of 65C02
programming but its role in comparison is really not all that complex.

The V flag, together with the N flag are used to compare signed data
quantities. So what does it mean? To keep things simple, when the V flag is
set, the N flag is flipped. That's all really. How this is used is covered
in the next section.

Branches on the V flag are simply _bvc_ to branch when it is 0 and _bvs_ to do
so when it is 1.

And now for some truly evil inconsistency. The _cmp_ instruction does not set
the V flag and so it cannot be used for signed comparisons. You must use the
_sbc_ instruction instead. On the bright side, the cmp_16 macro that is part
of the assist_16 folder of utilities sets _all_ of the required flags.

### The Negative Flag:

The The Negative (N) flag is used to signal that the result of an operation
are negative. Clearly this flag is used with signed data. Things get
interesting because the results of the subtraction may not be able to fit
in 8-bits. This is where the V flag augments the N flag to allow such cases
to still be handled.

Branches on the N flag are _bpl_ to branch when it is 0 and _bmi_ to do
so when it is 1.

The following table shows how the N and V bits are interpreted after a _cmp_
instruction:

N  | V | Meaning        | Interpretation
---|---|----------------|-----------------
0  | 0 | Positive       | A &ge; value
1  | 0 | Negative       | A < value
0  | 1 | False Positive | A < value
1  | 1 | False Negative | A &ge; value
