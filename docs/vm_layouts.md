# Sample Virtual Machine Layouts (WIP)

## Contents

* [Overview](#overview)
* [Low Ram](#low_ram)
   * [Low Ram plus Flash](#low_ram_plus_flash)

## Overview

To review, this section will examine different VM layouts guided by the
following four questions:

1. Where in the system will the VM interpreter reside?
2. Where will the target program reside?
3. Where will the data, stack(s), and heap(s) reside?
4. How will I/O devices be supported?

## Low Ram

This option is the simplest and the easiest to implement. It basically puts
everything into the 40K low ram region of memory. Here's what it looks like:

![Option 1](../images/MM_Low_RAM.png)

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

### Low Ram plus Flash

A slight variation of the Low Ram model above makes use of the empty language
flash memory banks to hold the VM interpreter. This frees up space in Low Ram
but adds a few new wrinkles:

![Option 2](../images/MM_Low_RAM_Flash.png)

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
bank of flash memory. Currently this is solidly TBD.
