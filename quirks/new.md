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
the Commander X 16 project. For a closer look at the technologies used in
these devices, see a [deep dive](./process.md).

## Programming

### New Instructions

### New Addressing Modes

The 65C02 adds three entirely new addressing modes. Further, it enhances a
number of instructions by adding in addressing modes that were omitted in the
6502.

### Bug Fixes

#### Illegal Instructions

The 6502 defined 151 valid operational codes. This left 105 unused opcodes
which had undefined behavior. Some of these did interesting things and some
caused the process to stop working so badly that only a reset would restore
order. A watch-dog timer connected to the NMI line would not work.

In the W65C02S, many of these codes are now defined with new uses. Moreover,
the remaining undefined codes perform no-operation and are reserved for
future use. No processor hangs, no interesting mash-ups. Sometimes boring
_is_ better.


## Hardware

### Compatibility

Here's a common myth: "The 65C02 is a fully pin compatible, drop-in replacement
for the 6502". Here's a look at some device pin-outs with differences
highlighted in bold:

![Pinouts](./pinout.png)

Myth BUSTED! Not only are five pins different between the two chips, at least
one pin is seriously incompatible. Let's examine these in detail, sorted by
level of severity:

#### Pin 1

This is the serious case. Let's examine the scenario where a 65C02 is plugged
into a socket that was originally designed for a 6502.

On the 6502, pin 1 is a Vss or Ground pin. As such it would normally be
connected to the Ground line of the printed circuit board (PCB). Even in older
designs where the PCB had only two layers, the Ground line would normally be
a more robust connection to be able to handle a large amount of current. In
more modern designs with four (or more) layers, an entire layer, consisting of
essentially a full sheet of copper would be used for Ground. This Ground layer
(or Ground plane as it often called) can handle large current flows with
negligible resistance to that current flow.

On the 65C02, pin 1 is the Vector Pull line. The 65C02 data sheet says of this
line that:

_VPB is low during during the last interrupt sequence cycles, during which
time the processor reads the interrupt vector_

Now when Vector Pull is low there is no issue. A pin is driving low to a PCB
where it is hardwired low. When the pin tries to return to a high state is
another matter. A transistor in the chip attempts to raise the pin to a one
or high voltage state. The PCB is having none of that. It sinks all the
current it needs to to keep the pin low. As a result, a great deal of current
flows through the pin and the transistor connected to it. This can damage
the chip and cause it to stop working reliably. Bad news!

##### Fixes

* If the PCB does not ground pin 1, then there is no problem.
* Otherwise, you can bend out pin 1 so it does not connect with the socket.
* If you have soldered directly to the PCB, you can cut off pin 1 with a
pair of side-edge cutters.
* If you don't want to mangle your 65C02 you can mount it in a socket where
pin 1 has been removed and plug that socket into the PCB socket.

#### Pin 36

This one _may_ cause trouble. The data sheets are lacking in enough detail
to be certain.

In the 6502, pin 36 is a No Connect pin. It would be expected that a 6502
PCB would have no connection for this pin.

In the 65C02, pin 36 is the Bus Enable pin. When high, the address, data, and
control lines act normally. When low, those pins are disabled, allowing
another device to control those signals. The W65C02 data sheet clearly states
that unused input pins need to be connected to Vdd, the power pin.

##### Fixes

* Bodge a 10K&Omega; resistor directly to the chip between pins 36 and 8. This
will require some delicate soldering and will look ugly.
* Bodge a 10K&Omega; resistor to the underside of the PCB. This will hide the
resistor but you will have to deal with the mirror image problem and be
careful that you get the correct pins.

#### Pin 5

On the 6502, pin 5 is a No Connect pin. On the 65C02 it is a seldom used
output, Memory Lock.

So long as the 6502 PCB respects the No Connect, this one should be fine.

#### Pin 37

On the 6502, pin 37 is the &Phi;0 input pin. On the 65C02 it's the &Phi;2
input pin. While this sounds serious, in most cases, at the low speeds of
older 6502 PCBs, the difference should not matter. The later section on
clocking looks into more detail of changes that are needed at higher speeds.


#### Pin 2

On both the 6502 and the 65C02, pin 2 is used as the Ready line. It is most
often used as an input, usually held high because it is not being used. On
the 65C02 it can sometimes be used as an output. This occurs during execution
of the new Wait for an Interrupt (WAI) instruction. Another change made in
the C chip is that this pin no longer has an internal _pullup_. This means
that an older PCB may treat pin 2 as a no connect. In that case, we would
need to resort to a bodge resistor, like the one for pin 36, except between
pins 2 and 8.

#### References

Further information about using the W65C02S in older 6502 based systems can be
found [here](https://www.westerndesigncenter.com/wdc/AN-002_W65C02S_Replacements.cfm).

### Power Supply

### Voltage and Speed

![Voltage vs Speed](./speed.png)

### Current and Speed

![Current vs Speed](./CurrentvSpeed.png)


### Clocking

