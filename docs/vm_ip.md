# The VM Instruction Pointer

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
* [Low Ram Virtual Instruction Pointers (LRVIP)](#low-ram-virtual-instruction-pointers-lrvip)
   * [LRVIP Zero Page Data](#lrvip-zero-page-data)
   * [Option 1](#option-1)
      * [fetch](#option-1-fetch)
         * [Saving Space](#option-1-saving-space)
      * [jmp](#option-1-jmp)
      * [bra](#option-1-bra)
      * [jsr/rts](#option-1-jsrrts)
      * [enter/exit](#option-1-enterexit)
   * [Option 2](#option-2)
      * [fetch](#option-2-fetch)
      * [jmp](#option-2-jmp)
      * [bra](#option-2-bra)
      * [jsr/rts](#option-2-jsrrts)
      * [enter/exit](#option-2-enterexit)
      * [mark](#option-2-mark)
   * [Option 3](#option-3)
      * [fetch](#option-3-fetch)
         * [Saving Space](#option-3-saving-space)
      * [jmp](#option-3-jmp)
      * [bra](#option-3-bra)
      * [jsr/rts](#option-3-jsrrts)
      * [enter/exit](#option-3-enterexit)
* [High Ram Virtual Instruction Pointers (HRVIP)](#high-ram-virtual-instruction-pointers-hrvip)
* [Design Comparisons](#design-comparisons)

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

## Low Ram Virtual Instruction Pointers (LRVIP)

This section will examine VM instruction pointers that use unmapped, 16-bit
addresses to access VM application code located (almost always) in the 40K
low ram memory space. Due to its simpler nature, this category of design has
the best opportunities for optimizing both bytes of code space and clock
cycles of time that are consumed.

We shall approach this section by first summarizing the zero page data
utilized by the rest of the code and then examining three options:

1. A conventional 16 bit pointer characterized by the use of zero page
indirect addressing mode
2. An unorthodox 16 bit plus an 8 bit offset that restricts the code to
yield higher performance.
3. A hybrid of the first two options that tries to retain some of the
benefits of option 2 without its restrictions.

[Back to the Top](#the-vm-instruction-pointer)

### LRVIP Zero Page Data

Let's start by looking at the data definitions that will be common to our
variations in the design:

    .zeropage
    vm_ip:    .res 2         ; The VM Instruction Pointer.
    vm_w:     .res 2         ; The VM Working address in threaded models.
    vm_t      .res 2         ; VM Temporary Storage.

The _vm\_w_ can be omitted in byte code designs but is shown here for
threaded options. As noted in the code snippet above, it is expected that
all of these variables will be in the W65C02S zero page.

### Option 1

We begin with the obvious design using indirect addressing. This approach is a
very common one seen in the Sweet-16 and other virtual machines. It uses a
16-bit zero page variable to point to any location in the 64K address space.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 1 fetch

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

##### Option 1 Saving Space

Now examining our code reveals that a lot of space is wasted getting a byte
and incrementing the _vm\_ip_. Since getting bytes from the instruction stream
will likely be needed in several places, perhaps we can do some factoring?

Here is one possible approach. First we create this pair of overlapped
subroutines:

    lda_vm_ip:               ; Grab a byte and increment the vm_ip.
      lda     (vm_ip)        ; Grab the next byte.
    inc_vm_ip:               ; Just increment the vm_ip.
      inc     vm_ip          ; Step the vm_ip.
      beq     :+             ; See if page crossed.
      rts
    : inc     vm_ip+1        ; Cross to the next page.
      rts

Note the two entry points, the first loads and increments and the second just
increments. Then we rewrite our byte code instruction fetch as follows:

      jsr     lda_vm_ip      ; Grab the next byte.

Our code now consumes only 3 bytes but a whopping 24 clocks. And our other
case for a threaded code fetch becomes:

      jsr     lda_vm_ip      ; Grab the next byte.
      sta     vm_w           ; Save it in vm_w low.
      jsr     lda_vm_ip      ; Grab the next byte.
      sta     vm_w+1         ; Save it in vm_w high.

The code size is now down to 10 bytes but with 54 clock cycles.

In some cases, the savings in space may be worth the slower execution. You
must make this trade-off decision. Perhaps for fetching instructions, which
happens on every instruction, the longer version could be used, while for
other parts of the VM interpreter, the more compact form could be preferred?

[Back to the Top](#the-vm-instruction-pointer)

#### Option 1 jmp

Now we look at the task of fetching a 16-bit jump address and setting the
_vm\_ip_ to this new value. For this code, there is no difference between
the byte code and threaded code cases. Two cases are covered, one with an
in-line increment of the _vm\_ip_ and the other, size reduced by using a
subroutine to accomplish this task. The code shown is, in effect, the
implementation of this hypothetical jump instruction.

Here's the case with in-line increment:

      lda     (vm_ip)        ; Grab the low jump address.
      tax                    ; Hide it in X
      inc     vm_ip          ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    : lda     (vm_ip)        ; Grab the high jump address.
      stx     vm_ip          ; Update the vm_ip
      sta     vm_ip+1

This consumes 15 bytes and 26 clock cycles. This size reduced code assumes
the existence of the subroutines introduced above.

      jsr     lda_vm_ip      ; Grab the low jump address.
      tax                    ; Hide it in X
      lda     (vm_ip)        ; Grab the high jump address.
      stx     vm_ip          ; Update the vm_ip
      sta     vm_ip+1

This consumes 10 bytes and 37 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 1 bra

Now we look at the classic 8-bit relative branch. As before, there is no
difference between the byte code and threaded code cases. Two cases are
covered, one with an in-line increment of the _vm\_ip_ and the other, size
reduced by using a subroutine to accomplish this task. The code shown is,
in effect, the implementation of this hypothetical bra instruction.

Here's the case with in-line increment:

      ldx     #0
      lda     (vm_ip)        ; Grab the branch displacement.
      inc     vm_ip          ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    : and     #$FF           ; Retest the displacement.
      bpl     :+             ; Skip for positive displacements.
      dex                    ; Sign extend negative displacements.
    : clc                    ; vm_ip = vm_ip + displacement.
      adc     vm_ip
      sta     vm_ip
      txa
      adc     vm_ip+1
      sta     vm_ip+1

This consumes 24 bytes and an average of 36.5 clock cycles, assuming that
branch displacement values are evenly scattered. The version using the space
saving subroutine is:

      ldx     #0
      jsr     lda_vm_ip      ; Grab the branch displacement.
      and     #$FF           ; Retest the displacement.
      bpl     :+             ; Skip for positive displacements.
      dex                    ; Sign extend negative displacements.
    : clc                    ; vm_ip = vm_ip + displacement.
      adc     vm_ip
      sta     vm_ip
      txa
      adc     vm_ip+1
      sta     vm_ip+1

This consumes 19 bytes and 47.5 clock cycles. Clearly branches are more
complex and slower than jumps.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 1 jsr/rts

These next two scenarios are specific to byte code virtual machines. They are
the classical jump to and return from a subroutine. For these examples we
will assume the the CPU stack is being used to hold return addresses. First
_jsr_:

      lda     (vm_ip)        ; Grab the low byte of the target
      inc     vm_ip
      bne     :+
      inc     vm_ip+1
    : sta     vm_t           ; Save it
      lda     (vm_ip)        ; Grab the high byte of the target
      inc     vm_ip
      bne     :+
      inc     vm_ip+1
    : sta     vm_t+1         ; Save it
      lda     vm_ip+1        ; Get the high byte of the vm_ip
      pha                    ; Push it
      lda     vm_ip          ; Get the low byte of the vm_ip
      pha                    ; Push it
      lda     vm_t           ; Update the vm_ip low byte
      sta     vm_ip
      lda     vm_t+1         ; Update the vm_ip high byte
      sta     vm_ip+1

For 34 bytes and 56 clocks. And of course the size reduced version:

      jsr     lda_vm_ip      ; Grab the low byte of the target
      sta     vm_t           ; Save it
      jsr     lda_vm_ip      ; Grab the high byte of the target
      sta     vm_t+1         ; Save it
      lda     vm_ip+1        ; Get the high byte of the vm_ip
      pha                    ; Push it
      lda     vm_ip          ; Get the low byte of the vm_ip
      pha                    ; Push it
      lda     vm_t           ; Update the vm_ip low byte
      sta     vm_ip
      lda     vm_t+1         ; Update the vm_ip high byte
      sta     vm_ip+1

This consumes 24 bytes and consumes a whopping 78 clock cycles. Next, _rts_
is a lot less nasty:

      pla                    ; Get the low byte
      sta     vm_ip          ; Update vm_ip
      pla                    ; Get the high byte
      sta     vm_ip+1        ; Update vm_ip+1

This consumes only 6 bytes and 14 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 1 enter/exit

With threaded interpreters, things work a little differently. The enter
instruction continue execution of a nested thread. The exit reverses the
process. In practice, _jsr_ and _enter_ differ while _exit_ and _rts_ are
the same. In FORTH systems, _enter_ is often called _do_col_ and and _exit_
is called _do_semi_ to reflect there roles as the runtime implementations
of the ":" and ";" operators. This is enter:

      lda     vm_ip+1        ; Get the high byte of the vm_ip
      pha                    ; Push it
      lda     vm_ip          ; Get the low byte of the vm_ip
      pha                    ; Push it
      clc                    ; vm_ip = vm_w + 3
      lda     vm_w
      adc     #3
      sta     vm_ip
      lda     vm_w+1
      adc     #0
      sta     vm_ip+1

This consumes 19 bytes and 30 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

### Option 2

In my use of FORTH, I noticed that it was very rare for word definitions to
exceed even a dozen "words". This translates to less than 24 bytes per code
word. What if we took advantage of this fact and said the

    No code word can exceed 256 bytes in length.

How would this restriction benefit us? Well, we would only need an 8 bit
instruction pointer. So, in this scenario, a 16 bit pointer in the zero page
points to the base of the code, let's call it a proc, and the Y register
points to the current byte within that proc.

Let's see where this takes us:

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 fetch

Again we start with fetching instructions and stepping to the next unit. First
for byte codes:

      lda     (vm_ip),y      ; Grab the op code.
      iny                    ; Step the vm_ip.

An astonishing 3 bytes and only 7 clock cycles. Next examine the code in the
threaded case study:

      lda     (vm_ip),y      ; Grab the low byte of the thread.
      sta     vm_w           ; Save it in vm_w low.
      iny                    ; Step the vm_ip.
      lda     (vm_ip),y      ; Grab the high byte of the thread.
      sta     vm_w+1         ; Save it in vm_w high.
      iny                    ; Step the vm_ip.

A scant 10 bytes and 20 clocks.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 jmp

Now we look at the task of fetching a 16-bit jump address and setting the
_vm\_ip_ to this new value. As before, there is no difference between
the byte code and threaded code cases.

      lda     (vm_ip),y      ; Grab the low jump address.
      tax                    ; Hide it in X
      iny                    ; Step the vm_ip.
      lda     (vm_ip),y      ; Grab the high jump address.
      stx     vm_ip          ; Update the vm_ip
      sta     vm_ip+1
      ldy     #0             ; Zero out the offset.

This uses 12 bytes and 22 clock cycles

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 bra

For the case of the branch instruction, we change things up a bit. Rather than
the classical relative branch, we redefine _bra_ to be a jump withing the
current proc. Here's what we get:

      lda     (vm_ip),y      ; Grab the new offset.
      tay                    ; Go there!

Just 3 bytes and 7 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 jsr/rts

Next we revisit the classical jump to and return from a subroutine. Here
option 2 has an extra requirement. In addition to saving and restoring the
16 bit _vm\_ip_, we must also deal with the 8 bit offset in the Y register.

Again we will assume the the CPU stack is being used. First _jsr_:

      lda     vm_ip+1        ; Push the vm_ip base.
      pha
      lda     vm_ip
      pha

      lda     (vm_ip),y      ; Get the 16 bit target.
      iny
      tax
      lda     (vm_ip),y
      iny
      sta     vm_ip+1
      stx     vm_ip
      phy                    ; Push the offset.
      ldy     #0             ; Set the offset to 0.

This code consumes 20 bytes and 39 clocks. A significant improvement. On the
downside it uses 3 bytes of stack space instead of just two. Next is _rts_:

      ply                    ; Restore the offset
      pla                    ; Get the low byte
      sta     vm_ip          ; Update vm_ip
      pla                    ; Get the high byte
      sta     vm_ip+1        ; Update vm_ip+1

This consumes 7 bytes and 18 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 enter/exit

Now for threaded interpreters, we examine just _enter_ as _exit_ is still the
same as _rts_.

      lda     vm_ip+1        ; Get the high byte of the vm_ip
      pha                    ; Push it
      lda     vm_ip          ; Get the low byte of the vm_ip
      pha                    ; Push it
      phy                    ; Push the offset

      lda     vm_w           ; vm_ip = vm_w
      sta     vm_ip
      lda     vm_w+1
      sta     vm_ip+1
      ldy     #3             ; Offset is 3.

This consumes 17 bytes and 29 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 mark

An optional instruction for option 2 is mark. The purpose of this instruction
is to "re-align" the vm_ip base pointer so that code beyond 256 bytes may be
contained in a proc. The need for this instruction is debatable, but it is
presented here as an example of a conceptual extension to this option.

      tya                    ; Get the offset
      ldy     #0             ; Clear it.
      clc
      adc     vm_ip          ; vm_ip += Y
      sta     vm_ip
      tya
      adc     vm_ip+1
      sta     vm_ip+1

This action consumes 13 bytes and 20 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

### Option 3

Whereas option 1 was largely orthodox and option 2 took a more radical
approach, option 3 asks the question: Is it possible to merge these two camps
and retain the flexibility of option 1 while preserving some of the
performance gains of option 2? Let's see!

[Back to the Top](#the-vm-instruction-pointer)

#### Option 3 fetch

      lda     (vm_ip),y      ; Fetch the op code.
      iny                    ; Step to the next
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    :

This consumes 7 bytes and either 10 or 14 clocks, the latter being the case
of a page crossover. This gives a weighted average of 10.015625 clock cycles.
Let's just call that 10. Here's the code for the threaded case:

      lda     (vm_ip)        ; Grab the low byte of the thread.
      sta     vm_w           ; Save it in vm_w low.
      iny                    ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    : lda     (vm_ip)        ; Grab the high byte of the thread.
      sta     vm_w+1         ; Save it in vm_w high.
      iny                    ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    :

This consumes 18 bytes and either 26 or 30 clocks, the latter being the case
of a page crossover (there can be only one). This gives a weighted average
of 26.03125 clock cycles. Let's just call that 26.

[Back to the Top](#the-vm-instruction-pointer)

##### Option 3 Saving Space

Now examining our code again reveals that a lot of space is wasted getting a
byte and incrementing the _vm\_ip_. Since getting bytes from the instruction
stream will likely be needed in several places, perhaps we can do some
factoring?

Here is one possible approach. First we create this pair of overlapped
subroutines:

    lda_vm_ip:               ; Grab a byte and increment the vm_ip.
      lda     (vm_ip),y      ; Grab the next byte.
    inc_vm_ip:               ; Just increment the vm_ip.
      iny                    ; Step the vm_ip.
      beq     :+             ; Branch if page crossed.
      rts
    : inc     vm_ip+1        ; Cross to the next page.
      rts

Note the two entry points, the first loads and increments and the second just
increments. Then we rewrite our byte code instruction fetch as follows:

      jsr     lda_vm_ip      ; Grab the next byte.

Our code now consumes only 3 bytes but a whopping 22 clocks. And our other
case for a threaded code fetch becomes:

      jsr     lda_vm_ip      ; Grab the next byte.
      sta     vm_w           ; Save it in vm_w low.
      jsr     lda_vm_ip      ; Grab the next byte.
      sta     vm_w+1         ; Save it in vm_w high.

The code size is now down to 10 bytes but with 48 clock cycles.

In some cases, the savings in space may be worth the slower execution. You
must make this trade-off decision. Perhaps for fetching instructions, which
happens on every instruction, the longer version could be used, while for
other parts of the VM interpreter, the more compact form could be preferred?

[Back to the Top](#the-vm-instruction-pointer)

#### Option 3 jmp

Now we look at the task of fetching a 16-bit jump address and setting the
_vm\_ip_ to this new value. For this code, there is no difference between
the byte code and threaded code cases. Two cases are covered, one with an
in-line increment of the _vm\_ip_ and the other, size reduced by using a
subroutine to accomplish this task. The code shown is, in effect, the
implementation of this hypothetical jump instruction.

Here's the case with in-line increment:

      lda     (vm_ip),y      ; Grab the low jump address.
      tax                    ; Hide it in X
      iny                    ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    : lda     (vm_ip),y      ; Grab the high jump address.
      stx     vm_ip          ; Update the vm_ip
      sta     vm_ip+1

This consumes 14 bytes and 23 clock cycles. This size reduced code assumes
the existence of the subroutines introduced above.

      jsr     lda_vm_ip      ; Grab the low jump address.
      tax                    ; Hide it in X
      lda     (vm_ip)        ; Grab the high jump address.
      stx     vm_ip          ; Update the vm_ip
      sta     vm_ip+1

This consumes 10 bytes and 34 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 3 bra

Now we look at the classic 8-bit relative branch. As before, there is no
difference between the byte code and threaded code cases. Two cases are
covered, one with an in-line increment of the _vm\_ip_ and the other, size
reduced by using a subroutine to accomplish this task. The code shown is,
in effect, the implementation of this hypothetical bra instruction.

Here's the case with in-line increment:

      ldx     #0
      lda     (vm_ip),y      ; Grab the branch displacement.
      iny                    ; Step the vm_ip.
      bne     :+             ; Skip if no page cross.
      inc     vm_ip+1        ; Cross to the next page.
    : and     #$FF           ; Retest the displacement.
      bpl     :+             ; Skip for positive displacements.
      dex                    ; Sign extend negative displacements.
    : clc                    ; vm_ip = vm_ip + displacement.
      adc     vm_ip
      sta     vm_ip
      txa
      adc     vm_ip+1
      sta     vm_ip+1

This consumes 23 bytes and an average of 33.5 clock cycles, assuming that
branch displacement values are evenly scattered. The version using the space
saving subroutine is:

      ldx     #0
      jsr     lda_vm_ip      ; Grab the branch displacement.
      and     #$FF           ; Retest the displacement.
      bpl     :+             ; Skip for positive displacements.
      dex                    ; Sign extend negative displacements.
    : clc                    ; vm_ip = vm_ip + displacement.
      adc     vm_ip
      sta     vm_ip
      txa
      adc     vm_ip+1
      sta     vm_ip+1

This consumes 19 bytes and 44.5 clock cycles. Clearly branches are more
complex and slower than jumps.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 3 jsr/rts

These next two scenarios are specific to byte code virtual machines. They are
the classical jump to and return from a subroutine. For these examples we
will assume the the CPU stack is being used to hold return addresses. First
_jsr_:

      lda     (vm_ip),y      ; Grab the low byte of the target
      iny
      bne     :+
      inc     vm_ip+1
    : sta     vm_t           ; Save it
      lda     (vm_ip),y      ; Grab the high byte of the target
      iny
      bne     :+
      inc     vm_ip+1
    : sta     vm_t+1         ; Save it

      clc                    ; Fold Y into the vm_ip and save it
      tya
      ldy     #0             ; Clear the offset
      adc     vm_ip          ; Add the low byte of the vm_ip
      tax
      tya
      adc     vm_ip+1        ; Add the high byte of the vm_ip
      pha                    ; Push the high byte
      phx                    ; Push the low byte
      lda     vm_t           ; Update the vm_ip low byte
      sta     vm_ip
      lda     vm_t+1         ; Update the vm_ip high byte
      sta     vm_ip+1

For 38 bytes and 60 clocks. And of course the size reduced version:

      jsr     lda_vm_ip      ; Grab the low byte of the target
      sta     vm_t           ; Save it
      jsr     lda_vm_ip      ; Grab the high byte of the target
      sta     vm_t+1         ; Save it

      clc                    ; Fold Y into the vm_ip and save it
      tya
      ldy     #0             ; Clear the offset
      adc     vm_ip          ; Add the low byte of the vm_ip
      tax
      tya
      adc     vm_ip+1        ; Add the high byte of the vm_ip
      pha                    ; Push the high byte
      phx                    ; Push the low byte
      lda     vm_t           ; Update the vm_ip low byte
      sta     vm_ip
      lda     vm_t+1         ; Update the vm_ip high byte
      sta     vm_ip+1

This consumes 30 bytes and consumes a
whopping 82 clock cycles. Next, _rts_ is a lot less nasty:

      pla                    ; Get the low byte
      sta     vm_ip          ; Update vm_ip
      pla                    ; Get the high byte
      sta     vm_ip+1        ; Update vm_ip+1
      ldy     #0             ; Clear the offset

This consumes only 8 bytes and 16 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 3 enter/exit

We now consider option 3 for the threaded _enter_ instruction. Again _exit_
is the same as _rts_

      clc                    ; Push vm_ip + Y
      tya
      adc     vm_ip          ; Get the low byte of the vm_ip
      tay
      lda     #0
      adc     vm_ip+1        ; Get the high byte of the vm_ip
      pha                    ; Push the high byte.
      phy                    ; Push the low byte

      lda     vm_w           ; vm_ip = vm_w + 3
      sta     vm_ip
      lda     vm_w+1
      sta     vm_ip+1
      ldy     #3

This consumes 21 bytes and 34 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

## High Ram Virtual Instruction Pointers (HRVIP)

This section will examine VM instruction pointers that use mapped, addresses
to access VM application code located (almost always) in the banked high
ram memory space. Due to its more complex nature, this category of design will
sacrifice both bytes of code space and clock cycles of time that are consumed
for the ability to access more code.

One way that the added complexity manifests itself is there are now more than
one obvious way for addresses to by represented. The low ram case had only
one. This means that the number of cases to be studied is the product of the
number of address types and the number of implementation choices. That could
result in a lot of test cases to be examined. Clearly some sensible paring
down is required or this document will be huge!

As in the previous section we shall approach this section by first summarizing
the zero page data utilized by the rest of the code and then examining three
further options:

4. This option uses 8 banks of high memory to create a uniform 64K code space.
This continues to use simple 16 bit pointers with a little machinery in the
background
5. This option uses 24 bit pointers to access all of high memory for code
space. Pointers are now much more complex and bank boundaries are a thing.
6. This also uses 24 bit pointers combined with an 8 bit offset for speed.
This is option 2 on banked steroids.

At this time, only byte code based systems will be considered.

[Back to the Top](#the-vm-instruction-pointer)

## Design Comparisons

Tables are formatted by bytes/clocks for each option and test case.

Byte Codes   | fetch  |  jmp   |  bra   |   jsr  |   rts  |  mark  |
-------------|:------:|:------:|:------:|:------:|:------:|:------:|
Option 1     |  8/13  | 15/26  | 24/36.5| 34/56  |  6/14  |    -   |
Reduced Size |  3/24  | 10/36  | 19/47.5| 24/78  |   -    |    -   |
Option 2     |  3/7   | 12/22  |  3/7   | 20/39  |  7/18  |  13/20 |
Option 3     |  7/10  | 14/23  | 23/33.5| 38/60  |  8/16  |    -   |
Reduced Size |  3/21  | 10/33  | 19/44.5| 30/82  |    -   |    -   |
Option 4     |        |        |        |        |        |        |
Option 5     |        |        |        |        |        |        |
Option 6     |        |        |        |        |        |        |


Threaded     | fetch  |  jmp   |  bra   |  enter |  exit  |  mark  |
-------------|:------:|:------:|:------:|:------:|:------:|:------:|
Option 1     | 20/32  | 15/26  | 24/36.5| 19/30  |  6/14  |    -   |
Reduced Size | 10/54  | 10/36  | 19/47.5|   -    |    -   |    -   |
Option 2     | 10/20  | 12/22  |  3/7   | 17/29  |  7/18  |  13/20 |
Option 3     | 18/26  | 14/23  | 23/33.5| 21/34  |  8/16  |    -   |
Reduced Size | 10/48  | 10/34  | 19/44.5|   -    |    -   |    -   |

[Back to the Top](#the-vm-instruction-pointer)
