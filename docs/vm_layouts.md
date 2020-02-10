# Sample Virtual Machine Layouts (WIP)

## Contents

* [Overview](#overview)
* [Low Ram](#low_ram)

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

Notes:

__\*__ - The lowest 2K of memory are reserved for the zero and stack pages
plus six pages for the use of the BASIC interpreter.

As can be seen, everything is in low RAM. With 40K there's enough here
to get quite a bit of work done. This option keeps things simple with all
addresses being simple 16 values that map directly to native addresses. No
complexity or overhead to get in the way.

While special I/O instructions can be added for space savings and performance,
they are not strictly required as the ability to address the entire system
allows regular memory addresses to be used to control devices.

On the down side, this option is cramped for space. It ignores the largest
region of RAM, the high banked area and the empty banks of flash memory. The
40K (oops, 38K) of low RAM will get used up in a hurry.

Still, this is a great option for starting out. I highly recommend it.
