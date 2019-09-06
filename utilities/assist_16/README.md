# The assist_16.i65 file

This is an include file full of macros that assist CX16 programmers in handling
16 bit values in 65C02 assembly language. It consists of a number of utility
macros that are normally included in a source file with the following line of
code:

    .include "assist_16.i65"

Note that none of the code in this file has any dependency on any ROMs, entry
points, or other software in the system. It can be used with any 65C02 system.

One area missing in the 65C02 instruction set are operations that manipulate 16
bit quantities in memory. There are several possible strategies that may be
employed in resolving this lack:

1. The programmer can code up each case as needed. This give full control to
the programmer, but is highly distracting from the flow of the code and the
development process.
2. Place the code in a subroutine and call it using a "jsr" instruction. This
reduces clutter. The programmer still needs to write the subroutine and any
code needed to pass in parameters that may be required. This is in addition to
the overhead of the jsr/rts instructions.
3. Place the code in a macro. This reduces clutter and macros easily handle the
passing of parameters at assembly time. The downside is that macros can work
too well and hide important details. They can also use a lot of memory space.

Another issue is dealing with the fact that these operations will, as
side-effects, modify the values of registers not obviously involved in the
operation. These registers are said to have been "clobbered". There are two
main camps for dealing with this problem:

1. The routine can preserve any affected registers by using appropriate push
and pop instructions to preserve values and then restore them. While this wraps
the problem up neatly, it is wasteful since it often preserves registers that
the caller doesn't care about or can do so at a point in the code that is
inefficient.
2. The user of the routine can preserve registers by using appropriate push
and pop instructions to preserve values and then restore them. This exposes
the required code and adds some clutter. However the caller knows which
registers it needs and can save only those. Further it can place the push and
pop instructions at the optimum location (for example outside a loop).

The approach taken here is to wrap the required code in macros that expand the
code in-line. The caller is responsible for saving any required registers that
may be "clobbered" during processing.

This table lists the operations provided by the assist_16 package.

Operation/Mode | var        | zpp        | zpy
---------------|------------|------------|------------
Initialize     | set_var_16 | set_zpp_16 | set_zpy_16
Increment      | inc_var_16 | inc_zpp_16 | inc_zpy_16
Decrement      | dec_var_16 | dec_zpp_16 | dec_zpy_16
Adjust         | adj_var_16 | adj_zpp_16 | adj_zpy_16
Test           | tst_var_16 | tst_zpp_16 | tst_zpy_16

It will be noted that these names are a bit long winded. They are certainly
not the terse 3 or 4 characters long that are common. There are reasons for
this choice too.
* The names contain more information about the macro. In this case the
operation, the addressing mode, and the size of the target data.
* The longer names are much less likely to conflict with an existing names
than would be the case for terse names. Until assemblers get concepts like
namespaces, this will have to do.

Finally it will be noted, that this is a lot of code! This shows the beauty of
macros. The ones you don't use, don't take up any space in your target system.
You only need resources for what you use.

Details about each of the macros follows:

### set_var_16

A macro to initialize a 16 bit variable in memory with a value.

*Declaration:*

    .macro set_var_16 var,value

*Parameters:*
* var - the name of a zero page or absolute addressed 16 bit variable.
* value - a value used to initialize var.

*Notes:*
* Unless value is 0, clobbers the A register, Z and N flags.
* Optimized for special case values like 0, $00xx, and $xx00

*Example:*

    .zeropage
    my_var: .res  2   ; My variables in the zero page for this example.
    root:   .res  2

    .import root_array:absolute  ; Import a reference to an array in another file.

    .code
    ; stuff omitted.
    set_var_16 my_var, 0
    set_var_16 root, root_array

### set_zpp_16

Initialize a 16 bit variable in memory pointed to by a zero page pointer.

*Declaration:*

    .macro set_zpp_16 zpp,value

*Parameters:*
* zpp - a pointer in the zero page that points to a 16 bit variable.
* value - a value used to initialize the target data.

*Notes:*
* Clobbers the A and Y registers, Z and N flags.

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute  ; Import a reference to an array in another file.

    .code
    ; stuff omitted.
    set_var_16 root, root_array  ; Set up the pointer to the base of the array.
    ; stuff omitted.
    set_zpp_16 root, 0           ; Clear first element of the array.

### set_zpy_16
Initialize a 16 bit variable in memory pointed to by a zp pointer indexed by
the Y register.

*Declaration:*

    .macro set_zpy_16 zpy,value

*Parameters:*
* zpy - a pointer in the zero page, indexed by the Y register, that points to a
16 bit variable.  The Y register needs to be setup by the caller.
* value - a value used to initialize the target data.

*Notes:*
* Clobbers the A register, Z and N flags.
* Page wrap failure if Y == $FF on entry.

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute  ; Import a reference to an array in another file.

    .code
    ; stuff omitted.
    set_var_16 root, root_array  ; Set up the pointer to the base of the array.
    ; stuff omitted.
    ldy #21*2
    set_zpy_16 root, 0           ; Clear the twenty first element of the array.

### inc_var_16

A macro to increment a 16 bit variable in memory.

*Declaration:*

    .macro inc_var_16 var

*Parameters:*
* var - the name of a zero page or absolute addressed 16 bit variable.

*Notes:*
* Clobbers the Z and N flags.

*Example:*

    .zeropage
    my_var: .res  2   ; My variable in the zero page in this example.

    .code
    ; stuff omitted.
    inc_var_16 my_var ; Step to the next.

### inc_zpp_16
Increment a 16 bit variable pointed to by a zero page pointer.

*Declaration:*

    .macro inc_zpp_16 zpp

*Parameters:*
* zpp - a pointer in the zero page that points to a 16 bit variable.

*Notes:*
* Clobbers the Y register, Z and N flags.

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute  ; Import a reference to an array in another file.

    .code
    ; stuff omitted.
    set_var_16 root, root_array  ; Set up the pointer to the base of the array.
    ; stuff omitted.
    inc_zpp_16 root              ; Increment the first element of the array.

### inc_zpy_16
Increment a 16 bit variable pointed to by a zero page pointer indexed by the Y
register.

*Declaration:*

    .macro inc_zpy_16 zpy

*Parameters:*
* zpy - a pointer in the zero page, indexed by the Y register, that points to
a 16 bit variable. The Y register needs to be setup by the caller.

*Notes:*
* Clobbers the Z and N flags.
* Page wrap failure if Y == $FF on entry.

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute  ; Import a reference to an array in another file.

    .code
    ; stuff omitted.
    set_var_16 root, root_array  ; Set up the pointer to the base of the array.
    ; stuff omitted.
    ldy #21*2
    inc_zpy_16 root              ; Increment the twenty first element of the array.

### dec_var_16
Decrement a 16 bit variable in memory.

*Declaration:*

    .macro dec_var_16 var

*Parameters:*
* var - the name of a zero page or absolute addressed 16 bit variable.

*Notes:*
* Clobbers the A register, Z and N flags.

*Example:*

    .zeropage
    my_var: .res  2   ; My variable in the zero page in this example.

    .code
    ; stuff omitted.
    dec_var_16 my_var ; Step to the previous.

### dec_zpp_16
Decrement a 16 bit variable pointed to by a zero page pointer.

*Declaration:*

    .macro dec_zpp_16 zpp

*Parameters:*
* zpp - a pointer in the zero page that points to a 16 bit variable.

*Notes:*
* Clobbers the A and Y registers, Z and N flags.

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute  ; Import a reference to an array in another file.

    .code
    ; stuff omitted.
    set_var_16 root,root_array   ; Set up the pointer to the base of the array.
    ; stuff omitted.
    dec_zpp_16 root              ; Decrement the first element of the array.

### dec_zpy_16
Decrement a 16 bit variable pointed to by a zero page pointer indexed by the Y
register.

*Declaration:*

    .macro dec_zpy_16 zpy

*Parameters:*
* zpy - a pointer in the zero page, indexed by the Y register, that points to
a 16 bit variable. The Y register needs to be setup by the caller.

*Notes:*
* Clobbers the A register, Z and N flags.
* Page wrap failure if Y == $FF on entry.

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute  ; Import a reference to an array in another file.

    .code
    ; stuff omitted.
    set_var_16 root, root_array  ; Set up the pointer to the base of the array.
    ; stuff omitted.
    ldy #21*2
    dec_zpy_16 root              ; Decrement the twenty first element of the array.

### adj_var_16
Adjust a 16 bit variable in memory by a literal amount.

*Declaration:*

    .macro adj_var_16 var,step

*Parameters:*
* var - the name of a zero page or absolute addressed 16 bit variable.
* step - an integer constant to be added to var.

*Notes:*
* Clobbers the A register, C, V, Z and N flags.
* Optimized for special cases like a step of 0, 1..255, $100..$FF00

*Example:*
    .zeropage
    root:   .res  2

    .import root_array:absolute  ; Import a reference to an array in another file.
    item_len = 10                ; Each item in the array is 10 bytes long.

    .code
    ; stuff omitted.
    set_var_16 root, root_array  ; Set up the pointer to the base of the array.
    ; stuff omitted.
    adj_var_16 root, item_len    ; Step to the next item.

### adj_zpp_16
Adjust a 16 bit variable pointed to by a zero page pointer by a literal amount.

*Declaration:*

    .macro adj_zpp_16 zpp,step

*Parameters:*
* zpp - a pointer in the zero page that points to a 16 bit variable.
* step - an integer constant to be added to var.

*Notes:*
* Clobbers the A and Y registers, C, V, Z and N flags.
* Optimized for special cases like a step of 0, 1..255, $100..$FF00

*Example:*

    .zeropage
    pieces: .res  2

    .code
    ; stuff omitted.
    adj_zpp_16 pieces, 10        ; Add 10 to the weight of this chess piece.

### adj_zpy_16
Adjust a 16 bit variable pointed to by a zero page pointer indexed by the Y
register by a literal amount.

*Declaration:*

    .macro adj_zpy_16 zpy,step

*Parameters:*
* zpy - a pointer in the zero page, indexed by the Y register, that points to
a 16 bit variable. The Y register needs to be setup by the caller.
* step - an integer constant to be added to var.

*Notes:*
* Clobbers the A register, Z and N flags.
* Optimized for special cases like a step of 0, 1..255, $100..$FF00
* Page wrap failure if Y == $FF on entry.

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute  ; Import a reference to an array in another file.

    .code
    ; stuff omitted.
    set_var_16 root, root_array  ; Set up the pointer to the base of the array.
    ; stuff omitted.
    ldy #21*2
    adj_zpy_16 root,10           ; Adjust the twenty first element of the array by 10.

### tst_var_16
Test a 16 bit variable in memory.

*Declaration:*

    .macro tst_var_16 var

*Parameters:*
* var - the name of a zero page or absolute addressed 16 bit variable.

*Returns:*
* The N and Z flags are set according to the value tested.

*Notes:*
* Clobbers the A register.

*Example:*

    .zeropage
    counter .res  2

    .code
    ; stuff omitted.
    set_var_16 root, 1535        ; Set up the loop counter.
    loop:
    ; Do really cool stuff
    dec_var_16 root              ; Decrement the loop counter
    tst_var_16                   ; Is is zero?
    bne loop                     ; If not, keep looping!

### tst_zpp_16

*Declaration:*

    .macro tst_zpp_16 zpp

*Parameters:*
* zpp - a pointer in the zero page that points to a 16 bit variable.

*Returns:*
* The N and Z flags are set according to the value tested.

*Notes:*
* Clobbers the A and Y registers.

*Example:*

    .zeropage
    health .res 2                ; A pointer into the health array.

    .code
    ; stuff omitted.
    tst_zpp_16 health            ; Which side of the grass?
    bmi morte                    ; Health negative, dead.
    beq morte                    ; Health zero, dead.
    ; still alive                ; Health greater than zero, alive.
    ; stuff omitted.

    morte:
    ; stuff omitted.

### tst_zpy_16

*Declaration:*

    .macro tst_zpy_16 zpy

*Parameters:*
* zpy - a pointer in the zero page, indexed by the Y register, that points to
a 16 bit variable. The Y register needs to be setup by the caller.

*Returns:*
* The N and Z flags are set according to the value tested.

*Notes:*
* Clobbers the A register.

*Example:*

    .zeropage
    health .res 2                ; A pointer into the health array.
    count  .res 1                ; A loop counter.

    .code
    ; stuff omitted.

    lda creature_count           ; Set up the creature count.
    sta count
    ldy #0

    health_loop:
    ; stuff omitted.
    tst_zpy_16 health            ; Which side of the grass?
    bmi morte                    ; Health negative, dead.
    beq morte                    ; Health zero, dead.
    ; still alive                ; Health greater than zero, alive.
    ; stuff omitted.

    morte:
    ; stuff omitted.

    next_creature:
    iny
    iny
    dec count
    bne health_loop
    ; stuff omitted.