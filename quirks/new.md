# What's New in the 65C02?

![6502 vs 65C02](./vs.png)

The first question that arises is exactly what processor chips are we going to
compare? It turns out that there have been a lot of old-school NMOS 6502 chips
through the years as well as quite a few parts called 65C02. We can however
simplify things be specifying that we will look at the classic 6502 produced
by MOS TECH and the 65C02 made by WDC and planned for the Commander X 16
project. Other parts are not relevant to this study.

The comparison will be made on the basis of the hardware and software
differences between the chips with an emphasis on those factors that affect
the Commander X 16 project.

## Programming

### New Instructions

### New Addressing Modes

The 65C02 adds three entirely new addressing modes. Further, it enhances a
number of instructions by adding in addressing modes that were omitted in the
6502.

### Bug Fixes

## Hardware

### Compatibility

Here's a common myth: "The 65C02 is a fully pin compatible, drop-in replacement
for the 6502". Here's a look at some device pin-outs with differences
highlighted in bold:

![Pinouts](./pinout.png)

Myth BUSTED! Not only are four pins different between the two chips, at least
one pin is seriously incompatible. Note how pin 1 is a Vss (Ground) pin on
the 6502 and yet is a signal output (Vector Pull) of the 65C02. Grounding
this pin could result in damage to a 65C02 and not grounding it could result
in erratic operation in a 6502.

### Power Supply

### Voltage and Speed

![Voltage vs Speed](./speed.png)

### Clocking

