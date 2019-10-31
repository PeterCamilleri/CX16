# Quirks of the 65C02 CPU

The enhanced CMOS version of the 6502. called the 65C02, makes several
improvements. And yet it still has a number of not-so endearing design quirks
that can make the life of a programmer more difficult than it needs to be. The
purpose of this section of the library is to provide a map to help avoid
nasty problems and land mines.

Topic                 | Description
----------------------|-------------------
[Being Negative](./negative.md) | The real story behind two's compliment arithmetic.
Playing Favorites     | The frustrating maze of instructions and addressing modes.
Missing Instructions  | Stuff that got left out.
Flag that Instruction | When instruction don't play fair with flags.
Tricky Tools          | When features become traps.

## Playing Favorites

One of the legendary quirks of the 6502 processor is the maddening way that
addressing modes are available to the various instructions. In my own coding
I have had to jump through complex coding hoops when the instruction I need
to use is not available with the addressing mode I also need. I mean, what is
the point of all these complicated addressing modes when you can't count on
them when you need them?

## Missing Instructions

wip

## Flag that Instruction

wip

## Tricky Tools

wip
