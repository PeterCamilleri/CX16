# The assist_16.i65 file

## Contents

* [Overview](#overview)
   * [A Deeper Dive](./assist_16_details.md)
* [Reference](#reference)
   * [adj_16](#adj_16)
   * [cmp_16](#cmp_16)
   * [dec_16](#dec_16)
   * [eql_16](#eql_16)
   * [gte_16](#gte_16)
   * [inc_16](#inc_16)
   * [set_16](#set_16)
   * [tst_16](#tst_16)

## Overview

The assist_16.i65 file contains macros that assist CX16 programmers in
handling 16 bit values in 65C02 assembly language. It consists of a number of
utility macros that are normally included in a source file with the following
line of code:

    .include "assist_16.i65"

Note that none of the code in this file has any dependency on any ROMs, entry
points, or other software in the system. It can be used with any 65C02 system.

This table lists the operations provided by the assist_16 package.

Operation        | Macro  | Summary                  | Flags |
-----------------|--------|--------------------------|-------|
Add a step       | adj_16 | var &larr; var + step    |       |
Compare          | cmp_16 | var &#8211; value        | NVZC  |
Decrement        | dec_16 | var &larr; var &#8211; 1 |       |
Equal            | eql_16 | var = value              | Z     |
Greater or Equal | gte_16 | var &ge; value           | NVC   |
Increment        | inc_16 | var &larr; var + 1       |       |
Initialize       | set_16 | var &larr; value         |       |
Test             | tst_16 | var &#8211; 0            | NZ    |

The macros support these eight addressing modes:

Mode | Syntax    | Description
-----|-----------|-----------------------------------
zp   | zp        | zero page
zx   | {zp,x}    | zero page indexed with X
zy   | {zp,y}    | zero page indexed with Y
abs  | abs       | absolute
abx  | {abs,x}   | absolute indexed with X
aby  | {abs,y}   | absolute indexed with Y
zpi  | (zp)      | zero page indirect
zpy  | {(zp),y}  | zero page indirect indexed with Y

*Note:* Some addressing modes contain characters that can confuse the macro
processor. To avoid this, these modes need to be enclosed in {braces} as
shown in the table above.

*Warning:* With the zpy addressing mode, the caller is responsible for
setting up the Y register. Further, a page wrap error will occur if the Y
register is set to $FF.

Further details on the internals are contained in the
[**deeper dive**](./assist_16_details.md) file.

## Reference:

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
zp, abs | The A register and the C, V, Z, and N flags.
zpi     | The A and Y register, and the C, V, Z, and N flags.
zpy     | The A register and the C, V, Z, and N flags.
zx, abx | The A register and the C, V, Z, and N flags.
zy, aby | The A register and the C, V, Z, and N flags.

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
needed to work with both unsigned and signed arguments. This also means that
the V flag needs to be considered for signed data. You can do this explicitly
as shown in the example of you can use the signed composite branches found
in the branches portion of this collection.
* Optimized for special cases like values of $xx00.

*Clobbers:*

Mode    | Clobbers
--------|---------
zp, abs | The A register.
zpi     | The A and Y registers.
zpy     | The A register.
zx, abx | The A register.
zy, aby | The A register.

*Example:*

    .zeropage
    score: .res 2                     ; Zero page variables.

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

    .zeropage                          ; Zero page variables.
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 creature, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.

      cmp_16 (creature), -400          ; Is the creature no longer resurrectable?

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

    .zeropage                          ; Zero page variables.
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.
    .import array_size                 ; and its size in words.

    .code
      ; stuff omitted.
      set_16 creature, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.

      ldy #0

    creature_loop:                     ; Loop through the creature array.
      cmp_16 {(creature),y}, -400      ; Test current creature for low health.

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
zx, abx | The A register and the Z and N flags.
zy, aby | The A register and the Z and N flags.

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
zx, abx | The A register, C, V, and N flags.
zy, aby | The A register, C, V, and N flags.

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
Compare an unsigned 16 bit variable in memory with a value to see if it is
greater or equal to a constant value.

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
zx, abx | The A register, and Z flag.
zy, aby | The A register, and Z flag.

*Example:*

    .zeropage
    score: .res 2                      ; Zero page variables.

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

    .zeropage                          ; Zero page variables.
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.

    .code
      ; stuff omitted.
      set_16 creature, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.

      gte_16 (creature), 400           ; Test current creature for low health.
      bcs health_ok
      ; stuff omitted.                 ; The creature health < 400, handle it.

    health_ok:                         ; The creature health >= 400.
      ; stuff omitted.

*Example:*

    .zeropage                          ; Zero page variables.
    creature: .res 2                   ; A pointer to some creature data.

    .import root_array:absolute        ; Import a reference to an array in another file.
    .import array_size                 ; and its size in words.

    .code
      ; stuff omitted.
      set_16 creature, root_array      ; Set up the pointer to the base of the array.
      ; stuff omitted.

      ldy #0

    creature_loop:                     ; Loop through the creature array.
      gte_16 {(creature),y}, 400       ; Test current creature for low health.
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
zx, abx | The Z and N flags.
zy, aby | The Z and N flags.

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
zx, abx | The A register.
zy, aby | The A register.

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
