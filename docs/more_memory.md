# More Memory (WIP)

The Commander X 16 has as goals being faster (8MHz) with a bucket of memory
(up to 2088K). The W65C02S chip generates a 16 bit address. This allows the
addressing of 65,536 bytes, usable for RAM, ROM, Video, and various
Input/Output (I/O) devices. This is called 64K (for 64 x 1024). Now when the
original 6502 was released in 1975, 64K was a lot of memory. Today, it's
considered extremely small. This is the central issue behind the topic of
_more memory_.

How is this enormous gap to be bridged? Let's get back to basics.

All programs generally use memory in two distinctive ways:

1. To hold the code of the program along with supporting libraries.
2. To hold the data of the program. This can include text, spreadsheet data,
game maps, images, sounds, music, and much more.
