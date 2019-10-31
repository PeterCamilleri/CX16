# Playing Favorites

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

