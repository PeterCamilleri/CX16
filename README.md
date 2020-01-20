# Developments Related to the Commander X 16 Project

This repository contains several developments/documents related to the
Commander X 16 (CX16) project.

Note: This repository is in in no way connected to the CX16 project. It's just
some stuff I thought might be useful and that should be written down. Further,
even though many companies, organizations, and web sites are mentioned within,
I have no connection to those either. I am  however, a member of the CX16
Facebook group where I make occasional posts and comments.

The prime focus of this repository is the W65C02S processor being used in the
CX16. In particular, it is hoped that this data will be useful to those that:

* Are new to the 6502 family, or assembly language programming.
* Are familiar with the MOS 6502 but not the improved W65C02S. There are lots
of tutorials on the old 6502, but little for the W65C02S variant. This needs
some attention.
* Are interested in creating new hardware for the CX16.
* Are interested in creating or porting development tools to the CX16.
* Are just curious about the CX16 and want to learn some deep dive details.

## Contents

* [Goals](#goals)
* [Sections](#sections)
* [Using this Repository](#using-this-repository)
   * [Library Files](#library-files)
* [Feedback](#feedback)
* [Some (Optional) History](#some-optional-history)
* [The (Optional) CPU Soapbox](#the-optional-cpu-soapbox)
* [License](#license)
* [Code of Conduct](#code-of-conduct)

## Goals

To serve the target groups, the goals of this repository are:

* To provide code/tools that may be of use to a potential CX16 programmer.
* As a tutorial/reference to useful methods and concepts of use to anyone
learning about programming.
* To provide an overview available tools and resources.

One feature added to help with these goals will be to supply extensive "Notes"
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

## Sections

The contents of this repository are divided into the following sections:

Section   | Description
----------|----------------------------------------------------
[**New**](./docs/new.md)| What's "new" in the W65C02S?
[**Quirks**](./docs/quirks.md)| A look at some of the "interesting" quirks of the W65C02S.
[**Memory**](./docs/memory.md) | Factors affecting the required memory speed.
[**More Memory**](./docs/more_memory.md) | Fitting 36 gallons into a 1 gallon bucket.
[**Tools**](./docs/tools.md)| A discussion of issues related to the tools used in this repository.
[**Testing**](./t65)| Unit tests for the code in this repository.
[**Assist_16**](./docs/assist_16.md)| Macros that assist in handling 16 bit values in W65C02S assembly language.
[**Branches**](./docs/branches.md)| Macros that enhance the W65C02S with long branches and branches on composite conditions.
[**Virtual Machines**](./docs/virtual_machines.md)| A study of virtual machine options.
wip | Work In Progress

## Using this Repository

In general, there are two approaches that can be taken to using the code in
this repository in one of your projects.

1. Use the repository folder as-is.

Through the use of include, object, and library paths it should be possible
to place the CX16 root folder someplace accessible, and access the needed
files.

* PRO: It will be easy to update to newer versions of CX16 by just updating
the contents of that one folder.
* PRO: The one folder can be shared by more than one user project.
* CON: Setting up all those paths takes effort.
* CON: It makes things more complex if different projects should happen to
require different CX16 versions. This situation should be avoided if at all
possible.

2. Copy the files needed.

The needed CX16 files can be copied into the user's project folder(s) in the
places where they are needed.

* PRO: The user only needs to setup paths for their project(s)
* PRO: Shorter paths may build a little quicker.
* CON: There may be a lot of files to copy and the dependencies of those
files may be troublesome.
* CON: When the CX16 is updated, all this copying may need to be done all over
again. Worse still, the update may be applied in an inconsistent manner
leading to applications created with mixed, untested code.

### Library Files

While most parts of the CX16 library do not directly generate object files,
some parts do. These are built by the build_all batch file and placed in two
library files in the "lib" folder. These are:

Library   | Description
----------|---------------
cx16.lib  | The standard version of the CX16 code for use in applications.
sim16.lib | The test version of the CX16 code for use with the sim65 tool.

## Feedback

As always, your feedback is really appreciated. This repository may be found
[here](https://github.com/PeterCamilleri/CX16) If you want to show some
support, leave a star. If you want to ask a question, make a suggestion, or
raise and issue, use the "Issues" tab and make your point using a label such
as __bug__, __comment__, __documentation__, __enhancement__, __help wanted__,
or __question__.

## Some (Optional) History

The CX16 is a project started by the
[**8-Bit Guy**](https://www.youtube.com/channel/UC8uT9cgJorJPWu7ITLGo9Ww),
David Murray. It was launched with a YouTube
[**video**](https://youtu.be/ayh0qebfD2g).
This repository is to
contain my notes for development efforts that I feel to be complimentary to the
main project. In a modern (I'm old so I get to call it _modern_) twist, the
effort is also supported by a (closed)
[**Facebook**](https://www.facebook.com/groups/CommanderX16/)
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

My relationship with the W65C02S chip and its choice as the processor in the
CX16, is to say the least, complicated. I will not make any bones about this.
The 6502 and its offspring are not on my favorites list. I never really did
much programming with that chip. The wretched, tiny set of 8 bit registers,
the random zoo of addressing modes, the stunted system stack, and slew of bugs
in the silicon were more than enough for me to run away from it.

So you might think that I am critical of the choice of the W65C02S in this
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
([**January 1979**](https://archive.org/details/byte-magazine-1979-01),
[**February 1979**](https://archive.org/details/byte-magazine-1979-02), and
[**March 1979**](https://archive.org/details/byte-magazine-1979-03))
about the reasoning and design process in creating the new chip. In short, for
me the 6809 was perfect, and also not a candidate. The part is effectively
obsolete. Rochester Electronics still makes the part, but their prices are
completely insane. They clearly do not want to deal a small, low cost
development project. Further, the chip maxes out at a pokey 2 MHz. That may
have been OK at one time, but now it is downright glacial. Yes, you can run
really fast on a fast FPGA, but that is also rather costly and not at all in
keeping with the neo-retro philosophy. Sorry, dream chip,
no big comeback here.

Still around is the venerable 8051. That chip is just not suited
to running as the processor of a personal computer. Its convoluted, byzantine
architecture is weird even in purely embedded applications.

I also did a lot of work with the 68HC11. I even wrote a 68HC11 assembler
(unreleased) in Delphi as part of an embedded systems IDE (never completed). I
programmed it extensively on a professional level. Some of the products I
used this chip in sold millions of units and were a huge success. It was a
great chip. Was being the operative concept.

So how does the W65C02S accord itself? Well the list is long:

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

Finally there is one last point in favor of the W65C02S. It may very well be
more important than all the stuff mentioned so far. I do not remember where
I first heard this concept, or who first expressed it, but I know it to be
true from the experiences in my own programming career and even my own life.
I phrase the concept something like this:

    Scarcity and restriction are the inspiration for creativity and ingenuity.

It is very true that all 8-bit processors exhibit some sort of scarcity and
most have serious restrictions. Maybe this is in fact one of their charms? I
am pretty sure that it is one of the major factors inspiring so many people to
devote so much effort to creating the Commander X 16.

Thank You All. This is truly **AWESOME!**

## License

The repository is available as open source under the terms of the
[**MIT License**](./LICENSE.txt).

## Code of Conduct

Everyone interacting in the CX16 repository’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the
[**code of conduct**](./CODE_OF_CONDUCT.md).
