# The VM Instruction Pointer

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
* [Low Ram Virtual Instruction Pointers](#low-ram-virtual-instruction-pointers-lrvip)
   * [Zero Page Data](#lrvip-zero-page-data)
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
* [High Ram Virtual Instruction Pointers](#high-ram-virtual-instruction-pointers-hrvip)
   * [Zero Page Data](#hrvip-zero-page-data)
   * [Option 4](#option-4)
      * [helper routines](#option-4-helper-routines)
      * [fetch](#option-4-fetch)
      * [jmp](#option-4-jmp)
      * [bra](#option-4-bra)
      * [jsr/rts](#option-4-jsrrts)
   * [Option 5](#option-5)
      * [fetch](#option-5-fetch)
      * [jmp far](#option-5-jmp-far)
      * [jmp near](#option-5-jmp-near)
      * [bra](#option-5-bra)
      * [jsr far](#option-5-jsr-far)
      * [jsr near](#option-5-jsr-near)
      * [rts far](#option-5-rts-far)
      * [rts near](#option-5-rts-near)
   * [Option 6](#option-6)
      * [fetch](#option-6-fetch)
      * [jmp far](#option-6-jmp-far)
      * [jmp near](#option-6-jmp-near)
      * [bra](#option-6-bra)
      * [jsr far](#option-6-jsr-far)
      * [jsr near](#option-6-jsr-near)
      * [rts far](#option-6-rts-far)
      * [rts near](#option-6-rts-near)
      * [mark](#option-6-mark)
* [Design Comparisons](#design-comparisons)
* [Macro Abstraction](#macro-abstraction)

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

In total, six options are examined here. This is a small subset of the total
number of available options but should be illustrative of many of the key
ideas. The reader is free to explore other ideas that may be more suited to
their application's requirements as an extended exercise.

For each option, the basic job of fetching instructions is considered plus
a study is made of those operations that directly affect the instruction
pointer. Operations like jump, branch, call a subroutine, return from a
subroutine, etc. This list while ponderous may not cover all requirements
for any given application.

Finally, this code is untested. While every effort has been made to check it
for correctness, there is no assurance that it is free from potentially
serious defects, poor performance, or other issues. Use at your own risk.

One last thing, the byte and cycle counts presented here were all derived by
my unsteady hand and are thus especially error prone, despite, or perhaps
because of, my best efforts.

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

```
.zeropage
vm_ip:    .res 2         ; The VM Instruction Pointer.
vm_w:     .res 2         ; The VM Working address in threaded models.
vm_t      .res 2         ; VM Temporary Storage.
```

The _vm\_w_ can be omitted in byte code designs but is shown here for
threaded options. As noted in the code snippet above, it is expected that
all of these variables will be in the W65C02S zero page.

### Option 1

We begin with the obvious design using indirect addressing. This approach is a
very common one seen in the Sweet-16 and other virtual machines. It uses a
16-bit zero page variable to point to any location in the 64K address space.

This option is very simple as is illustrated here:

![Option 1](../images/option1.png)

Where:
* __A0...A15__ is a simple 16 bit instruction byte address.


[Back to the Top](#the-vm-instruction-pointer)

#### Option 1 fetch

Let's see what it looks like fetching instructions and stepping to the next
unit. A slight benefit over classical code is that the W65C02S gives a mode
of indirect addressing that does not require the use of the Y register and
we take advantage of that here.

First the case is for byte codes with the op code being in the A register.

```
  lda     (vm_ip)        ; Grab the op code.
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
:
```

This consumes 8 bytes and either 13 or 17 clocks, the latter being the case
of a page crossover. This gives a weighted average of 13.015625 clock cycles.
Let's just call that 13.

Second the case is for threaded code with the op address being stored in the
vm_w register.

```
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
```

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

```
lda_vm_ip:               ; Grab a byte and increment the vm_ip.
  lda     (vm_ip)        ; Grab the next byte.
inc_vm_ip:               ; Just increment the vm_ip.
  inc     vm_ip          ; Step the vm_ip.
  beq     :+             ; See if page crossed.
  rts
: inc     vm_ip+1        ; Cross to the next page.
  rts
```

Note the two entry points, the first loads and increments and the second just
increments. Then we rewrite our byte code instruction fetch as follows:

```
  jsr     lda_vm_ip      ; Grab the next byte.
```

Our code now consumes only 3 bytes but a whopping 24 clocks. And our other
case for a threaded code fetch becomes:

```
  jsr     lda_vm_ip      ; Grab the next byte.
  sta     vm_w           ; Save it in vm_w low.
  jsr     lda_vm_ip      ; Grab the next byte.
  sta     vm_w+1         ; Save it in vm_w high.
```

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

```
  lda     (vm_ip)        ; Grab the low jump address.
  tax                    ; Hide it in X
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
: lda     (vm_ip)        ; Grab the high jump address.
  stx     vm_ip          ; Update the vm_ip
  sta     vm_ip+1
```

This consumes 15 bytes and 26 clock cycles. This size reduced code assumes
the existence of the subroutines introduced above.

```
  jsr     lda_vm_ip      ; Grab the low jump address.
  tax                    ; Hide it in X
  lda     (vm_ip)        ; Grab the high jump address.
  stx     vm_ip          ; Update the vm_ip
  sta     vm_ip+1
```

This consumes 10 bytes and 37 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 1 bra

Now we look at the classic 8-bit relative branch. As before, there is no
difference between the byte code and threaded code cases. Two cases are
covered, one with an in-line increment of the _vm\_ip_ and the other, size
reduced by using a subroutine to accomplish this task. The code shown is,
in effect, the implementation of this hypothetical bra instruction.

Here's the case with in-line increment:

```
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
```

This consumes 24 bytes and an average of 36.5 clock cycles, assuming that
branch displacement values are evenly scattered. The version using the space
saving subroutine is:

```
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
```

This consumes 19 bytes and 47.5 clock cycles. Clearly branches are more
complex and slower than jumps.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 1 jsr/rts

These next two scenarios are specific to byte code virtual machines. They are
the classical jump to and return from a subroutine. For these examples we
will assume the the CPU stack is being used to hold return addresses. First
_jsr_:

```
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
```

For 34 bytes and 56 clocks. And of course the size reduced version:

```
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
```

This consumes 24 bytes and consumes a whopping 78 clock cycles. Next, _rts_
is a lot less nasty:

```
  pla                    ; Get the low byte
  sta     vm_ip          ; Update vm_ip
  pla                    ; Get the high byte
  sta     vm_ip+1        ; Update vm_ip+1
```

This consumes only 6 bytes and 14 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 1 enter/exit

With threaded interpreters, things work a little differently. The enter
instruction continue execution of a nested thread. The exit reverses the
process. In practice, _jsr_ and _enter_ differ while _exit_ and _rts_ are
the same. In FORTH systems, _enter_ is often called _do_col_ and and _exit_
is called _do_semi_ to reflect there roles as the runtime implementations
of the ":" and ";" operators. This is enter:

```
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
```

This consumes 19 bytes and 30 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

### Option 2

In my use of FORTH, I noticed that it was very rare for word definitions to
exceed even a dozen "words". This translates to less than 24 bytes per code
word. What if we took advantage of this fact and said that:

    No code word can exceed 256 bytes in length.

How would this restriction benefit us? Well, we would only need an 8 bit
instruction pointer. So, in this scenario, a 16 bit pointer in the zero page
points to the base of the code, let's call it a proc, and the Y register
points to the current byte within that proc.

Let's see where this takes us:

![Option 2](../images/option2.png)

Where:
* __A0...A15__ is a simple 16 bit current procedure starting address.
* __P0...P7__ is the 8 bit offset into the current procedure.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 fetch

Again we start with fetching instructions and stepping to the next unit. First
for byte codes:

```
  lda     (vm_ip),y      ; Grab the op code.
  iny                    ; Step the vm_ip.
```

An astonishing 3 bytes and only 7 clock cycles. Next examine the code in the
threaded case study:

```
  lda     (vm_ip),y      ; Grab the low byte of the thread.
  sta     vm_w           ; Save it in vm_w low.
  iny                    ; Step the vm_ip.
  lda     (vm_ip),y      ; Grab the high byte of the thread.
  sta     vm_w+1         ; Save it in vm_w high.
  iny                    ; Step the vm_ip.
```

A scant 10 bytes and 20 clocks.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 jmp

Now we look at the task of fetching a 16-bit jump address and setting the
_vm\_ip_ to this new value. As before, there is no difference between
the byte code and threaded code cases.

```
  lda     (vm_ip),y      ; Grab the low jump address.
  tax                    ; Hide it in X
  iny                    ; Step the vm_ip.
  lda     (vm_ip),y      ; Grab the high jump address.
  stx     vm_ip          ; Update the vm_ip
  sta     vm_ip+1
  ldy     #0             ; Zero out the offset.
```

This uses 12 bytes and 22 clock cycles

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 bra

For the case of the branch instruction, we change things up a bit. Rather than
the classical relative branch, we redefine _bra_ to be a jump withing the
current proc. Here's what we get:

```
  lda     (vm_ip),y      ; Grab the new offset.
  tay                    ; Go there!
```

Just 3 bytes and 7 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 jsr/rts

Next we revisit the classical jump to and return from a subroutine. Here
option 2 has an extra requirement. In addition to saving and restoring the
16 bit _vm\_ip_, we must also deal with the 8 bit offset in the Y register.

Again we will assume the the CPU stack is being used. First _jsr_:

```
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
```

This code consumes 20 bytes and 39 clocks. A significant improvement. On the
downside it uses 3 bytes of stack space instead of just two. Next is _rts_:

```
  ply                    ; Restore the offset
  pla                    ; Get the low byte
  sta     vm_ip          ; Update vm_ip
  pla                    ; Get the high byte
  sta     vm_ip+1        ; Update vm_ip+1
```

This consumes 7 bytes and 18 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 enter/exit

Now for threaded interpreters, we examine just _enter_ as _exit_ is still the
same as _rts_.

```
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
```

This consumes 17 bytes and 29 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 2 mark

An optional instruction for option 2 is mark. The purpose of this instruction
is to "re-align" the vm_ip base pointer so that code beyond 256 bytes may be
contained in a proc. The need for this instruction is debatable, but it is
presented here as an example of a conceptual extension to this option.

```
  tya                    ; Get the offset
  ldy     #0             ; Clear it.
  clc
  adc     vm_ip          ; vm_ip += Y
  sta     vm_ip
  tya
  adc     vm_ip+1
  sta     vm_ip+1
```

This action consumes 13 bytes and 20 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

### Option 3

Whereas option 1 was largely orthodox and option 2 took a more radical
approach, option 3 asks the question: Is it possible to merge these two camps
and retain the flexibility of option 1 while preserving some of the
performance gains of option 2?

Let's see this approach:

![Option 3](../images/option3.png)

Where:
* __A0...A15__ is a simple 16 bit partial byte address.
* __A'0...A'7__ is the 8 bit address increment.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 3 fetch

```
  lda     (vm_ip),y      ; Fetch the op code.
  iny                    ; Step to the next
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
:
```

This consumes 7 bytes and either 10 or 14 clocks, the latter being the case
of a page crossover. This gives a weighted average of 10.015625 clock cycles.
Let's just call that 10. Here's the code for the threaded case:

```
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
```

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

```
lda_vm_ip:               ; Grab a byte and increment the vm_ip.
  lda     (vm_ip),y      ; Grab the next byte.
inc_vm_ip:               ; Just increment the vm_ip.
  iny                    ; Step the vm_ip.
  beq     :+             ; Branch if page crossed.
  rts
: inc     vm_ip+1        ; Cross to the next page.
  rts
```

Note the two entry points, the first loads and increments and the second just
increments. Then we rewrite our byte code instruction fetch as follows:

```
  jsr     lda_vm_ip      ; Grab the next byte.
```

Our code now consumes only 3 bytes but a whopping 22 clocks. And our other
case for a threaded code fetch becomes:

```
  jsr     lda_vm_ip      ; Grab the next byte.
  sta     vm_w           ; Save it in vm_w low.
  jsr     lda_vm_ip      ; Grab the next byte.
  sta     vm_w+1         ; Save it in vm_w high.
```

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

```
  lda     (vm_ip),y      ; Grab the low jump address.
  tax                    ; Hide it in X
  iny                    ; Step the vm_ip.
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
: lda     (vm_ip),y      ; Grab the high jump address.
  stx     vm_ip          ; Update the vm_ip
  sta     vm_ip+1
```

This consumes 14 bytes and 23 clock cycles. This size reduced code assumes
the existence of the subroutines introduced above.

```
  jsr     lda_vm_ip      ; Grab the low jump address.
  tax                    ; Hide it in X
  lda     (vm_ip)        ; Grab the high jump address.
  stx     vm_ip          ; Update the vm_ip
  sta     vm_ip+1
```

This consumes 10 bytes and 34 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 3 bra

Now we look at the classic 8-bit relative branch. As before, there is no
difference between the byte code and threaded code cases. Two cases are
covered, one with an in-line increment of the _vm\_ip_ and the other, size
reduced by using a subroutine to accomplish this task. The code shown is,
in effect, the implementation of this hypothetical bra instruction.

Here's the case with in-line increment:

```
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
```

This consumes 23 bytes and an average of 33.5 clock cycles, assuming that
branch displacement values are evenly scattered. The version using the space
saving subroutine is:

```
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
```

This consumes 19 bytes and 44.5 clock cycles. Clearly branches are more
complex and slower than jumps.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 3 jsr/rts

These next two scenarios are specific to byte code virtual machines. They are
the classical jump to and return from a subroutine. For these examples we
will assume the the CPU stack is being used to hold return addresses. First
_jsr_:

```
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
```

For 38 bytes and 60 clocks. And of course the size reduced version:

```
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
```

This consumes 30 bytes and consumes a
whopping 82 clock cycles. Next, _rts_ is a lot less nasty:

```
  pla                    ; Get the low byte
  sta     vm_ip          ; Update vm_ip
  pla                    ; Get the high byte
  sta     vm_ip+1        ; Update vm_ip+1
  ldy     #0             ; Clear the offset
```

This consumes only 8 bytes and 16 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 3 enter/exit

We now consider option 3 for the threaded _enter_ instruction. Again _exit_
is the same as _rts_

```
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
```

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

### HRVIP Zero Page Data

Let's start by looking at the data definitions that will be common to our
variations in the design:

```
.zeropage
vm_ip:    .res 3         ; The VM Instruction Pointer.
vm_t      .res 3         ; VM Temporary Storage.
vm_base   .res 1         ; The starting bank of the program.
```

As noted in the code snippet above, it is expected that all of these
variables will be in the W65C02S zero page. Also, the location _d1pra_ in
the I/O region is the register that controls high RAM bank selection.

[Back to the Top](#the-vm-instruction-pointer)

### Option 4

This instruction pointer design creates a uniform 64K space for virtual machine
code. It has no restrictions or nasty boundary issues. Since it uses only 8
banks of memory, any Commander X 16 will have enough to go around. Since this
code is more complex and thus a great deal more lengthy, we will only examine
a space reduced version of the code.

This option is outwardly very simple as is illustrated here:

![Option 4](../images/option4.png)

Where:
* __VA0...VA15__ is a 16 bit virtual instruction byte address.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 4 helper routines

To save space, this option uses a number of helper subroutines. These are
presented here:

We start with two overlapping subroutines.

* _lda\_vm\_ip_ fetches the next byte of code and increments the _vm\_ip_.
* _inc\_vm\_ip_ just increments the _vm\_ip_.

```
lda_vm_ip:               ; Grab a byte and increment the vm_ip.
  lda     (vm_ip)        ; Grab the next byte.
inc_vm_ip:               ; Just increment the vm_ip.
  inc     vm_ip          ; Step the vm_ip.
  beq     vm_step_page   ; See if page crossed.
  rts

vm_step_page:            ; Step to the next page.
  inc     vm_ip+1        ; Update the high address byte.
  inc     vm_ip+2        ; Update the shadow too.
  bbr5    vm_ip+1,vm_step_bank ; See if we crossed a bank boundary.
  rts

vm_step_bank:            ; Step to the next bank.
  pha                    ; Save A
  lda     #$A0           ; Reset to the start of a new bank.
  sta     vm_ip+1
  lda     vm_ip+2        ; Step to the next ram bank.
  lsr                    ; Isolate the bank number.
  lsr
  lsr
  lsr
  lsr
  clc                    ; Add in the base value.
  adc     vm_base
  sta     d1pra          ; Switch in the desired ram bank.
  pla                    ; Restore A
  rts
```
Including the overhead of a _jsr_, these routines consume an average of
22 and 17 for _lda\_vm\_ip_ and _inc\_vm\_ip_ respectively.

The second helper routine, _vm\_update_ takes a parameter in the A register
that contains the upper eight bits of a program address and updates the
appropriate registers to reflect that value.

```
vm_update:
  cmp     vm_ip+2        ; See if the value is changing.
  beq     :+
  sta     vm_ip+2        ; Update the shadow register
  and     #$1F
  ora     #$A0
  sta     vm_ip+1        ; Update the base address page.
  lda     vm_ip+2        ; Select the correct high ram bank.
  lsr                    ; Isolate the bank number.
  lsr
  lsr
  lsr
  lsr
  clc                    ; Add in the base value.
  adc     vm_base
  sta     d1pra          ; Switch in the desired ram bank.
: rts
```

Including the overhead of a _jsr_, this routine consumes 18 or 51
clock cycles, depending if the page is constant or being changed .

[Back to the Top](#the-vm-instruction-pointer)

#### Option 4 fetch

With the help of the above subroutines, our actual fetch code is simply:

```
  lda     (vm_ip)        ; Grab the next byte.
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; See if page crossed.
  jsr     vm_step_page   ; Do the job of stepping to the next page.
:
```

This code consumes just 9 bytes and 13 clock cycles on average.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 4 jmp

Now we look at the task of fetching a 16-bit jump address and setting the
_vm\_ip_ to this new value:

```
  lda     (vm_ip)        ; Grab the low jump address.
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; See if page crossed.
  jsr     vm_step_page   ; Do the job of stepping to the next page.
: tax                    ; Hide the low jump address in X
  lda     (vm_ip)        ; Grab the high jump address.
  stx     vm_ip          ; Update the vm_ip low byte.
  jsr     vm_update      ; Update the vm_ip high byte.
```

This consumes 18 bytes and 41 clock cycles or 74 if a page boundary is crossed.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 4 bra

Again we look at the classic 8-bit relative branch.  The code shown is,
in effect, the implementation of this hypothetical bra instruction.

```
  lda     (vm_ip)        ; Grab the low jump address.
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; See if page crossed.
  jsr     vm_step_page   ; Do the job of stepping to the next page.
: ldx     #0
  and     #$FF           ; Retest the displacement.
  bpl     :+             ; Skip for positive displacements.
  dex                    ; Sign extend negative displacements.
: clc                    ; vm_ip = vm_ip + displacement.
  adc     vm_ip
  sta     vm_ip
  txa
  adc     vm_ip+2
  cmp     vm_ip+2        ; See if the high address changed.
  beq     :+             ; If no change, skip to the end.
  sta     vm_ip+2        ; Update the shadow register
  and     #$1F
  ora     #$A0
  sta     vm_ip+1        ; Update the base address page.
  lda     vm_ip+2        ; Select the correct high ram bank.
  lsr                    ; Isolate the bank number.
  lsr
  lsr
  lsr
  lsr
  clc                    ; Add in the base value.
  adc     vm_base
  sta     d1pra          ; Switch in the desired ram bank.
:
```

This consumes 49 bytes and 40 clock cycles, 70 if a page boundary is crossed.
Heavy!

[Back to the Top](#the-vm-instruction-pointer)

#### Option 4 jsr/rts

Next is the classical jump to and return from a subroutine. For these examples
we again assume the the CPU stack is being used to hold return addresses. First
_jsr_:

```
  lda     (vm_ip)        ; Grab the low jump address.
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; See if page crossed.
  jsr     vm_step_page   ; Do the job of stepping to the next page.
: sta     vm_t           ; Save it
  lda     (vm_ip)        ; Grab the low jump address.
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; See if page crossed.
  jsr     vm_step_page   ; Do the job of stepping to the next page.
: sta     vm_t+1         ; Save it
  lda     vm_ip+1        ; Get the high byte of the vm_ip
  pha                    ; Push it
  lda     vm_ip          ; Get the low byte of the vm_ip
  pha                    ; Push it
  lda     vm_t           ; Update the vm_ip low byte
  sta     vm_ip
  lda     vm_t+1         ; Update the vm_ip high byte
  cmp     vm_ip+2        ; See if the high address changed.
  beq     :+             ; If no change, skip to the end.
  sta     vm_ip+2        ; Update the shadow register
  and     #$1F
  ora     #$A0
  sta     vm_ip+1        ; Update the base address page.
  lda     vm_ip+2        ; Select the correct high ram bank.
  lsr                    ; Isolate the bank number.
  lsr
  lsr
  lsr
  lsr
  clc                    ; Add in the base value.
  adc     vm_base
  sta     d1pra          ; Switch in the desired ram bank.
:
```

This consumes 62 bytes and 55 clock cycles or 88 if a page boundary is
crossed. Next, _rts_ is a little less nasty:

```
  pla                    ; Get the low byte
  sta     vm_ip          ; Update vm_ip
  pla                    ; Get the high byte
  jsr     vm_update
```

This consumes only 7 bytes and 29 clock cycles or 72 if a page boundary is
crossed.

[Back to the Top](#the-vm-instruction-pointer)

### Option 5

Option 5 changes a great deal about addressing. Whereas option 4 creates
a linear 16 bit address space, option 5 is anything but linear. It is lumpy
and full of limits. It parks its code in 8K segments. The format of option 5
addresses is in fact the format used internally by option 4; An eight bit
segment number combined with a 16 bit address constrained to the range $A000
though $BFFF.

This option uses a more complex IP address. Here it is illustrated:

![Option 5](../images/option5c.png)

Where:
* __B0...B7__ is the select value of the current bank kept in the d1pra
register of the 65C22 VIA number one.
* __101__ is the constant bank high 3 bit value.
* __A0...A12__ is the 13 bit byte address with the current bank.

One more thing. Since this option supports multiple segments in the form of
memory banks, it also needs to distinguish between operations that within
a segment (bank) called near, and those that go between segments (banks)
called far. This split takes the form of the default entry (far) and those
explicitly marked as near.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 5 fetch

The instruction fetch for option 5 benefits from the fact that code is not
permitted to transition from one bank to another. This results in code that
is the same as option 1 since no bank register update is needed.

```
  lda     (vm_ip)        ; Grab the op code.
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
:
```

[Back to the Top](#the-vm-instruction-pointer)

#### Option 5 jmp far

This instruction is used to jump to code located in another segment (bank) or
to any segment (bank) from code located in low ram.

```
  lda     (vm_ip)        ; Grab the low jump address.
  sta     vm_t           ; Hide it in vm_t
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
: lda     (vm_ip)        ; Grab the high jump address.
  tax                    ; stash it in X
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
: lda     (vm_ip)        ; Grab the bank number.
  sta     d1pra          ; Update the bank select register
  stx     vm_ip+1        ; Update the vm_ip
  lda     vm_t
  sta     vm_ip
```

This consumes 30 bytes and 45 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 5 jmp near

This instruction is used to jump to code located in the same segment (bank)
as the current code or to code located in low ram.

```
  lda     (vm_ip)        ; Grab the low jump address.
  tax                    ; Hide it in X
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
: lda     (vm_ip)        ; Grab the high jump address.
  stx     vm_ip          ; Update the vm_ip
  sta     vm_ip+1
```

This code consumes 15 bytes and 26 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 5 bra

Now we revisit the classic 8-bit relative branch. The code shown is,
in effect, the implementation of this hypothetical bra instruction:

```
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
```

This consumes 24 bytes and an average of 36.5 clock cycles, assuming that
branch displacement values are evenly scattered.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 5 jsr far

This instruction is used to call a subroutine located in another segment
(bank) or in any segment (bank) from code located in low ram.

```
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
  lda     (vm_ip)        ; Grab the bank number
  inc     vm_ip
  bne     :+
  inc     vm_ip+1
: sta     vm_t+2         ; Save it
  lda     d1pra          ; Get the current bank number
  pha                    ; Push it
  lda     vm_ip+1        ; Get the high byte of the vm_ip
  pha                    ; Push it
  lda     vm_ip          ; Get the low byte of the vm_ip
  pha                    ; Push it
  lda     vm_t           ; Update the vm_ip low byte
  sta     vm_ip
  lda     vm_t+1         ; Update the vm_ip high byte
  sta     vm_ip+1
  lda     vm_t+2         ; Update the bank select
  sta     d1pra
```

For 47 bytes and 85 clocks.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 5 jsr near

This instruction is used to call a subroutine located in the same segment
(bank) as the current code or to code located in low ram.

```
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
```

For 34 bytes and 56 clocks.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 5 rts far

This form of the _rts_ instruction is used to return from a subroutine that
has been called with the far form of _jsr_

```
  pla                    ; Get the low byte
  sta     vm_ip          ; Update vm_ip
  pla                    ; Get the high byte
  sta     vm_ip+1        ; Update vm_ip+1
  pla                    ; Get the segment (bank) number
  sta     d1pra          ; Make it the current segment
```

This consumes only 10 bytes and 22 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 5 rts near

This form of the _rts_ instruction is used to return from a subroutine that
has been called with the near form of _jsr_

```
  pla                    ; Get the low byte
  sta     vm_ip          ; Update vm_ip
  pla                    ; Get the high byte
  sta     vm_ip+1        ; Update vm_ip+1
```

This consumes only 6 bytes and 14 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

### Option 6

Finally, option 6 asks the question: What if combined option 5 with option 2?
That is a generalized 24 bit base address combined with a nimble 8 bit
offset?

Option 6, the most complex we'll examine here, is shown below:

![Option 6](../images/option6b.png)

Where:
* __B0...B7__ is the select value of the current bank kept in the d1pra
register of the 65C22 VIA number one.
* __101__ is the constant bank high 3 bit value.
* __A0...A12__ is the 13 bit byte address with the current bank.
* __P0...P7__ is the 8 bit offset into the current procedure.

One more thing. Since this option supports multiple segments in the form of
memory banks, it also needs to distinguish between operations that within
a segment (bank) called near, and those that go between segments (banks)
called far. This split takes the form of the default entry (far) and those
explicitly marked as near.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 6 fetch

Again, the restrictions of not crossing banks plus the 256 byte limit of a
proc, allow for very lean fetch code:

```
  lda     (vm_ip),y      ; Grab the op code.
  iny                    ; Step the vm_ip.
```

[Back to the Top](#the-vm-instruction-pointer)

#### Option 6 jmp far

This instruction is used to jump to code located in another segment (bank) or
to any segment (bank) from code located in low ram.

This instruction is used to jump to code located in another segment (bank) or
to any segment (bank) from code located in low ram.

```
  lda     (vm_ip)        ; Grab the low jump address.
  sta     vm_t           ; Hide it in vm_t
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
: lda     (vm_ip)        ; Grab the high jump address.
  tax                    ; stash it in X
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
: lda     (vm_ip)        ; Grab the bank number.
  sta     d1pra          ; Update the bank select register
  stx     vm_ip+1        ; Update the vm_ip
  lda     vm_t
  sta     vm_ip
  ldy     #0             ; Clear the proc offeset.
```

This consumes 32 bytes and 47 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 6 jmp near

This instruction is used to jump to code located in the same segment (bank)
as the current code or to code located in low ram.

```
  lda     (vm_ip)        ; Grab the low jump address.
  tax                    ; Hide it in X
  inc     vm_ip          ; Step the vm_ip.
  bne     :+             ; Skip if no page cross.
  inc     vm_ip+1        ; Cross to the next page.
: lda     (vm_ip)        ; Grab the high jump address.
  stx     vm_ip          ; Update the vm_ip
  sta     vm_ip+1
  ldy     #0             ; Clear the proc offeset.
```

This code consumes 17 bytes and 28 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 6 bra

Like option 2, we change things up a bit. Again, rather than
the classical relative branch, we redefine _bra_ to be a jump withing the
current proc. Here's what we get:

```
  lda     (vm_ip),y      ; Grab the new offset.
  tay                    ; Go there!
```

Just 3 bytes and 7 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 6 jsr far

This instruction is used to call a subroutine located in another segment
(bank) or in any segment (bank) from code located in low ram.

```
  lda     d1psa          ; Push the current segment (bank) number.
  pha
  lda     vm_ip+1        ; Push the vm_ip base.
  pha
  lda     vm_ip
  pha
  lda     (vm_ip),y      ; Get the 24 bit target.
  iny
  sta     vm_t
  lda     (vm_ip),y
  iny
  tax
  lda     (vm_ip),y
  iny
  sta     d1psa          ; Set the vm_ip to the new value.
  stx     vm_ip+1
  lda     vm_t
  sta     vm_ip
  phy                    ; Push the offset.
  ldy     #0             ; Set the offset to 0.
```

This code consumes 34 bytes and 59 clocks.


[Back to the Top](#the-vm-instruction-pointer)

#### Option 6 jsr near

This instruction is used to call a subroutine located in the same segment
(bank) as the current code or to code located in low ram.

```
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
```

This code consumes 20 bytes and 39 clocks.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 6 rts far

This form of the _rts_ instruction is used to return from a subroutine that
has been called with the far form of _jsr_

```
  pla                    ; restore the segment (bank) number
  sta     d1psa
  ply                    ; Restore the offset
  pla                    ; Get the low byte
  sta     vm_ip          ; Update vm_ip
  pla                    ; Get the high byte
  sta     vm_ip+1        ; Update vm_ip+1
```

This consumes 11 bytes and 26 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 6 rts near

This form of the _rts_ instruction is used to return from a subroutine that
has been called with the near form of _jsr_

```
  ply                    ; Restore the offset
  pla                    ; Get the low byte
  sta     vm_ip          ; Update vm_ip
  pla                    ; Get the high byte
  sta     vm_ip+1        ; Update vm_ip+1
```

This consumes 7 bytes and 18 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

#### Option 6 mark

An optional instruction for option 6 is mark. The purpose of this instruction
is to "re-align" the vm_ip base pointer so that code beyond 256 bytes may be
contained in a proc. The need for this instruction is debatable, but it is
presented here as an example of a conceptual extension to this option.

The code for this operation is identical to that for option 2 and consumes
13 bytes and 20 clock cycles.

[Back to the Top](#the-vm-instruction-pointer)

## Design Comparisons

Tables are formatted by bytes/clocks for each option and test case.

Byte Codes   | fetch  |  jmp   |  bra   |   jsr  |   rts  |  mark  |
-------------|:------:|:------:|:------:|:------:|:------:|:------:|
Option 1     |  8/13  | 15/26  | 24/37  | 34/56  |  6/14  |    -   |
Reduced Size |  3/24  | 10/36  | 19/48  | 24/78  |    -   |    -   |
Option 2     |  3/7   | 12/22  |  3/7   | 20/39  |  7/18  |  13/20 |
Option 3     |  7/10  | 14/23  | 23/34  | 38/60  |  8/16  |    -   |
Reduced Size |  3/21  | 10/33  | 19/45  | 30/82  |    -   |    -   |
Option 4     |  9/13  |18/41-74|49/40-70|62/55-88| 7/29-72|    -   |
Option 5     |  8/13  | 30/45  |   -    | 47/85  | 10/22  |    -   |
Near         |   -    | 15/26  | 24/37  | 34/56  |  6/14  |    -   |
Option 6     |  3/7   | 32/47  |   -    | 34/59  | 11/26  |  13/20 |
Near         |   -    | 17/28  |  3/7   | 20/30  |  7/18  |    -   |


Threaded     | fetch  |  jmp   |  bra   |  enter |  exit  |  mark  |
-------------|:------:|:------:|:------:|:------:|:------:|:------:|
Option 1     | 20/32  | 15/26  | 24/7   | 19/30  |  6/14  |    -   |
Reduced Size | 10/54  | 10/36  | 19/8   |   -    |    -   |    -   |
Option 2     | 10/20  | 12/22  |  3/7   | 17/29  |  7/18  |  13/20 |
Option 3     | 18/26  | 14/23  | 23/4   | 21/34  |  8/16  |    -   |
Reduced Size | 10/48  | 10/34  | 19/45  |   -    |    -   |    -   |

[Back to the Top](#the-vm-instruction-pointer)

## Macro Abstraction

A very useful concept in programming is that of decoupling. This idea is used
to make code less sensitive to changes in the code that it relies on. To
help achieve this with our instruction pointer, macros can be employed. The
most widely used feature of the IP is that of fetching a byte from the
instruction stream. This can be represented by as:

```
vm_fetch           ; Fetch a byte from the instruction stream.
```

A possible refinement would be to add emphasis "hints" like:

```
vm_fetch_f         ; Fetch a byte with emphasis on being fast.
vm_fetch_s         ; Fetch a byte with emphasis on saving space.
```

In some designs these macros will be different, reflecting the emphasis. In
other designs they could generate the exact same code, reflecting the fact
that the design has no such trade offs. In either case, changes in the design
will continue to reflect the intent of the code as written. Now, code that
works directly with updating or modifying the instruction pointer will
need to track changes, but code that just needs to get a byte, should not
need to be changed.

[Back to the Top](#the-vm-instruction-pointer)
