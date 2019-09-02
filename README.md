# Developments Related to the Commander X 16 Project

This repository contains several developments/documents related to the
Commander X 16 (CX16) project. It is, however, in no way connected to that project.

The prime focus of this repository is the 65C02 processor being used in the
CX16. In particular:

* Documentation of the 65C02. There are lots of tutorials on the old 6502, but
little for the "C" variant. This needs some attention.
* Utility macros to round out some of the rough edges.
* Useful routines of a larger sort. Ideas include stack emulation, bank
management, heap management, and "drivers" for custom add on devices.
* The design of threaded interpreter languages (TIL) for the 65C02. While
normally associated with the FORTH language, TILs are a powerful technique that
may be used to implement almost any language. The Great Grand Daddy of this is
the Sweet-16 virtual machine written by Steve Wozniak and described in Byte
[November 1977](https://archive.org/details/byte-magazine-1977-11) magazine.

## Goals

The goals of this repository are two fold:

* To provide code/tools that may be of use to a potential CX16 programmer.
* As a tutorial/reference to useful methods and concepts of use to anyone
learning about programming.

One feature added to help with both goals will be to supply extensive "Notes"
that highlight crucial information and also the design decisions that were
needed to resolve conflicting requirements, limited resources, and the
side-effects of using the code.

Furthermore, in line with its instructional aspirations, this code will be
rather more commented than would be the case for contract production code.
Hopefully not to the extent of getting in the way, but instead adding useful
information about the commented code. This is our first example of a
trade-off: _More documentation_ vs. _Time spent & Obscuring the code._

I can speak from personal experience that it is possible to take documentation
so far that the code gets lost in the mess. To help avoid this, I will use
external documentation in the form of readme files in each section. This
should help to reduce the clutter.

## Tools

The initial work on the CX16 project will be done with the [cc65](https://cc65.github.io/)
tool chain. There are many reasons that I have made this my (initial) choice.
The assembler (a65) supports macros, the 65C02 (among others) and it comes with
a linker (ld65) breaks the tyranny of absolute object code. Besides it's
open-sourced and free!

The tool chain may change at some point. In any event I will may provide some
helpful (?) instructions on installing what ever tool chain I settle on, when
I settle on it.

Another, entirely optional, component of the toolset is the [Notepad++](https://notepad-plus-plus.org/)
editor. This program supports multi-tab edit with syntax highlighting. It also
allows effortless handling of the various line endings used in Windows, Linux,
Unix, and the Mac. It's also easy-to-use and free! You may prefer another
editor and that's OK. Go with what makes you happy.

### File Extensions

Initially, the following file extensions are used in this repository:

Extension | Use
----------|----------------------------------------------------
.a65      | Assembler Source File
.i65      | Assembler Include File
.md       | Documentation using GitHub markdown formatting.
others    | To be determined.

## Feedback

As always, your feedback is really appreciated. This repository may be found
[here](https://github.com/PeterCamilleri/CX16) If you want to show some
support, leave a star. If you want to ask a question, make a suggestion, or
raise and issue, use the "Issues" tab and make your point using a label such
as "bug", "documentation", "enhancement", "help wanted", or "question".

## Some (Optional) History

The CX16 is a project started by the 8-Bit Guy, David Murray. It was launched
with a YouTube [video](https://youtu.be/ayh0qebfD2g). This repository is to
contain my notes for development efforts that I feel to be complimentary to the
main project. In a modern (I'm old so I get to call it _modern_) twist, the
effort is also supported by a (closed) [Facebook](https://www.facebook.com/groups/CommanderX16/)
group with over 8,000 participants.

My first computer was an SD Systems Z-80 Starter Kit my father bought for me. I
had a lot of fun adding AMI 68047 video, a parallel ASCII keyboard, a 64K S-100
DRAM card, and even a MM57109 math chip. I wrote all the programs in Z-80 code,
painfully hand assembled.

I never got to own the original Commodore 64. In the beginning, I was poor and
could not afford to buy one. Later, I had a little money, but instead built a
CP/M machine around a Megatel Quark-100 based on the Z-80. I felt that it
would be more compatible with what I needed to do. Comparing Turbo Pascal to
BASIC, I think I made the right call for me.

Still later, but also long long ago, I did own two awesome CBM 8096 machines
but I foolishly gave them away along with my SD Systems Z-80 Starter Kit. I had
no way to store those machines and felt that others would benefit from them
more than I could. That is water under the bridge but the collector/hoarder in
me still cringes at the thought.

## The (Optional) CPU Soapbox

My relationship with the 65C02 chip and its choice as the processor in the CX16,
is to say the least, complicated. I will not make any bones about this. The
6502 and its offspring are not on my favorites list. I never really did much
programming with that chip. The wretched, tiny set of 8 bit registers, the
random zoo of addressing modes, the stunted system stack, and slew of bugs in
the silicon were more than enough for me to run away from it.

So you might think that I am critical of the choice of the 65C02 in this
project. I am not. The reasons for that are also complicated.

Let's start by looking at the 8-bit alternatives.

I used to use the old Z-80 an awful lot. I got to learn all of its features in
my own machine and several projects. I came to realize that most of what had
been added beyond the old 8080a was of little use in the "real" world. I was
saved by Turbo Pascal Version 3. I know well enough to know I would never want
to seriously program the Z-80 at the assembler level ever again.

My dream 8-bit processor has always been the Motorola 6809 (or the Hitachi
6309). It has the cleanest, best designed instruction set, an excellent
register set, exemplary addressing modes, and freedom from bugs. I also loved
the 3 part series that appeared in Byte magazine
([January 1979](https://archive.org/details/byte-magazine-1979-01),
[February 1979](https://archive.org/details/byte-magazine-1979-02), and
[March 1979](https://archive.org/details/byte-magazine-1979-03))
about the reasoning and design process in creating the new chip. In short, for
me the 6809 was perfect, and also not a candidate. The part is effectively
obsolete. Rochester Electronics still makes the part, but their prices are
completely insane. They clearly do not want to deal a small, low cost
development project. Further, the chip maxes out at a pokey 2 MHz. That may
have been OK at one time, but now it is downright glacial. Yes, you can run
really fast on a fast FPGA, but that is also rather costly. Sorry, dream chip,
no big comeback here.

I did as a lot of impressive work with the 8051. That chip is just not suited
to running as the processor of a personal computer. Its convoluted, byzantine
architecture is weird even in purely embedded applications.

I also did a lot of work with the 68HC11. I even wrote a 68HC11 assembler
(unreleased) in Delphi as part of an embedded systems IDE (never completed). I
also programmed it extensively on a professional level. Some of the products I
used this chip in sold millions of units and were a huge success. It was a
great chip. Was being the operative concept.

So how does the 65C02 accord itself? Well the list is long:

* Corrects the silicon bugs that made the original such a nightmare.
* Adds a few instructions to fill in some of the gaps.
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
