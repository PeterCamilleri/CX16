# The assist_16.i65 file

This is a top level include file that includes files full of macros that
assist CX16 programmers in handling 16 bit values in 65C02 assembly language.
It consists of a number of utility macros that are normally included in a
source file with the following line of code:

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
Test             | tst_16 | var &#8211; 0            | NZ    | tst_16.i65  | t65_tst_16.a65
Equal            | eql_16 | var = value              | Z     | eql_16.i65  | t65_eql_16.a65
Greater or Equal | gte_16 | var &ge; value           | NVC   | gte_16.i65  | t65_gte_16.i65
Compare          | cmp_16 | var &#8211; value        | NVZC  | cmp_16.i65  | t65_cmp_16?.i65 ?=[abcd]

The macros support these four addressing modes:

Mode | Syntax    | Description
-----|-----------|-----------------------------------
zp   | zp        | zero page
zx   | zp,x      | zero page indexed with X -- wip
zy   | zp,y      | zero page indexed with Y -- wip
abs  | abs       | absolute
abx  | abs,x     | absolute indexed with X -- wip
aby  | abs,y     | absolute indexed with Y -- wip
zpi  | (zp)      | zero page indirect
zpy  | {(zp),y}  | zero page indirect indexed with Y

*Note:* Some addressing modes contain characters that can confuse the macro
processor. To avoid this, these modes need to be enclosed in {braces}.

*Warning:* With the zpy addressing mode, the caller
is responsible for setting up the Y register. Further, a page wrap error will
occur if the Y register is set to $FF.

*Sub-macros:*  The above macros contain "parsers" that determine the addressing
mode in use. They are less capable than the main parser used by the ca65
assembler but do well enough most of the time. To make the parse work,
addressing modes except for zp and abs require that simple identifiers be used.
For example, these are OK:

    set_16 myvar,42          ; Simple identifier
    set_16 myvar+2,44        ; Allowed for zp addressing mode
    set_16 (myptr),46        ; Simple identifier
    set_16 {(myptr),y},46    ; Simple identifier

and these are not OK:

    set_16 ($F0),46          ; Not an identifier
    set_16 (myptr+2),46      ; Complex expression
    set_16 {(myptr+2),y},46  ; Complex expression

One way around this is to use a temporary assembly time variable to hold the
computed expression. This is demonstrated in the set_16 test code and is
duplicated here:

    zpvp2 = zpv+2            ; Compute a temporary variable.
    set_16 zpvp2,$FF00       ; Set up the pointer
    set_16 (zpvp2),$1234     ; The up the pointee
    lda $FF00                ; Verify the low byte.
    cmp #$34
    fail_ne 50
    lda $FF01                ; Verify the high byte.
    cmp #$12
    fail_ne 51

Note that the "extra" code is evaluated as the code is being assembled and
does not generate any extra machine language code or take up any execution
time (clock cycles).

For those cases where the use of such a variable is not desired, it is
possible to bypass the parser level and use the lower level macros directly.
The arguments to this level are just the labels or expressions without the
addressing mode syntax. For example:

Addressing Mode                   | High Level        | Low Level
----------------------------------|-------------------|------------
Zero page                         | var or expression | var or expression
Zero page indexed with X          | {pointer,x}       | pointer or expression
Zero page indexed with Y          | {pointer,y}       | pointer or expression
Absolute                          | var or expression | var or expression
Absolute indexed with X           | {pointer,x}       | pointer or expression
Absolute indexed with Y           | {pointer,y}       | pointer or expression
Zero page indirect                | (pointer)         | pointer or expression
Zero page indirect indexed with Y | {(pointer),y}     | pointer or expression

Here are those lower level macros:

Operation/Mode   | zp or abs   | zx or abx   | zy or aby   |zpi          | zpy
-----------------|:-----------:|:-----------:|:-----------:|:-----------:|:--------:
Initialize       | _set_var_16 | _set_vax_16 | _set_vay_16 | _set_zpp_16 | _set_zpy_16
Increment        | _inc_var_16 | wip         | wip         | _inc_zpp_16 | _inc_zpy_16
Decrement        | _dec_var_16 | wip         | wip         | _dec_zpp_16 | _dec_zpy_16
Add a step       | _adj_var_16 | wip         | wip         | _adj_zpp_16 | _adj_zpy_16
Test             | _tst_var_16 | wip         | wip         | _tst_zpp_16 | _tst_zpy_16
Equal            | _eql_var_16 | wip         | wip         | _eql_zpp_16 | _eql_zpy_16
Greater or Equal | _gte_var_16 | wip         | wip         | _gte_zpp_16 | _gte_zpy_16
Compare          | _cmp_var_16 | wip         | wip         | _cmp_zpp_16 | _cmp_zpy_16


Details about each of the macros follows:

### set_16

A macro to initialize a 16 bit variable in memory with a value.

*Declaration:*

    .macro set_16 var,value

*Parameters:*
* var - the 16 bit variable.
* value - a value used to initialize var.

*Notes:*
* Some modes are optimized for special case values like 0, $00xx, and $xx00.

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | Unless value is 0, the A register, Z and N flags.
zpi     | The A and Y registers, Z and N flags.
zpy     | The A register, Z and N flags.
zx, abx | Unless value is 0, the A register, Z and N flags.
zy, aby | The A register, Z and N flags.

*Example:*

    .zeropage                          ; Zero page variables.
    my_var: .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 my_var, 0                 ; Clear my_var.

*Example:*

    .zeropage                          ; Zero page variables.
    root: .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 root, root_array          ; Root points to the start of root_array.
      set_16 (root), $FFFF             ; Set the first value of the array.


*Example:*

    .zeropage                          ; Zero page variables.
    root: .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.
    .import rec_size                   ; and the size of its elements.

    .code
      ; stuff omitted.
      set_16 root, root_array          ; Set up the pointer to the start of the array.
      ; stuff omitted.
      ldy #rec_size
      set_16 {(root),y}, 0             ; Clear first word element of the array.

### inc_16

A macro to increment a 16 bit variable in memory.

*Declaration:*

    .macro inc_16 var

*Parameters:*
* var - the 16 bit variable.

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | The Z and N flags.
zpi     | The A and Y register, Z and N flags.
zpy     | The A register and the Z and N flags.

*Example:*

    .zeropage                          ; Zero page variables.
    my_var: .res  2

    .code
      ; stuff omitted.
      inc_16 my_var                    ; Step to the next.

*Example:*

    .zeropage                          ; Zero page variables.
    root: .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 root, root_array          ; Set up the pointer to the base of the array.
      ; stuff omitted.
      inc_16 (root)                    ; Increment the first element of the array.

*Example:*

    .zeropage                          ; Zero page variables.
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 root, root_array          ; Set up the pointer to the base of the array.
      ; stuff omitted.
      ldy #21*2
      inc_16 {(root),y}                ; Increment the twenty first element of the array.

### dec_16
Decrement a 16 bit variable in memory.

*Declaration:*

    .macro dec_16 var

*Parameters:*
* var - the name of a 16 bit variable.

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | The A register and the Z and N flags.
zpi     | The A and Y register, and the Z and N flags.
zpy     | The A register and the Z and N flags.

*Example:*

    .zeropage                          ; Zero page variables.
    my_var: .res  2

    .code
      ; stuff omitted.
      dec_16 my_var                    ; Step to the previous.

*Example:*

    .zeropage                          ; Zero page variables.
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 root,root_array           ; Set up the pointer to the base of the array.
      ; stuff omitted.
      dec_16 (root)                    ; Decrement the first element of the array.

*Example:*

    .zeropage
    root:   .res  2                    ; Zero page variables.

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 root, root_array          ; Set up the pointer to the base of the array.
      ; stuff omitted.
      ldy #(21-1)*2
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
zp, abs | The A register and the Z and N flags.
zpi     | The A and Y register, and the Z and N flags.
zpy     | The A register and the Z and N flags.


*Example:*

    .zeropage                          ; Zero page variables.
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.
    item_len = 10                      ; Each item in the array is 10 bytes long.

    .code
      ; stuff omitted.
      set_16 root, root_array          ; Set up the pointer to the base of the array.
      ; stuff omitted.
      adj_16 root, item_len            ; Step to the next item.

*Example:*

    .zeropage                          ; Zero page variables.
    pieces: .res  2                    ; Points to a chess piece

    .code
      ; stuff omitted.
      adj_16 (pieces), 10              ; Add 10 to the weight of this chess piece.

*Example:*

    .zeropage                          ; Zero page variables.
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 root, root_array          ; Set up the pointer to the base of the array.
      ; stuff omitted.
      ldy #(21-1)*2
      adj_16 {(root),y},10             ; Adjust the twenty first element of the array by 10.

### tst_16
Test a 16 bit variable in memory.

*Declaration:*

    .macro tst_16 var

*Parameters:*
* var - a 16 bit variable.

*Notes:*
* The test operation never has overflow conditions so the N flag is never
inverted. Thus the V flag is not needed.

*Returns:*
* The N and Z flags are set according to the value tested.

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | The A register.
zpi     | The A and Y registers.
zpy     | The A register.

*Example:*

    .zeropage                          ; Zero page variables.
    counter: .res  2

    .code
      ; stuff omitted.
      set_16 counter, 1535             ; Set up the loop counter.

    loop:
      ; Do really cool stuff (omitted).

      dec_16 counter                   ; Decrement the loop counter
      tst_16 counter                   ; Is is zero?
      bne loop                         ; If not, keep looping!

*Example:*

    .zeropage                          ; Zero page variables.
    health: .res 2                     ; A pointer into the health array.

    .code
      ; stuff omitted.
      tst_16 (health)                  ; Which side of the grass?
      bmi morte                        ; Health negative, dead.
      beq morte                        ; Health zero, dead.
      ; still alive                    ; Health greater than zero, alive.
      ; stuff omitted.

    morte:
      ; stuff omitted.

*Example:*

    .zeropage                          ; Zero page variables.
    health: .res 2                     ; A pointer into the health array.
    count:  .res 1                     ; A loop counter.

    .import creature_count            ; Import a reference to the number of creatures.

    .code
      ; stuff omitted.

      lda creature_count               ; Set up the creature count.
      sta count
      ldy #0                           ; Start from the start.

    health_loop:
      ; stuff omitted.
      tst_16 {(health),y}              ; Which side of the grass?
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

### eql_16
Compare a 16 bit variable in memory with a value to see if they are equal.

*Declaration:*

    .macro eql_16 var, value

*Parameters:*
* var - a 16 bit variable.
* value - an integer value to compare var with.

*Returns:*
* The Z flag is set if var equals value.

*Notes:*
* Optimized for special cases like values of 0, $00xx, $xx00.

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | The A register, C, V, and N flags.
zpi     | The A and Y registers, C, V, and N flags.
zpy     | The A register, C, V, and N flags.

*Example:*

    .zeropage                          ; Zero page variables.
    root:   .res  2

    .import root_array:absolute        ; Import a reference to an array in another file.
    item_count = 42                    ; There are 42 items.
    item_len   = 10                    ; Each item in the array is 10 bytes long.
    array_len  = item_count*item_len

    .code
      ; stuff omitted.
      set_16 root, root_array          ; Set up the pointer to the base of the array.
      ; stuff omitted.

    loop:
      ; Do amazing (omitted) things with the current entry.

      adj_16 root, item_len            ; Step to the next item.
      eql_16 root, root_array+array_len ; Are we at the end?
      bne loop

*Example:*

    .zeropage                          ; Zero page variables.
    pter: .res 2                       ; A pointer to some data.

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 pter, root_array          ; Set up the pointer to the base of the array.
      ; stuff omitted.

      eql_16 (pter), 42                ; Test current array element for the answer.
      bne no_answer
      ; stuff omitted.                 ; Found the answer. Process it,

    no_answer:
      ; stuff omitted.

*Example:*

    .zeropage                          ; Zero page variables.
    pter: .res 2                       ; A pointer to some data.
    cter: .res 1                       ; A loop counter

    .import root_array:absolute        ; Import a reference to an array in another file.
    .import root_size                  ; Import its size too.

    .code
      ; stuff omitted.

      ; Scour the array looking for answers!
      set_16 pter, root_array          ; Set up the pointer to the base of the array.
      ldy #0
      lda #root_size
      sta cter

    scour_loop:

      ; stuff omitted.

      eql_16 {(pter),y}, 42            ; Test current array element for the answer.
      bne no_answer

      ; stuff omitted.                 ; Found the answer. Process it.

    no_answer:

      iny
      iny
      dec cter
      bne scour_loop

### gte_16
Compare a 16 bit variable in memory with a value to see if it is greater or equal.

*Declaration:*

    .macro gte_16 var, value

*Parameters:*
* var - a 16 bit variable.
* value - an integer value to compare var with.

*Returns:*
* C is set if var >= value using unsigned comparison.
* (N xor V) is cleared if var >= value using signed comparison.

*Notes:*
* Optimized for special cases like values of $xx00.

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | The A register, and Z flag.
zpi     | The A and Y registers, and Z flag.
zpy     | The A register, and Z flag.

*Example:*

    .zeropage
    score: .res 2

    .code
      ; stuff omitted.

      ; Level completed, check for bonuses
    bonus_loop:
      gte_16 score, 1000               ; >= 1000 for a bonus
      bcc no_bonus

      adj_16 score, -1000              ; Remove 1000 points
      ; do other bonus things

      bra bonus_loop

    no_bonus:

*Example:*

    .zeropage
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 creature, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.

      gte_16 creature, 400             ; Test current creature for low health.
      bcs health_ok
      ; stuff omitted.                 ; The creature health < 400, handle it.

    health_ok:                         ; The creature health >= 400.
      ; stuff omitted.

*Example:*

    .zeropage
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.
    .import array_size                 ; and its size in words.

    .code
      ; stuff omitted.
      set_16 creature, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.

      ldy #0

    creature_loop:                     ; Loop through the creature array.
      gte_16 creature, 400             ; Test current creature for low health.
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

### cmp_16
Compare a 16 bit variable in memory with a value.

*Declaration:*

    .macro cmp_16 var, value

*Parameters:*
* var - a 16 bit variable.
* value - an integer value to compare var with.

*Returns:*
* The N, V, Z, and C flags are set.

*Notes:*
* Unlike the native _cmp_ instruction, the cmp_16 macro sets all the flags
needed to work with both unsigned and signed arguments.
* Optimized for special cases like values of $xx00.

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | The A register.
zpi     | The A and Y registers.
zpy     | The A register.

*Example:*

    .zeropage
    score: .res 2

    .code
      ; stuff omitted.

      ; Level completed, check score
      cmp_16 score, 1000              ; == 1000 for a bonus
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

*Example:*

    .zeropage
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 creature, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.

      cmp_16 creature, -400            ; Is the creature no longer resurrectable?

      bvs sign_flipped                 ; If overflow detected the N bit is flipped.
      bmi perma_dead                   ; If negative there's no coming back!
      bra still_alive
    sign_flipped:
      bpl perma_dead                   ; The sign is flipped so positive is negative.

    still_alive:
      ; stuff omitted.                 ; The creature health >= -400, handle it.

    perma_dead:                        ; The creature health < -400.
      ; stuff omitted.

*Example:*

    .zeropage
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.
    .import array_size                 ; and its size in words.

    .code
      ; stuff omitted.
      set_16 creature, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.

      ldy #0

    creature_loop:                     ; Loop through the creature array.
      cmp_16 creature, -400            ; Test current creature for low health.

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
