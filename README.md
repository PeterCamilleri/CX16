# Development Related to the CommanderX16 Project

This repository contains several developments/documents related to the
Commander X 16 project. It is, however, in no way connected to that project.

My first computer was an SD Systems Z-80 Starter Kit my father bought for me. I
had a lot of fun adding AMI 68047 video, a parallel ASCII keyboard, a 64K S-100
DRAM card, and even a MM57109 math chip. I wrote all the programs in Z-80 code,
painfully hand assembled.

I never got to own the original Commodore 64. In the beginning, I was poor and
could not afford to buy one. Later, I had a little money, but instead built a
CP/M machine around a Megatel Quark-100 based on the Z-80. I felt that it
would have more compatible with what I needed to do. Comparing Turbo Pascal to
BASIC, I think I made the right call for me.

Still later, but also long long ago, I did own two awesome CBM 8096 machines
but I foolishly gave them away along with my SD Systems Z-80 Starter Kit. I had
no way to store those machines and felt that others would benefit from them
more than I could. That is water under the bridge.

The Commander X 16 is a project started by the 8-Bit Guy, David Murray. It was
launched with a YouTube [video](https://youtu.be/ayh0qebfD2g). This repository
is to contain my notes for development efforts that I feel to be complimentary
to the main project. In a modern twist, the effort is also supported by a
closed [Facebook](https://www.facebook.com/groups/CommanderX16/) group with
over 8,000 participants.

A prime focus of this repository is the 65C02 processor being used in the
Commander X 16 (CX16). In particular:

* Documentation of the 65C02. There are lots of tutorials on the old 6502, but
little for the "C" variant. This needs some attention.
* Utility macros to round out some of the rough edges.
* Useful routines of a larger sort. Ideas include stack emulation, bank
management, heap management, and "drivers" for custom add on devices.
* The design of threaded interpreter languages (TIL) for the 65C02. While
normally associated with the FORTH language, TILs are a powerful technique that
may be used to implement almost any language.

#### Soapbox

My relationship with the 65C02 chip and its choice as the processor in the CX16,
is to say the least, complicated. I will not make any bones about this. The
6502 and its offspring are not on my favorites list. I never really did much
programming with that chip. The wretched, tiny set of 8 bit registers, the
random zoo of addressing modes, the stunted system stack, and slew of bugs in
the silicon were more than enough for me to run away from it.

So you might think that I am critical of the choice of the 65C02 in this
project. I am not. The reasons for that are also complicated.

Let's start by looking at the 8-bit alternatives.

I used the Z-80 an awful lot. I got to learn all of its features in my own
machine and several projects. I came to realize that most of what had bed added
beyond the old 8080a was of little use in the "real" world. I knew it well
enough to never want to seriously program it ever again.

My dream processor has always been the 6809 (or the Hitachi 6309). It has the
cleanest, best designed instruction set, an excellent register set, exemplary
addressing modes, and freedom from bugs. I also loved the 3 part series that
appeared in Byte magazine about the  reasoning and design process in creating
the new chip. In short, for me the 6809 was perfect, and also not a candidate.
The part is effectively obsolete. Rochester Electronics makes the part, but
their prices are completely insane. They clearly do not want to deal a small,
low cost development project. Further, the chip maxes out at a pokey 2 MHZ.
That may have been OK at one time, but now it is downright glacial. Yes, you
can run really fast on a fast FPGA, but that is also rather costly. Sorry,
dream chip, no big comeback here.

I did as a lot of impressive work with the 8051. That chip is just not suited
to running as the processor of a personal computer. Its byzantine
architecture is weird even in purely embedded applications.

I also did a lot of work with the 68HC11. I even wrote a 68HC11 assembler
(unreleased) in Delphi as part of an embedded systems IDE (never
completed). It was a great chip. Was being the operative concept.

So how does the 65C02 accord itself? Well the list is long:

* Corrects the silicon bugs that made the original such a nightmare.
* Adds instructions to fill in some of the gaps.
* Applies addressing modes in a somewhat fairer plan.
* Adds branch on bit set/cleared instructions
* Adds a new addressing mode to avoid taking the Y register hostage.
* Operates up to pretty peppy 14MHz.

Now I realize that 14MHz is very difficult to get working and the project will
be targeting 8MHz, but this is still pretty quick. And the other improvements,
combined with the excellent support of the Western Design Center (WDC) make
this the winning candidate. Now don't get me wrong, measly 8 bit index
registers and a stunted stack still suck, but the pain level has been reduced
enough (I hope) to make this work.

On the other hand, using the 65C816 would be **SO** much **BETTER** !!!

