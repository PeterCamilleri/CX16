# Sweet-16

This file describes the port of the Sweet-16 covirtual machine to the W65C02S,
the ca65 assembler, and the Commander X 16 computer.

The Sweet-16 VM was part of the Apple \]\[ Integer Basic ROMs. Its primary
goal was to save code space, trading of speed for space. It achived this by
encoding instructions in 1, 2, or 3 bytes that often replaced native code
sequences of 6 to 12 (or more) bytes. And while the VM added an overhead of
about 300 bytes, if it was used often enough, it could have a net savings of
memory space.

Sweet-16 was first described in the May 1977 issue of Byte magazine with a
follow-up article in November going into much more detail as to how the code
worked. It was my first introduction to byte code interpreters and had a
profound influence on my thinking about computers, software design, and
layered architectures.

That is why I have chosen to port the Sweet-16 to the Commander X 16 computer.
I also felt the code was in desperate need of a face-lift and "modernization".
This reflects the fact that we no longer need to program in upper case only
and we now have a more current macro assembler (ca65) and linker (ld65).
We are also allowed to have blank lines and other nice things too. Further
we've replaced the old battered M6502 with a less dented W65C02S. I plan to
take full advantage of all of these over the course of time.

## References:

* The Apple-II, discusses the computer with a brief discussion of Sweet-16 in
[**May 1977 Byte**](https://archive.org/download/byte-magazine-1977-05/1977_05_BYTE_02-05_Interfacing.pdf).
* A follow on article with a much more in-depth look at the Sweet-16 was in
[**November 1977 Byte**](https://archive.org/download/byte-magazine-1977-11/1977_11_BYTE_02-11_Memory_Mapped_IO.pdf).
* The origin of the machine readable code, plus a great deal of useful
information about the Sweet-16 is found at 6502.org page
[**Porting Sweet 16**](http://www.6502.org/source/interpreters/sweet16.htm).
