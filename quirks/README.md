# Quirks of the 65C02 CPU

The enhanced CMOS version of the 6502. called the 65C02, makes several
improvements. And yet it still has a number of not-so endearing design quirks
that can make the life of a programmer more difficult than it needs to be. The
purpose of this section of the library is to provide a map to help avoid
nasty problems and land mines.

Topic                 | Description
----------------------|-------------------
Being Negative        | The real story behind two's compliment arithmetic.
Playing Favorites     | The frustrating maze of instructions and addressing modes.
Missing Instructions  | Stuff that got left out.
Flag that Instruction | When instruction don't play fair with flags.
Tricky Tools          | When features become traps.

## Being Negative

OK so this is a quirk _not_ specific to the 6502, but shared by almost every
computer system ever made. It's two's complement arithmetic and how negative
numbers and subtraction work.

Now, I learned way back in high school that computers perform subtraction by
adding. To do so they use the following bit of algebra:

    (1) A = B - C

    (2) A = B + (-C)

For example subtracting three is the same as adding negative three.

## Playing Favorites

wip

## Missing Instructions

wip

## Flag that Instruction

wip

## Tricky Tools

wip
