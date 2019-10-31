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
I have had to jump through inefficient coding hoops when the instruction I
need to use is not available with the addressing mode I also need. I mean,
what is the point of all these complicated addressing modes when you can't
count on them when you need them?

To be clear, not all instructions are candidates for a lot of addressing
modes. Many instructions have specific inherent or internally defined data
that they deal with. In this discussion, we need to focus those instructions
that interact with data in memory. Secondly, some addressing modes are used
in specific domains and not applicable elsewhere.

However, even with these restriction, things are still a mess. Well the cause
of this chaos is the fact that the 6502 architecture has a three level system
of support for instructions and addressing modes:

Instruction/Mode          | Favored Modes  | Accepted Modes   | Fringe Modes
--------------------------|----------------|------------------|---------------
**Favored Instructions**  | Solid Support  | Get's these too  | Too extreme
**Accepted Instructions** | Get's these    | Nope             | Nope
**Fringe Instructions**   | Some?          | Some?            | Some?

## Missing Instructions

wip

## Flag that Instruction

wip

## Tricky Tools

wip
