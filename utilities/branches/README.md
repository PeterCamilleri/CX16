# Branches

The 6502 family comes with a spartan limited set of branch instructions for
most bits in the Processor Status Register (P). The 65C02 helps this a little
bit by adding in the unconditional branch alway or "bra" as well as a bunch of
branch on bit set or cleared for zero page  variables. There are still glaring
omissions. Other 8-bit microprocessors, notably the 6809, expand on this basic
set with several improvements:

**Long Branches** The standard branch instruction only has an 8-bit range. This
means that it can only reach so far before you encounter the following error:

    mysh>ca65 -l tools\too_far.lst tools\too_far.a65
    tools\too_far.a65(5): Error: Range error (128 not in [-128..127])

Long branches can be used to get around this problem. Too bad the 6502 doesn't
have any.

**Composite Unsigned Branches** Some conditions resulting from subtraction or
comparison of unsigned values require more that one status bit to be examined.
These conditions are "less than or equal" to (&le;) and "greater than" (>)
Instructions that test for these unsigned conditions are absent in the 6502.

**Composite Signed Branches** Most conditions resulting from subtraction or
comparison of signed values require more that one status bit to be examined.
These conditions are "less than" (<), "less than or equal" to (&le;),
"greater than or equal to" (&ge;), and "greater than" (>). Instructions that
test for these unsigned conditions are absent in the 6502.

**Long Composite Unsigned Branches** Long versions.

**Long Composite Signed Branches** Long versions.
