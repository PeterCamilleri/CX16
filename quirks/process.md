# Chip Process: NMOS vs CMOS

A lot of the differences between the 6502 and the 65C02 come down to the
process used to create the chips. This document will take a simplified look
at how these design features make a dramatic impact on the resulting chips.

The original 6502 was an NMOS device with features sized at the 8 &mu;m with
an advertised die size of 3.9 mm &times; 4.3 mm, or an area of 16.6 mm&sup2;
The layout of the chip, its transistors, its interconnect wiring and its
internal registers were all drawn by hand on a huge six layered drawing.
Initially speeds were restricted to 1 MHz, but eventually, parts were
produced as fast as 4 MHz. All of these devices are designed to operate
with a 5 volt power supply.

The 65C02 is a CMOS device based on

[GDSII](https://en.wikipedia.org/wiki/GDSII)
Hard Cores and
[Verilog](https://en.wikipedia.org/wiki/Verilog)
RTL Soft Cores
