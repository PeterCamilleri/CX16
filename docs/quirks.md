# Quirks of the W65C02S CPU

The enhanced W65C02S, makes several improvements. And yet, it still has a
number of not-so endearing design quirks that can make the life of a
programmer more difficult than it needs to be. The purpose of this section of
the library is to provide a map to help avoid nasty problems and land mines.

Topic                 | Description
----------------------|-------------------
[**Being Negative**](./negative.md) | The real story behind two's compliment arithmetic.
[**Playing Favorites**](./favorites.md) | The frustrating maze of instructions and addressing modes.
Flag that Instruction | When instruction don't play fair with flags.
Return Address        | Strange quirks in the return address pushed onto the stack.

## Contents

* [Flag that Instruction](#flag-that-instruction)
   * [Too much pull](#too-much-pull)
   * [Comparisons are odious](#comparisons-are-odious)
   * [The most useless pin](#the-most-useless-pin)
* [Return Address](#return-address)
   * [Subroutines](#subroutines)
   * [Interrupts](#interrupts)
   * [The _brk_ Instruction](#the-brk-instruction)

## Flag that Instruction

The process status (P) register does not normally get a lot of attention. It
is normally affected as a side effect of instructions. Sometimes, instructions
affect the various status register bits of flags, in ways that can be
confusing or even confounding. Let's look at a few bad actors.

### Too much pull

Some instructions are meant to be used together in pairs, almost like how
(parenthesis) are always supposed to be paired. The most iconic of these
are the push and pull instructions:

 Push | Description         | Pull  | Description
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

### Comparisons are odious

That's what what dad always told growing up. Of course, he was referring to
comparing people. In the W65C02S, comparisons are operators applied to scalar
quantities, like the values in the
A register of a CPU with some value in memory. The compare instruction has
exactly one job to do. It has to set the appropriate flags based on the
computation of the operation A - m. That's it. That's all it has to do.

It gets it wrong.

To compare unsigned quantities, the C and Z flags must be set. To compare
signed quantities the N, V, and Z flags must be set. The _cmp_ instruction
sets the N, C, and Z flags. It does not set the V flag making it useless
for comparing signed values.

Given that it already sets the other three flags, I can conceive of no
justification for this omission other than "It's a bug, but we can't fix it
now because we need to be compatible with the bugs too!"

Phooey! The _cmp_, _cpx_, and _cpy_ instructions should set all four flags:
N, V, C, and Z!

### The most useless pin

So far we have discussed instructions that mistreat status flags. This next
part discusses a hardware line that crosses the line.

The most useless pin on the W65C02S is the aptly names SOB line. Setting aside
some colorful expansions of that acronym we arrive at Set Overflow Bit. This
line sets the Overflow status bit when a negative transition occurs on pin 38.

The idea was to have the ability to rapidly poll an external status pin since
the status could be tested with a simple branch. In practice, this was never
done. Even the data sheet says that this line should not be used in new
designs. If this feature was really a requirement, it should have been
supported by an instruction like _bef_ for branch on external flag, rather
than mangling the overflow bit. Then I suspect, it would have gotten a lot
more positive attention.

Thus I call the SOB pin the most useless pin. It is less useful than even pins
designated as no connect as they are at least harmless. The SOB pin can cause
a lot of harm if not put down in its place. It should be tied to Vcc, and
relegated to a cautionary note in chip history.

## Return Address

Another area of quirky behavior relates to the all variants of the 6502. It is
the return address pushed onto the stack at various times. Normally return
addresses point to the next byte of code to be executed when code... returns.
Not so in this processor family. Sometimes the return address points to the
next byte, yes, but sometimes it points to the last byte of the previous
instruction. This can be very confusing, this should help:

### Subroutines

* The _jsr_ instruction enters a subroutine. It starts by saving the address
of the last byte of the _jsr_ on the stack, before updating the PC register.

* The _rts_ instruction exits a subroutine. It pops an address from the stack
and adds one to it before updating the PC register. Execution then begins at
the instruction following the _jsr_.

### Interrupts

* On an IRQ or NMI condition, or a _brk_ instruction, The address of the next
instruction to be executed is pushed onto the stack. Then the status register
is also pushed onto the stack. Finally, the interrupt address is loaded from
the appropriate address into the PC register.

* The _rti_ instruction returns from an interrupt. It restores the status
register and the PC from the stack. There is no modification made to the
restored PC value. Execution then begins at the instruction that was
interrupted.

### The _brk_ Instruction

The _brk_ instruction is a special case. Here are the official docs:

_Although BRK is a one-byte instruction, the program counter (which is pushed
onto the stack by the instruction) is incremented by two; this lets you follow
the break instruction with a one-byte signature byte indicating which break
caused the interrupt. Even if a signature byte is not needed, either the byte
following the BRK instruction must be padded with some value or the
break-handling routine must decrement the return address on the stack to let
an RTI (return from interrupt) instruction execute correctly._

Note that when assembled, the _brk_ instruction does not specify or even
allow for a signature value. None the less, one is normally required. Let's
see an actual code listing:

    000000r 1               ; A file to test various ideas.
    000000r 1
    000000r 1               .pc02  ; Use the 65C02 instruction set.
    000000r 1
    000000r 1               .code
    000000r 1
    000000r 1  A9 00          lda #$00
    000002r 1
    000002r 1                 ; Is brk a two byte instruction like the manual says?
    000002r 1  1A             inc   ; A == 1.
    000003r 1  00             brk
    000004r 1  1A             inc   ; Skipped "Signature" byte.
    000005r 1
    000005r 1  1A             inc   ; A == 2, not 3 as expected.
    000005r 1

This sort of weirdness, sorry quirkiness, is especially important to those
developing tools like debuggers or single steppers.
