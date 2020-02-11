# Sample Virtual Machine Layouts (WIP)

## Contents

* [Overview](#overview)
* [1A Low Ram](#1a-low-ram)
   * [1B Low Ram plus Flash](#1b-low-ram-plus-flash)
   * [1C Low Ram plus Flash Emulation](#1c-low-ram-plus-flash-emulation)
   * [1D Low Ram plus Dynamic](#1d-low-ram-plus-dynamic)
* [2A Banked Ram](#2a-banked-ram)

## Overview

To review, this section will examine different VM layouts guided by the
following four questions:

1. Where in the system will the VM interpreter reside?
2. Where will the target program reside?
3. Where will the data, stack(s), and heap(s) reside?
4. How will I/O devices be supported?

## 1A Low Ram

This option is the simplest and the easiest to implement. It basically puts
everything into the 40K low ram region of memory. Here's what it looks like:

![Option 1A](../images/MM_Low_RAM.png)

Regions:

1. __'\*'__ - The lowest 2K of memory are reserved for the zero and stack
pages plus six pages for the use of the BASIC interpreter.
2. **VM Interpreter** - The W65C02S code that interprets VM code.
3. **VM Code** - The VM code to be interpreted. AKA the application code.
4. **Static Data** - Global and static data of the interpreter and the
application. Not included here are the system stack and zero page variables.
5. **Heap** - This optional region is used for dynamic memory allocation,
assuming your VM supports that feature.
6. **Stack** - The generalized VM stack, assuming your VM supports that
feature.
7. **IO** - The page reserved for IO devices.
8. In grey - Unused regions.
9. The "**kernal**" in flash. The system BIOS.

As can be seen, all of the application is in low RAM. With 40K there's enough
here to get quite a bit of work done. This option keeps things simple with all
addresses being simple 16 values that map directly to native addresses. No
complexity or overhead to get in the way.

While special I/O instructions can be added for space savings and performance,
they are not strictly required as the ability to address the entire system
allows regular memory addresses to be used to control devices.

On the down side, this option is cramped for space. It ignores the largest
region of RAM, the high banked area and the empty banks of flash memory. The
40K (oops, 38K) of low RAM will get used up in a hurry.

Still, this is a great option for starting out. I highly recommend it.

### 1B Low Ram plus Flash

A slight variation of the Low Ram model above makes use of the empty language
flash memory banks to hold the VM interpreter. This frees up space in Low Ram
but adds a few new wrinkles:

![Option 1B](../images/MM_Low_RAM_Flash.png)

Regions:

1. __'\*'__ - The lowest 2K of memory are reserved for the zero and stack
pages plus six pages for the use of the BASIC interpreter.
2. __'!'__ - The initial startup code that calls into the VM interpreter.
3. **VM Code** - The VM code to be interpreted. AKA the application code.
4. **Static Data** - Global and static data of the interpreter and the
application. Not included here are the system stack and zero page variables.
5. **Heap** - This optional region is used for dynamic memory allocation,
assuming your VM supports that feature.
6. **Stack** - The generalized VM stack, assuming your VM supports that
feature.
7. **IO** - The page reserved for IO devices.
8. In grey - Unused regions.
9. **VM Interpreter** - The W65C02S code that interprets VM code.
10. The "**kernal**" in flash. The system BIOS.

This layout preserves the advantages of the previous with simple, uniform
16-bit addresses with the added advantage of saving up to 8K of precious low
ram.

Complications here are the task of getting the required code into the required
bank of flash memory. Would the bank of flash be static or dynamic? In would
case we have to search through the banks looking for the correct one?
Currently all of this is solidly TBD.

Another potential problem is that the VM interpreter now needs to be less than
8K in length. This is probably not a problem but one can never be too certain
of that.

### 1C Low Ram plus Flash Emulation

On a variation of the variation, this Low Ram model puts the VM interpreter
into an unused bank of the High Ram. In effect, the High Ram is being used to
emulate what the flash would have done. The map is very similar:

![Option 1C](../images/MM_Low_RAM_Not_Flash.png)

Regions:

1. __'\*'__ - The lowest 2K of memory are reserved for the zero and stack
pages plus six pages for the use of the BASIC interpreter.
2. __'!'__ - The initial startup code that calls into the VM interpreter.
3. **VM Code** - The VM code to be interpreted. AKA the application code.
4. **Static Data** - Global and static data of the interpreter and the
application. Not included here are the system stack and zero page variables.
5. **Heap** - This optional region is used for dynamic memory allocation,
assuming your VM supports that feature.
6. **Stack** - The generalized VM stack, assuming your VM supports that
feature.
7. **IO** - The page reserved for IO devices.
8. **VM Interpreter** - The W65C02S code that interprets VM code, located in
a single bank of the High Ram.
9. In grey - Unused regions.
10. The "**kernal**" in flash. The system BIOS.

This layout also preserves the advantages of the simple, uniform
16-bit addresses and the added advantage of saving up to 8K of precious low
ram.

It also adds the require to explicitly load the VM interpreter into a bank.
This is less complex than loading it into flash, but would have to be done
every time the program was run. It would likely be part of the initial
startup code.

One potential downside is that if the file containing the VM interpreter
cannot be found, the program is unable to run and must exit with an error
message. Nobody likes error messages.

Plus, this option shares the 8K limit on the size of the VM interpreter.

### 1D Low Ram plus Dynamic

This option has a fancy name, but it really just a combination of options 1B
and 1C. Here, the startup code does a little more work. It first checks the
flash banks looking for the correct version of the VM interpreter. If it is
found, it uses that. If not found it loads the needed code into a ram bank and
uses that.

There's no map graphic to see here, they're above in sections 1B and 1C.

This approach allows for more flexible delivery of applications, but may
introduce a layer of complexity without much in the way of benefit.

## 2A Banked Ram

In this approach we mark a major departure by storing VM code in the High
Banked Ram, shown here:

![Option 2A](../images/MM_Banked_RAM.png)
