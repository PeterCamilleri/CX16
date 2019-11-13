# Memory Speed Requirements

The W65C02S requires external memory to be useful. Further it requires that
this memory supply data in a timely manner. This document examines the
requirements that memory must meet to be compatible with the CPU chip.

The following diagram illustrates a very simple system:

![A very simple system](./simplified_memory.png)

Now for our processor, the address consists of 16 address lines labeled A0
through A15. This 16 bit address can generate up to 65,536 unique addresses.
The command consists of a single line, R/W. When this line is low, a write
command is signified, when high, a read command is in progress. In this
design, the process supplies the address and the command and the memory
returns the data for a read, or accepts the data for a write,

Let's focus on read commands just for now.

This is a simplified version of the timing diagram that appears in the data-
sheet of the W65C02S.

![Read Timing](./read_timing.png)

As can be seen, four timing measurements are called out for examination.

