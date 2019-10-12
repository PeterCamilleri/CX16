# The assist_16.i65 file

This is an include file full of macros that assist CX16 programmers in handling
16 bit values in 65C02 assembly language. It consists of a number of utility
macros that are normally included in a source file with the following line of
code:

    .include "assist_16.i65"

This will include all of the macros of the library. Alternatively, the
programmer may opt to use the lower level include files (see the table below)
and only load in those components required by their application. This may save
some time in assembling the program.

Note that none of the code in this file has any dependency on any ROMs, entry
points, or other software in the system. It can be used with any 65C02 system.

One area missing in the 65C02 instruction set are operations that manipulate
16-bit quantities in memory. The goal here is not to replace the 65C02 with a
virtual dream machine. Rather, it is to augment the processor with those very
basic 16-bit operations that always seem so hard to do normally.

There are several possible strategies that may be employed in achieving this
goal:

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

WIP - this is being rewritten!

Operation        | Macro  | Summary                  | Flags | File        | Test
-----------------|--------|--------------------------|-------|-------------|----------------
Initialize       | set_16 | var &larr; value         |       | set_16.i65  | t65_set_16.a65
Increment        | inc_16 | var &larr; var + 1       |       | inc_16.i65  | t65_inc_16.a65
Decrement        | dec_16 | var &larr; var &#8211; 1 |       | dec_16.i65  | t65_dec_16.a65
Add a step       | adj_16 | var &larr; var + step    |       | adj_16.i65  | t65_adj_16.a65


These macros support four addressing modes:

Mode | Assembler | Description
-----|-----------|-----------------------------------
zp   | zp        | zero page
abs  | abs       | absolute
zpi  | (zp)      | zero page indirect
zpy  | (zp),y    | zero page indirect indexed with Y

*Warning:* With zero page indirect indexed with Y addressing mode, the caller 
is responsible for setting up the Y register. Further, a page wrap error will
occur if the Y register is set to $FF.

*Sub-macros:*  The above macros contain "parsers" that determine the addressing 
mode in use. They are less capable than the main parser used by the ca65 
assembler but do well enough most of the time. For those cases where this is 
not so, it is possible to bypass the parser and use the lower level macros 
directly. The arguments to these are just the labels or expressions without 
the addressing mode syntax. For example:

* For zero page indirect use my_pointer and not (my_pointer)
* For zero page indirect indexed with Y use my_pointer and not (my_pointer),y

Here are those lower level macros:

Operation/Mode   | zp or abs   | (zp)        | (zp),y      | Summary                       | File
-----------------|-------------|-------------|-------------|-------------------------------|----
Initialize       | _set_var_16 | _set_zpp_16 | _set_zpy_16
Increment        | _inc_var_16 | _inc_zpp_16 | _inc_zpy_16
Decrement        | _dec_var_16 | _dec_zpp_16 | _dec_zpy_16
Add a step       | _adj_var_16 | _adj_zpp_16 | _adj_zpy_16 | mode &larr; mode + step       | adj_16.i65
Test             | tst_var_16 | tst_zpp_16 | tst_zpy_16 | mode &#8211; 0 (Sets NZ)      | tst_16.i65
Equal            | eql_var_16 | eql_zpp_16 | eql_zpy_16 | mode = value (Sets Z)         | eql_16.i65
Greater or Equal | gte_var_16 | gte_zpp_16 | gte_zpy_16 | mode &ge; value (Sets C)      | gte_16.i65
Compare          | cmp_var_16 | cmp_zpp_16 | cmp_zpy_16 | mode &#8211; value (Sets CNZ) | cmp_16.i65

Where mode represents the three addressing modes supported for the 16-bit data
processed by these macros. These are:

* var - This corresponds to the zero page or absolute addressing modes of the
65C02 microprocessor.
* zpp - This corresponds to the zero page indirect addressing mode of the
65C02 microprocessor.
* zpy - This corresponds to the zero page indirect indexed with Y addressing
mode of the 65C02 microprocessor.

It will be noted that the macro names are a bit long winded. While not the 30+
character monsters seen in Java, they are certainly not the terse 3 or 4
character snips that are common in assembly language. There are reasons for
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

### set_16

A macro to initialize a 16 bit variable in memory with a value.

*Declaration:*

    .macro set_16 var,value

*Parameters:*
* var - the 16 bit variable.
* value - a value used to initialize var.

*Notes:*
* Optimized for special case values like 0, $00xx, and $xx00

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | Unless value is 0, clobbers the A register, Z and N flags.
zpi     | Clobbers the A and Y registers, Z and N flags.
zpy     | Clobbers the A register, Z and N flags.

*Example:*

    .zeropage
    my_var: .res  2   ; My variables in the zero page for this example.
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 my_var, 0                 ; Clear my_var.
      set_16 root, root_array          ; Root points to the start of root_array.

### inc_16

A macro to increment a 16 bit variable in memory.

*Declaration:*

    .macro inc_16 var

*Parameters:*
* var - the 16 bit variable.

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | Clobbers the Z and N flags.
zpi     | Clobbers the A and Y register, Z and N flags.
zpy     | Clobbers the A register and the Z and N flags.

*Example:*

    .zeropage
    my_var: .res  2                    ; My variable in the zero page in this example.

    .code
      ; stuff omitted.
      inc_16 my_var                    ; Step to the next.

### dec_16
Decrement a 16 bit variable in memory.

*Declaration:*

    .macro dec_16 var

*Parameters:*
* var - the name of a 16 bit variable.

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | Clobbers the A register and the Z and N flags.
zpi     | Clobbers the A and Y register, and the Z and N flags.
zpy     | Clobbers the A register and the Z and N flags.

*Example:*

    .zeropage
    my_var: .res  2                    ; My variable in the zero page in this example.

    .code
      ; stuff omitted.
      dec_16 my_var                    ; Step to the previous.

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 root,root_array           ; Set up the pointer to the base of the array.
      ; stuff omitted.
      dec_16 (root)                    ; Decrement the first element of the array.

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 root, root_array          ; Set up the pointer to the base of the array.
      ; stuff omitted.
      ldy #21*2
      dec_16 {(root),y}                ; Decrement the twenty first element of the array.

### adj_16
Adjust a 16 bit variable in memory by a literal amount.

*Declaration:*

    .macro adj_16 var,step

*Parameters:*
* var - the 16 bit variable.
* step - an integer constant to be added to var.

*Notes:*
* Optimized for special cases like a step of 0, 1..255, $100..$FF00

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | Clobbers the A register and the Z and N flags.
zpi     | Clobbers the A and Y register, and the Z and N flags.
zpy     | Clobbers the A register and the Z and N flags.


*Example:*
    .zeropage
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.
    item_len = 10                      ; Each item in the array is 10 bytes long.

    .code
      ; stuff omitted.
      set_var_16 root, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.
      adj_var_16 root, item_len        ; Step to the next item.

*Example:*

    .zeropage
    pieces: .res  2

    .code
      ; stuff omitted.
      adj_zpp_16 pieces, 10            ; Add 10 to the weight of this chess piece.

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_var_16 root, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.
      ldy #21*2
      adj_zpy_16 root,10               ; Adjust the twenty first element of the array by 10.

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
    counter: .res  2

    .code
      ; stuff omitted.
      set_var_16 counter, 1535         ; Set up the loop counter.
    loop:
      ; Do really cool stuff (omitted).

      dec_var_16 root                  ; Decrement the loop counter
      tst_var_16                       ; Is is zero?
      bne loop                         ; If not, keep looping!

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
    health: .res 2                     ; A pointer into the health array.

    .code
      ; stuff omitted.
      tst_zpp_16 health                ; Which side of the grass?
      bmi morte                        ; Health negative, dead.
      beq morte                        ; Health zero, dead.
      ; still alive                    ; Health greater than zero, alive.
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
* Page wrap failure if Y == $FF on entry.

*Example:*

    .zeropage
    health: .res 2                     ; A pointer into the health array.
    count:  .res 1                     ; A loop counter.

    .code
      ; stuff omitted.

      lda creature_count               ; Set up the creature count.
      sta count
      ldy #0

    health_loop:
      ; stuff omitted.
      tst_zpy_16 health                ; Which side of the grass?
      bmi morte                        ; Health negative, dead.
      beq morte                        ; Health zero, dead.
      ; still alive                    ; Health greater than zero, alive.
      ; stuff omitted.
      bra next_creature:

    morte:                             ; The creature is dead.
    ; stuff omitted.

    next_creature:                     ; Process the next creature.
      iny
      iny
      dec count
      bne health_loop
      ; stuff omitted.

### eql_var_16
Compare a 16 bit variable in memory with a value to see if they are equal.

*Declaration:*

    .macro eql_var_16 var, value

*Parameters:*
* var  - the name of a zero page or absolute addressed 16 bit variable.
* value - an integer value to compare var with.

*Returns:*
* The Z flag is set if var equals value.

*Notes:*
* Clobbers the A register.
* Optimized for special cases like values of 0, 1..255, $100..$FF00

*Example:*

    .zeropage
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.
    item_count = 42                    ; There are 42 items.
    item_len   = 10                    ; Each item in the array is 10 bytes long.
    array_len  = item_count*item_len

    .code
      ; stuff omitted.
      set_var_16 root, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.

    loop:
      ; Do amazing (omitted) things with the current entry.

      adj_var_16 root, item_len        ; Step to the next item.
      eql_var_16 root, root_array+array_len ; Are we at the end?
      bne loop

### eql_zpp_16
Compare a 16 bit variable in memory pointed to by a zero page pointer with a
value to see if they are equal.

*Declaration:*

    .macro eql_zpp_16 zpp, value

*Parameters:*
* zpp - a pointer in the zero page that points to a 16 bit variable.
* value - an integer value to compare var with.

*Returns:*
* The Z flag is set if var equals value.

*Notes:*
* Clobbers the A and Y registers.
* Optimized for special cases like values of 0, $00xx, $xx00.

*Example:*

    .zeropage
    pter: .res 2                       ; A pointer to some data.

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_var_16 pter, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.

      eql_zpp_16 pter, 42              ; Test current array element for the answer.
      bne no_answer
      ; stuff omitted.                 ; Found the answer. Process it,

    no_answer:
      ; stuff omitted.


### eql_zpy_16
Compare a 16 bit variable in memory pointed to by a zero page pointer indexed
by the Y register with a value to see if they are equal.

*Declaration:*

    .macro eql_zpy_16 zpy, value

*Parameters:*
* zpy - a pointer in the zero page, indexed by the Y register, that points to
a 16 bit variable. The Y register needs to be setup by the caller.
* value - an integer value to compare (zpy),y with.

*Returns:*
* The Z flag is set if the 16 bit data at (zpy),y equals value.

*Notes:*
* Clobbers the A register.
* Optimized for special cases like values of 0 and $xx00.
* Page wrap failure if Y == $FF on entry.

*Example:*

    .zeropage
    pter: .res 2                       ; A pointer to some data.
    cter: .res 1                       ; A loop counter

    .import root_array:absolute        ; Import a reference to an array in another file.
    .import root_size                  ; Import its size too.

    .code
      ; stuff omitted.

      ; Scour the array looking for answers!
      set_var_16 pter, root_array      ; Set up the pointer to the base of the array.
      ldy #0
      lda #root_size
      sta cter

    scour_loop:

      ; stuff omitted.

      eql_zpy_16 pter, 42              ; Test current array element for the answer.
      bne no_answer

      ; stuff omitted.                 ; Found the answer. Process it.

    no_answer:

      iny
      iny
      dec cter
      bne scour_loop

### gte_var_16
Compare a 16 bit variable in memory with a value to see if it is greater or
equal.

*Declaration:*

    .macro gte_var_16 var, value

*Parameters:*
* var - the name of a zero page or absolute addressed 16 bit variable.
* value - an integer value to compare var with.

*Returns:*
* The C and N flags are set if var is greater or equal to value.
* C is set if var >= value using unsigned comparison.
* N is cleared if var >= value using signed comparison.

*Notes:*
* Clobbers the A register.
* Optimized for special cases like values of $xx00.

*Example:*

    .zeropage
    score: .res 2

    .code
      ; stuff omitted.

      ; Level completed, check for bonuses
    bonus_loop:
      gte_var_16 score, 1000          ; >= 1000 for a bonus
      bcc no_bonus

      adj_var_16 score, -1000         ; Remove 1000 points
      ; do other bonus things

      bra bonus_loop

    no_bonus:

### gte_zpp_16
Compare a 16 bit variable in memory pointed to by a zero page pointer with
a value to see if it is greater or equal.

*Declaration*

    .macro gte_zpp_16 zpp, value

*Parameters:*
* zpp - a pointer in the zero page that points to a 16 bit variable.
* value - an integer value to compare (zpp) with.

*Returns:*
* The C and N flags are set if (zpp) is greater or equal to value.
* C is set if (zpp) >= value using unsigned comparison.
* N is cleared if (zpp) >= value using signed comparison.

*Notes:*
* Clobbers the A and Y registers.
* Optimized for special cases like values of $xx00.

*Example:*

    .zeropage
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_var_16 creature, root_array  ; Set up the pointer to the base of the array.
      ; stuff omitted.

      gte_zpp_16 creature, 400         ; Test current creature for low health.
      bcs health_ok
      ; stuff omitted.                 ; The creature health < 400, handle it.

    health_ok:                         ; The creature health >= 400.
      ; stuff omitted.

### gte_zpy_16
Compare a 16 bit variable in memory pointed to by a zero page pointer
indexed with the Y register with a value to see if it is greater or equal.

*Declaration*

    .macro gte_zpy_16 zpy, value

*Parameters:*
* zpy - a pointer in the zero page indexed with the Y register that points
to a 16 bit variable.
* value - an integer value to compare (zpp) with.

*Returns:*
* The C and N flags are set if (zpp) is greater or equal to value.
* C is set if (zpp) >= value using unsigned comparison.
* N is cleared if (zpp) >= value using signed comparison.

*Notes:*
* Clobbers the A register.
* Optimized for special cases like values of $xx00.

*Example:*

    .zeropage
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.
    .import array_size                 ; and its size in words.

    .code
      ; stuff omitted.
      set_var_16 creature, root_array  ; Set up the pointer to the base of the array.
      ; stuff omitted.

      ldy #0

    creature_loop:                     ; Loop through the creature array.
      gte_zpy_1y creature, 400         ; Test current creature for low health.
      bcs health_ok
      ; stuff omitted.                 ; The creature health < 400, handle it.
      bra next_creature

    health_ok:                         ; The creature health >= 400.
      ; stuff omitted.

    next_creature:
      iny                              ; Step Y by 2
      iny
      cpy #array_size*2                ; See if we are done.
      bne creature_loop

### cmp_var_16
Compare a 16 bit variable in memory with a value.

*Declaration:*

    .macro cmp_var_16 var, value

*Parameters:*
* var  - the name of a zero page or absolute addressed 16 bit variable.
* value - an integer value to compare var with.

*Returns:*
* The V, C, N, and Z flags are set.

*Notes:*
* Clobbers the A register.
* Optimized for special cases like values of $xx00.

*Example:*

    .zeropage
    score: .res 2

    .code
      ; stuff omitted.

      ; Level completed, check score
      cmp_var_16 score, 1000          ; == 1000 for a bonus
      bcc low_score                   ; If C is cleared score < 1000
      bne no_extra                    ; If Z is set score = 1000
      ; stuff omitted.                ; C is set and Z is not so score > 1000
      bra test_done

    no_extra:
      ; stuff omitted.
      bra test_done

    low_score:
      ; stuff omitted.

    test_done:

### cmp_zpp_16

Compare a 16 bit variable in memory pointed to by a zero page pointer
with a value.

*Declaration:*

    .macro cmp_zpp_16 zpp, value

*Parameters:*
* zpp - a pointer in the zero page that points to a 16 bit variable.
* value - an integer value to compare var with.

*Returns:*
* The V, C, N, and Z flags are set.

*Notes:*
* Clobbers the A and Y registers.
* Optimized for special cases like values of $xx00.

*Example:*

    .zeropage
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_var_16 creature, root_array  ; Set up the pointer to the base of the array.
      ; stuff omitted.

      cmp_zpp_16 creature, -400        ; Is the creature no longer resurrectable?

      bvs sign_flipped                 ; If overflow detected the N bit is flipped.
      bmi perma_dead                   ; If negative there's no coming back!
      bra still_alive
    sign_flipped:
      bpl perma_dead                   ; The sign is flipped so positive is negative.

    still_alive:
      ; stuff omitted.                 ; The creature health >= -400, handle it.

    perma_dead:                        ; The creature health < -400.
      ; stuff omitted.

### cmp_zpy_16
Compare a 16 bit variable in memory pointed to by a zero page pointer indexed
by the Y register with a value.

*Declaration:*

    .macro cmp_zpy_16 zpy, value

*Parameters:*
* zpy - a pointer in the zero page indexed by the Y register that points to
a 16 bit variable.  The Y register needs to be setup by the caller.
* value - an integer value to compare var with.

*Returns:*
* The V, C, N, and Z flags are set.

*Notes:*
* Clobbers the A register.
* Optimized for special cases like values of $xx00.
* Page wrap failure if Y == $FF on entry.

*Example:*

    .zeropage
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.
    .import array_size                 ; and its size in words.

    .code
      ; stuff omitted.
      set_var_16 creature, root_array  ; Set up the pointer to the base of the array.
      ; stuff omitted.

      ldy #0

    creature_loop:                     ; Loop through the creature array.
      cmp_zpy_1y creature, -400        ; Test current creature for low health.

      bvs sign_flipped                 ; If overflow detected the N bit is flipped.
      bmi perma_dead                   ; If negative there's no coming back!
      bra still_alive
    sign_flipped:
      bpl perma_dead                   ; The sign is flipped so positive is negative.

    still_alive:
      ; stuff omitted.                 ; The creature health >= -400, handle it.
      bra next_creature

    perma_dead:                        ; The creature health < -400.
      ; stuff omitted.

    next_creature:
      iny                              ; Step Y by 2
      iny
      cpy #array_size*2                ; See if we are done.
      bne creature_loop
