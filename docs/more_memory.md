# More Memory

The Commander X 16 has as its goals being faster (8MHz) with a bucket of
memory (up to 2088K). Yet its design is based on the VIC-20 which was designed
to be slow (1MHz) with a pathetically small amount (5K) of memory. For example
Wikipedia says that "the amount of memory on the VIC-20's system board was
very small even for 1981 standards"

So how is this enormous gap to be bridged? Let's go back to basics. The 6502
family of chips (excluding the varieties hobbled to save packaging costs)
generates a 16 bit address. This allows the addressing of 65,536 bytes, usable
for RAM, ROM, Video, and various Input/Output (I/O) devices. This is called
64K (for 64 x 1024). Now when the 6502 was released in 1975, 64K was a lot
of memory. Today, it's considered extremely small. This is the central issue
behind the topic of more memory.

So what is to be done? To answer this, we need to ask the question, "What do
we need?" The obvious answer: "More memory" is not very helpful. More memory
for what? No things get interesting.

All programs generally use memory in two distinctive ways:

1. To hold the code of the program along with supporting libraries.
2. To hold the data of the program. This can include text, spreadsheet data,
game maps, images, sounds, music, and much more.

While this is not carved "in-stone"
