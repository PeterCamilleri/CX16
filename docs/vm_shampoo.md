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

|   fetch   |     decode     |  execute  | repeat  |
|:---------:|:--------------:|:---------:|:-------:|
|  1 (13)   | Acheron (11)   |  nop (2)  | jmp (3) |
|  1rs (24) | AcheronC (9)   |           |         |
|  2 (7)    | Decoder 8 (11) |           |         |
|  3 (10)   | Decoder 7L (11)|           |         |
|  3rs (21) | Decoder 7H (11)|           |         |
|  4 (13)   |                |           |         |
|  5 (13)   |                |           |         |
|  6 (7)    |                |           |         |

Now we can begin to understand what level of performance awaits us. Taking
the fastest fetch and decode choices we get a minimum execution time of
21 clock cycles (7+9+2+3). At the proposed speed for the Commander X 16 of
8MHz, this yields ‭380,952 virtual machine instructions per seconds. This
is the upper limit.

[Back to the Top](#vm-shampoo-summary)

## Threaded VM

wip

[Back to the Top](#vm-shampoo-summary)

wip

[Back to the Top](#vm-shampoo-summary)
