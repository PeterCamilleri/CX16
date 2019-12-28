# More Memory (WIP)

The Commander X 16 has as goals being faster (8MHz) with a bucket of memory
(up to 2088K). The W65C02S chip generates a 16 bit address. This allows the
addressing of 65,536 bytes, usable for RAM, ROM, Video, and various
Input/Output (I/O) devices. This is called 64K (for 64 x 1024). Now when the
original 6502 was released in 1975, 64K was a lot of memory. Today, it's
considered extremely small. This is the central issue behind the topic of
_more memory_.

How is this enormous gap to be bridged? Let's get back to basics. In a typical
system, the processor sends address information to memory which is used to
select the memory location being read from or written to. As mentioned
previously the W65C02S supplies 16 bits of address which allows for 64K. Thus,
for _more memory_ we will need _more address bits_. How do we obtain more
address bits? There are generally two schools of thought for doing this:

**Memory Address Translation**: In this model, addresses leaving the core
CPU go through a mapping function that maps (or translates) CPU addresses to
larger address. Historically there have been a number of ways this can be done:

The most common is to have a small memory that takes as its address a few
of the higher order address bits from the CPU and replaces them with more
bits. A typical example of this is the now obsolete 74LS610 chip that took
the upper 4 bits of CPU address and replaced them with 12 bits, thus
expanding the address bus from 16 to 24 bits and expanding addressable memory
from 64K to 16,384K or 16M.

Another approach from history is to integrate translation registers into the
CPU and add these registers to address with a shift. For example a shift of
four bits would result in addresses being added to a 20 bit value (16 plus
four zeros from the shift). This would allow up to 1,024K or 1M to be
accessed. This mapping method went by the name "segmentation", a name that
will live in ignominy. The CPU? Well the 8086 and its stripped down version
the 8088. No one would be dumb enough to use those chips for _anything_.

**Bank Switching**:


WIP


All programs generally use memory in two distinctive ways:

1. To hold the code of the program along with supporting libraries.
2. To hold the data of the program. This can include text, spreadsheet data,
game maps, game data, images, sounds, music, and much more.
