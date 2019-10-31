# Playing Favorites

One of the legendary quirks of the 65C02 processor is the maddening way that
addressing modes are available to the various instructions. In my own coding
I have had to jump through inefficient coding hoops when the instruction I
need to use is not available with the addressing mode I also need. I mean,
what is the point of all these sophisticated addressing modes when you can't
count on them when you need them?

To be clear, not all instructions are candidates for a lot of addressing
modes. Many instructions have specific inherent or internally defined data
that they deal with. In this discussion, we need to focus those instructions
that interact with data in memory. Secondly, some addressing modes are used
in specific domains and not applicable elsewhere.

However, even with these restriction, things are still a mess. Well the cause
of this chaos is the fact that the 6502 architecture has a three level system
of support for instructions and addressing modes:

Caste                     | Favored Modes  | Accepted Modes   | Fringe Modes
--------------------------|----------------|------------------|---------------
**Favored Instructions**  | Solid Support  | Get's these too  | Nope
**Accepted Instructions** | Get's these    | Nope             | Nope
**Fringe Instructions**   | Some?          | Some?            | Some?

So how do we begin to unravel this architectural caste system? Let's start
with the popular kids first.

## Favored Instructions

The 65C02 has eight favored data manipulation instructions. These are:

M/I                    | lda    | sta    | adc    |sbc     | and    | ora    | eor    | cmp    |
-----------------------|:------:|:------:|:------:|:------:|:------:|:------:|:------:|:------:|
Immediate              |&#x2714;|        |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
Absolute               |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
Direct Page (DP)       |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
Absolute Indexed,X     |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
Absolute Indexed,Y     |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
DP Indirect            |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
DP Indexed, X          |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
DP Indexed Indirect, X |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
DP Indirect Indexed, Y |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|

It should be noted that with the exceptions of _lda_ and _sta_ all of these
are dyadic or two operand instructions. In general they take the form:

<pre><code>A &larr; A &#60;operator&#62; m</code></pre>

In fact, in this whole array of 72 instructions and modes, there is only one
anomaly. You can't use _sta_ with immediate data. In this one case, the
exception makes good sense. You cannot store data into a literal constant
value.

## Favored Addressing Modes

The 65C02 has four and a half most favored addressing modes. These are
addressing modes that can almost be counted on to be there when you need
them. Almost. In addition to the favored instructions, these modes work
with these additional instructions:

M/I                    | asl    | bit    | dec    | inc    | lsr    | rol    | ror    | stz    |
-----------------------|:------:|:------:|:------:|:------:|:------:|:------:|:------:|:------:|
Accumulator            |&#x2714;|        |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|        |
Immediate              |        |&#x2714;|        |        |        |        |        |        |
Absolute               |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
Direct Page (DP)       |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
Absolute Indexed,X     |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
DP Indexed, X          |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|

Most of these are monadic instructions that do their work on a single operand.
They take the form:

<pre><code>m &larr; &#60;operator&#62; m</code></pre>

There are two exceptions to this orderly group:

* The _bit_ instruction which is an unloved dyadic instruction,
the bit-wise equivalent to _cmp_. As the only dyadic in the whole bunch it is
the only case that makes sense to have immediate mode.
* The _stz_ which just stores a zero and is annoyingly missing Accumulator
mode. It would have save a byte.

Note: Since it does not address memory, Accumulator is not technically an
addressing mode, but it is listed here for completeness.

## Mere Acceptance

Now, we've seen favored instructions and addressing modes, but what of those
that are less favored. They are sort of in the above two tables. The
instructions listed in the favored addressing modes table are the less
favored instructions, and the modes present in the first table but absent
from the second are those less favored addressing modes. As the "B" team
they deserve a table of their own:

 M/I                   | asl    | bit    | dec    | inc    | lsr    | rol    | ror    | stz    |
-----------------------|:------:|:------:|:------:|:------:|:------:|:------:|:------:|:------:|
Absolute Indexed,Y     |        |        |        |        |        |        |        |        |
DP Indirect            |        |        |        |        |        |        |        |        |
DP Indexed Indirect, X |        |        |        |        |        |        |        |        |
DP Indirect Indexed, Y |        |        |        |        |        |        |        |        |

No you're not looking at an incomplete table. Not one of those instructions
or modes work together. Sad really.

## The Fringe

Up till now, we've been looking at instructions and addressing modes with
reasonable, if not great, levels of support. It's time now to look into the
much less than reasonable regions of the 65C02. Since this area is so chaotic,
both instructions and addressing modes will be presented in one table.
Here it is in a its horrible glory:

M/I                         | cpx    | cpy    | jmp    | ldx    | ldy    | stx    | sty    | trb    | tsb
----------------------------|:------:|:------:|:------:|:------:|:------:|:------:|:------:|:------:|:------:|
Immediate                   |&#x2714;|&#x2714;|        |&#x2714;|&#x2714;|&#x2714;|&#x2714;|        |        |
Absolute                    |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
Absolute Indexed, X         |        |        |        |        |&#x2714;|        |&#x2714;|        |        |
Absolute Indexed, Y         |        |        |        |&#x2714;|        |&#x2714;|        |        |        |
Direct Page (DP)            |&#x2714;|&#x2714;|        |&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|&#x2714;|
DP Indexed, X               |        |        |        |        |&#x2714;|        |&#x2714;|        |        |
DP Indexed, Y               |        |        |        |&#x2714;|        |&#x2714;|        |        |        |
Absolute Indirect           |        |        |&#x2714;|        |        |        |        |        |        |
Absolute Indexed, X Indirect|        |        |&#x2714;|        |        |        |        |        |        |
