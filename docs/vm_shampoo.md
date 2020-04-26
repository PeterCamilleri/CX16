# VM Shampoo Summary

In this section, we are going to look at the options we've examined so
far and see how they fit into the virtual machine (VM) shampoo loop. If
you need a refresher on that loop, here is what has to happen for each
VM instruction executed:

<pre><code>fetch &rarr; decode &rarr; execute &rarr; repeat</code></pre>

Since they differ so much, we will further divide our summary into the byte
coded and threaded VM design philosophies.

Before we proceed, some areas of this summary bear further study.

1. Since the execute portion varies widely, depending on the task at hand,
we will be looking at a _nop_ instruction. This is to be an actual _nop_
and not an optimized instruction body containing no code. This will give
a more realistic upper limit on VM execution speed.
2. We've not paid any attention to the "repeat" part of the shampoo. The
reason for this is that it is so simple. In these studies we will use:

```
  jmp     vm_next        ; Execute the next VM instruction.
```

[Back to the Top](#vm-shampoo-summary)

## Byte Coded VM

|      fetch      |     decode     |  execute  | repeat  |
|:---------------:|:--------------:|:---------:|:-------:|
| Option 1 (13)   | Acheron (11)   |  nop (2)  | jmp (3) |
| Option 1rs (24) | AcheronC (9)   |           |         |
| Option 2 (7)    | Decoder 8 (11) |           |         |
| Option 3 (10)   | Decoder 7L (11)|           |         |
| Option 3rs (21) | Decoder 7H (11)|           |         |
| Option 4 (13)   |                |           |         |
| Option 5 (13)   |                |           |         |
| Option 6 (7)    |                |           |         |

Now we can begin to understand what level of performance awaits us. Taking
the fastest fetch and decode choices we get a minimum execution time of
21 clock cycles (7+9+2+3). At the proposed speed for the Commander X 16 of
8MHz, this yields ‭380,952 virtual machine instructions per second. This
is the upper limit.

Choosing the slowest options we get 40 clock cycles (24+11+2+3). This then
yields 200,000 virtual machine instructions per second. This is _not_ the
lower limit. Recall that the execute phase is a _nop_. Things can get much
slower when real work is to be done.

It is valuable to realize that this is still pretty quick by 8-bit standards.

[Back to the Top](#vm-shampoo-summary)

## Threaded VM

|      fetch      |     decode     |  execute  | repeat  |
|:---------------:|:--------------:|:---------:|:-------:|
| Option 1 (32)   | Indirect (29)  |  nop (2)  | jmp (3) |
| Option 1rs (54) | Direct (5)     |           |         |
| Option 2 (20)   |                |           |         |
| Option 3 (26)   |                |           |         |
| Option 3rs (48) |                |           |         |

Choosing the fastest options yields 30 clock cycles (20+5+2+3) and 266,666
virtual machine instructions per second. The slowest gets 88 clock cycles
(54+29+2+3) and 90,909 virtual machine instructions per second.

Threaded virtual machines are clearly slower, but are better for interactive
languages like FORTH. As such they bridge the gap between slow languages like
BASIC and compiled languages like "C" or low level languages like assembler.


[Back to the Top](#vm-shampoo-summary)

wip

[Back to the Top](#vm-shampoo-summary)
