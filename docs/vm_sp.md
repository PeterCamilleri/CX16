# Implementing VM Stacks

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)
* [Stack Options](#stack-options)
   * [The System Stack](#the-system-stack)
   * [The Absolute Indexed Stack](#the-absolute-indexed-stack)
   * [The Zippy Stack](#the-zippy-stack)
   * [The Page Stack](#the-page-stack)
   * [The Large Stack](#the-large-stack)

## Introduction

This section will focus on the options available for providing stack support.
This means test cases will be designed with the goal of making the best use
of the limited resources of the W65C02S. Studies will note the resources of
memory and clock cycles used by each design.

To compare the designs, the following uses for stacks are examined:

1. Holding subroutine return addresses.
2. Passing parameters to a function or procedure.
3. Accessing parameters to this function or procedure.
4. Setting the return value for this function.
5. Getting return values back from functions.
6. Allocation of local variables.
7. Accessing those local variables.
8. Preserving native registers and variables when necessary for internal
virtual machine code.

[Back to the Top](#implementing-vm-stacks)

## Stack Options

In this section, let's take a look at the sorts of stacks available for use.
In very general terms these fall into one of two camps:

* Small stacks of 256 bytes or less.
* Larger stacks with no 256 byte size limit.

Now let's look at what low level operations fit our use cases:

* Pushing data onto the stack.
* Popping data from the stack.
* Creating stack frames.
* Destroying stack frames.
* Accessing data in the frame using a frame pointer and an
offset.
* Performing arithmetic and logic operations on stack data.

And as if that weren't enough there are still more considerations:

* Are there any special alignment requirements to use the stack?
* Can the stacks be moved around for efficient multi-threading?
* Can the stack share space with a heap to support dynamic memory allocation?
* When we index from the stack pointer, does the offset value need to be
signed, or can we make do with an unsigned offset?
* Can we divide the tasks of our stack into multiple stack types, each better
suited to the tasks assigned to it?

There are actually a lot of variations of the code that can be used to
implement the functionality of a stack. The following sections examine a
few of these possibilities:

[Back to the Top](#implementing-vm-stacks)

### The System Stack

The W65C02S stack pointer (S) is used to provide a small stack (256 bytes)
with a fixed location in memory page 1. It is reasonably good at pushing and
popping data, especially with the enhanced instruction set of the CMOS
version of the chip:

```
  php                    ; Push the processor status register.
  phy                    ; Push Y (Enhancement)
  phx                    ; Push X (Enhancement)
  pha                    ; Push A

  pla                    ; Pull A
  plx                    ; Pull X (Enhancement)
  ply                    ; Pull Y (Enhancement)
  plp                    ; Pull the processor status register.
```

No other operations are available for data on the stack. In particular it is
not possible to use the S register in any sort of indexed addressing mode. It
is possible to simulate this however, as shown in this example:

```
  ; Add the last two bytes pushed onto the stack.
  pla                    ; Get the last byte pushed
  tsx                    ; X mirrors S
  clc                    ; Prepare to add.
  adc $101,x             ; Add in the byte above.
  sta $101,x             ; Save result.
```

While the system stack is well suited to the task of pushing and pulling
values, it's small size makes it unsuitable for holding stack frames. It is
a candidate for use as an evaluation stack, but again, its small size can
make things a bit cramped. It is fixed in page 1, meaning that multi-threading
systems are forced to carve up the tiny space available, or a lot of data
needs to be copied to move stacks.

Notes:
* The system stack is naturally page aligned in page 1.
* The pull instructions all modify the P register. So in any sequence
that seeks to preserve that register, the _plp_ instruction must be the last
one in the sequence. One such sequence is shown above.
* In addition, since the system stack is used during interrupt processing, no
data should ever be placed or accessed from addresses less than the address
$101 + S.

[Back to the Top](#implementing-vm-stacks)

### The Absolute Indexed Stack

This type of stack uses one of the index registers (X or Y) along with an
absolute base to simulate stack behavior. Let's see what's involved with
push and pull:

```
  ; ais_pha
  sta stack_base,x       ; Write the data.
  dex                    ; Adjust the stack pointer.

  ; ais_pla
  inx                    ; Adjust the stack pointer.
  lda stack_base,x       ; Read the data.
```

This type of stack also allows for other operations beyond the basic push
and pull, though the X register has a richer set than the Y register.

```
  ; Add the last two bytes pushed onto the stack.
  clc                    ; Prepare to add.
  lda stack_base+1,x     ; Get the last byte pushed
  adc stack_base+2,x     ; Add in the byte above.
  sta stack_base+2,x     ; Save result.
  inx
```

A useful feature of this type of stack is the ease of accessing different
parts of the stack by using an offset value added to the stack base address.

Like the system stack, this is well suited to the task of pushing and pulling
data, and the evaluation of expressions. However, it's small size makes it
unsuitable for holding stack frames. Since its base address is fixed,
multi-threading systems are forced to either carve up the tiny space
available, or a lot of data needs to be copied to move stacks.

Notes:
* This type of stack may be used to create stacks from 2 up to a limit of 256
bytes.
* Stack space does not need to be page aligned, however, it will run faster
if it does not cross a page boundary.
* Since this stack uses an index register, the overhead of saving and
restoring that register needs to be factored in.
* For a stack of size L bytes, the initial stack pointer value is L-1.
* These stacks are not interrupt safe.

[Back to the Top](#implementing-vm-stacks)

### The Zippy Stack

This stack is based on the Zero Page Indirect Indexed with Y (zpy) addressing
mode. These stacks are similar to the absolute indexed stacks above except
that they require 2 bytes of zero page storage for the base pointer, generally
have slightly shorter code and consume more clock cycles. the are also
limited to the Y register and a restricted set of 8 instructions.

Also like the absolute indexed stacks, these are small stacks that use an
index register (Y).

Lets see push and pull:

```
  ; zippy_pha
  sta (stack_base),y     ; Write the data.
  dey                    ; Adjust the stack pointer.

  ; zippy_pla
  iny                    ; Adjust the stack pointer.
  lda (stack_base),y     ; Read the data.
```

While not as versatile as the X register, data manipulation is still
effective for these sorts of stacks:

```
  ; Add the last two bytes pushed onto the stack.
  clc                    ; Prepare to add.
  iny
  lda (stack_base),y     ; Get the last byte pushed
  iny
  adc (stack_base),y     ; Add in the byte above.
  sta (stack_base),y     ; Save result.
  dey
```

Notes:
* This type of stack may also be used to create stacks from 2 up to a limit
of 256 bytes.
* Stack space does not need to be page aligned. Further it will not run
faster if it does not cross a page boundary.
* Since this stack uses an index register, the overhead of saving and
restoring that register needs to be factored in.
* Since its base address is not fixed, multi-threading systems can easily
switch between multiple stacks.
* For a stack of size L bytes, the initial stack pointer value is L-1.
* These stacks are not interrupt safe.

[Back to the Top](#implementing-vm-stacks)

### The Page Stack

The page stack is yet another small stack based (predominantly) on the new
W65C02S addressing mode, zero page indirect. The concept is that of a page
aligned stack, access via an indirect pointer, where the upper 8 bits of the
address do not change. Only the lower 8 bits of the address are adjusted
as needed.

Lets see push and pull:

```
  ; page_pha
  sta (stack_base)       ; Write the data.
  dec stack_base         ; Adjust the stack pointer.

  ; page_pla
  inc stack_base         ; Adjust the stack pointer.
  lda (stack_base)       ; Read the data.
```

While limited in instructions available, data manipulation is still
effective for these sorts of stacks:

```
  ; Add the last two bytes pushed onto the stack.
  clc                    ; Prepare to add.
  ldy #1                 ; Use Y for offsets.
  lda (stack_base),y     ; Get the last byte pushed
  iny
  adc (stack_base),y     ; Add in the byte above.
  sta (stack_base),y     ; Save result.
  inc stack_base         ; Adjust the stack pointer.
```

Notes:
* Stack space needs to be page aligned.
* Since its base address is not fixed, multi-threading systems can easily
switch between multiple stacks.
* Since this stack occupies a page, the initial value of the low byte is $FF.
* No index registers are occupied by the operation of this stack.
* The Y register can be used to provide offsets to the stack pointer.
* These stacks are not interrupt safe.

[Back to the Top](#implementing-vm-stacks)

### The Large Stack

The large stack is similar to the page stack except that the full 16 bit
address is updated for each operation. This allows this stack to, for the
first time, exceed the 256 byte limit of all those small stacks. This comes
at a price though in terms of larger code and lower performance. To
start off, lets examine push and pull:

```
  ; ls_pha
  sta (stack_base)       ; Write the data.
  lda stack_base         ; Adjust the stack pointer.
  bne :+
  dec stack_base+1
: dec stack_base

  ; ls_pla
  inc stack_base         ; Adjust the stack pointer.
  bne :+
  inc stack_base+1
: lda (stack_base)       ; Read the data.

```

Data manipulation is not really effective for these sorts of stacks:

```
  ; Add the last two bytes pushed onto the stack.
  clc                    ; Prepare to add.
  ldy #1                 ; Use Y for offsets.
  lda (stack_base),y     ; Get the last byte pushed
  iny
  adc (stack_base),y     ; Add in the byte above.
  sta (stack_base),y     ; Save result.
  inc stack_base         ; Adjust the stack pointer.
  bne :+
  inc stack_base+1
:
```

Notes:
* Stack space does not need to be page aligned.
* Since its base address is not fixed, multi-threading systems can easily
switch between multiple stacks.
* The initial value of the stack pointer is the address of the last byte of
memory in the stack area.
* No index registers are occupied by the operation of this stack.
* The Y register can be used to provide offsets to the stack pointer.
* These stacks are not interrupt safe.

[Back to the Top](#implementing-vm-stacks)
