# Quirks of the 65C02 CPU

The enhanced CMOS version of the 6502. called the 65C02, makes several
improvements. And yet it still has a number of not-so endearing design quirks
that can make the life of a programmer more difficult than it needs to be. The
purpose of this section of the library is to provide a map to help avoid
nasty problems and land mines.

Topic                 | Description
----------------------|-------------------
[**Being Negative**](./negative.md) | The real story behind two's compliment arithmetic.
[**Playing Favorites**](./favorites.md) | The frustrating maze of instructions and addressing modes.
[**Memory Speed**](./memory.md) | Factors affecting the required memory speed.
Missing Instructions  | Stuff that got left out.
Flag that Instruction | When instruction don't play fair with flags.
Tricky Tools          | When features become traps.

## Missing Instructions

wip

## Flag that Instruction

The process status (P) register does not normally get a lot of attention. It
is normally affected as a side effect of instructions. Sometimes, instructions
affect the various status register bits of flags, in ways that can be
confusing or even confounding. Let's look at a few bad actors.

### Too much pull:

Some instructions are meant to be used together in pairs, almost like how
(parenthesis) are always supposed to be paired. The most iconic of these
are the push and pull instructions:

 Push |                     | Pull  |
------|---------------------|-------|---------------------------
_pha_ | Save A to the stack | _pla_ | Restore A from the stack
_php_ | Save P to the stack | _plp_ | Restore P from the stack
_phx_ | Save X to the stack | _plx_ | Restore X from the stack
_phy_ | Save Y to the stack | _ply_ | Restore Y from the stack

The push and the pull instructions neatly bracket code with the pull being
the exact undo of the push. Except it isn't. The pull instructions (except for
plp) have a dirty little secret. They also affect the N and Z flags.

This misstep causes problems as the very instructions meant to preserve
register values also corrupt a register. It can be a very rude surprise for
the unsuspecting, but now you know better.

### Comparisons are odious:

wip

## Tricky Tools

wip
