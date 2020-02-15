# The VM Instruction Pointer

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
   * [Low Ram Virtual Instruction Pointers](#low-ram-virtual-instruction-pointers)
      * [Low Ram Zero Page Data](#low-ram-zero-page-data)
      * [Low Ram 1](#low-ram-1)
         * [1 Saving Space](#1-saving-space)
         * [1 Jump](#1-jump)
      * [Low Ram Design Comparisons](#low-ram-design-comparisons)

## Introduction

The VM Instruction Pointer's job is point into memory. It gracefully sweeps
and hops its way through the the application's code, often branching and
looping and covering a lot of ground.

On a less poetic note, it needs to do very good job at:

* Sweeping through the entire address range of the code space.
* Stepping to the next address.
* Updating it's value for absolute jumps and subroutine returns.
* Adding signed values to it to implement relative branches

The W65C02S chip behind these virtual machines is not at all into doing
graceful memory sweeps. It likes to confine data to fixed locations. It does
have two index registers which can be used to expand things, but only to 256
bytes, no further. These puny, 8-bit registers have a severely limited reach.
There are indirect addressing modes with full 16-bit ranges. They are rather
slow and have no instructions that manipulate the address as a whole.
Everything has to be coded up explicitly, wasting both code space and
clock cycles.

Yet, in a virtual machine, this simple task is performed by one of the most
crucial bits of code. Its performance reflects on all instructions. Wasted
cycles here are wasted in everything the VM does.

On the other hand, if this were easy, would there be a whole section on it?
It is precisely these difficulties that make the task of programming the
VM instruction pointer all the more interesting. This is so true that there
is even a [**famous quote**](../README.md#famous-quote) about this.

So, we face challenging questions like:

* How fast can we make the code?
* How compact?
* Are there things we can trade off to improve the code?
* How do we deal with banked RAM? Assuming that's a thing we're doing.

Speaking of banked RAM, our study of the VM instruction pointer will be
divided into two sections, one for the VM application in low ram and the
other where it resides in banked, high ram. These correspond to options 1X
and 2X in the [**sample VM layouts**](./vm_layouts.md).

The second thing that must be considered is, what, exactly is being fetched?
Here almost all VM designs fall into one of two sub-camps. In these, VM
application code consists of one of the following:

* A series of byte codes or tokens. This is by far the most common and is
typically what one thinks of in most VM architectures. The instruction may
require some additional follow-on bytes. In this case we will be putting
our fetched byte code into the A register.
* A 16-bit address. This is most often seen with threaded languages like
FORTH. The instruction may also require additional some follow-on bytes or
16-bit words. In this case we will be putting our fetched 16-bit word into
a 16-bit working register located in the zero page.

There may be other options, but they are too obscure to be considered here.

[Back to the Top](#the-vm-instruction-pointer)

## Low Ram Virtual Instruction Pointers

This section will examine VM instruction pointers that use unmapped, 16-bit
addresses to access VM application code located (almost always) in the 40K
low ram memory space. Due to its simpler nature, this category of design has
the best opportunities for optimizing both bytes of code space and clock
cycles of time that are consumed.

[Back to the Top](#the-vm-instruction-pointer)

### Low Ram Zero Page Data

Let's start by looking at the data definitions that will be common to our
variations in the design:

    .zeropage
    vm_ip:    .res 2         ; The VM Instruction Pointer.
    vm_w:     .res 2         ; The VM Working address in threaded models.

The _vm\_w_ can be omitted in byte code designs but is shown here for
threaded options. Also, while the _vm\_ip_ must be located in the zero page,
the _vm\_w_ can be usually located in just about any data ram area in the
low ram. Nevertheless, ignore that and put it in the zero page anyway. If you
need this register, don't make it slow.

### Low Ram 1

We begin with the obvious design using indirect addressing. This approach is a
very common one seen in the Sweet-16 and other virtual machines. It uses a
16-bit zero page variable to point to any location in the 64K address space.

Let's see what it looks like fetching instructions and stepping to the next
unit. A slight benefit over classical code is that the W65C02S gives a mode
of indirect addressing that does not require the use of the Y register and
we take advantage of that here.

First the case is for byte codes with the op code being in the A register.

      lda     (vm_ip)        ; Grab the op code.
      inc     vm_ip          ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    :

This consumes 8 bytes and either 13 or 17 clocks, the latter being the case
of a page crossover. This gives a weighted average of 13.015625 clock cycles.
Let's just call that 13.

Second the case is for threaded code with the op address being stored in the
vm_w register.

      lda     (vm_ip)        ; Grab the low byte of the thread.
      sta     vm_w           ; Save it in vm_w low.
      inc     vm_ip          ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    : lda     (vm_ip)        ; Grab the high byte of the thread.
      sta     vm_w+1         ; Save it in vm_w high.
      inc     vm_ip          ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    :

This consumes 20 bytes and either 32 or 36 clocks, the latter being the case
of a page crossover (there can be only one). This gives a weighted average
of 32.03125 clock cycles. Let's just call that 32.

[Back to the Top](#the-vm-instruction-pointer)

#### 1 Saving Space

Now examining our code reveals that a lot of space is wasted getting a byte
and incrementing the _vm\_ip_. Since getting bytes from the instruction stream
will likely be needed in several places, perhaps we can do some factoring?

Here is one possible approach. First we create this pair of overlapped
subroutines:

    ldi_vm_ip:               ; Grab a byte and increment the vm_ip.
      lda     (vm_ip)        ; Grab the next byte.
    inc_vm_ip:               ; Just increment the vm_ip.
      inc     vm_ip          ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    : rts

Note the two entry points, the first loads and increments and the second just
increments. Then we rewrite our byte code instruction fetch as follows:

      jsr     ldi_vm_ip      ; Grab the next byte.

Our code now consumes only 3 bytes but a whopping 25 clocks. And our other
case for a threaded code fetch becomes:

      jsr     ldi_vm_ip      ; Grab the next byte.
      sta     vm_w           ; Save it in vm_w low.
      jsr     ldi_vm_ip      ; Grab the next byte.
      sta     vm_w+1         ; Save it in vm_w high.

The code size is now down to 10 bytes but with 56 clock cycles.

In some cases, the savings in space may be worth the slower execution. You
must make this trade-off decision. Perhaps for fetching instructions, which
happens on every instruction, the longer version could be used, while for
other parts of the VM interpreter, the more compact form could be preferred?

[Back to the Top](#the-vm-instruction-pointer)

#### 1 Jump

Now we look at the task of fetching a 16-bit jump address and setting the
_vm\_ip_ to this new value. For this code there is no difference between
the byte code and threaded code cases so only one routine is shown. The code
shown is the implementation of this hypothetical jump instruction.

      lda     (vm_ip)        ; Grab the low jump address.
      tax                    ; Hide it in X
      inc     vm_ip          ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    : lda     (vm_ip)        ; Grab the high jump address.
      stx     vm_ip          ; Update the vm_ip
      sta     vm_ip+1

This consumes 15 bytes and 24 clock cycles. This size reduced code assumes
the existence of the subroutines introduced above.

      jsr     ldi_vm_ip      ; Grab the low jump address.
      tax                    ; Hide it in X
      lda     (vm_ip)        ; Grab the high jump address.
      stx     vm_ip          ; Update the vm_ip
      sta     vm_ip+1

This consumes 10 bytes and 38 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

### Low Ram Design Comparisons

Tables are formatted in pairs of columns, the first being the topic and
listing the number of bytes used and the second being the number of clock
cycles needed to accomplish that task.

For Byte Codes     | Fetch  | Clocks |  Jump  | Clocks |
-------------------|:------:|:------:|:------:|:------:|
1                  |   8    |   13   |   15   |   24   |
1 Reduced          |   5    |   25   |   10   |   38   |

For Threaded Code  | Fetch  | Clocks |  Jump  | Clocks |
-------------------|:------:|:------:|:------:|:------:|
1                  |   20   |   32   |   15   |   24   |
1 Reduced          |   10   |   56   |   10   |   38   |

wip

[Back to the Top](#the-vm-instruction-pointer)
