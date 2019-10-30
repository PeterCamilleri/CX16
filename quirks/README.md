# Quirks of the 65C02 CPU

The enhanced CMOS version of the 6502. called the 65C02, makes several
improvements. And yet it still has a number of not-so endearing design quirks
that can make the life of a programmer more difficult than it needs to be. The
purpose of this section of the library is to provide a map to help avoid
nasty problems and land mines.

Topic                 | Description
----------------------|-------------------
Being Negative        | The real story behind two's compliment arithmetic.
Playing Favorites     | The frustrating maze of instructions and addressing modes.
Missing Instructions  | Stuff that got left out.
Flag that Instruction | When instruction don't play fair with flags.
Tricky Tools          | When features become traps.

## Being Negative

OK so this is a quirk _not_ specific to the 6502, but shared by almost every
computer system ever made. It's two's complement arithmetic and how negative
numbers and subtraction work.

Now, I learned way back in high school that computers perform subtraction by
adding. To do so they use the following bit of algebra:

    (1)    A = B - C

    (2)    A = B + (-C)

So, for example subtracting three is the same as adding negative three.

OK, so how do you compute the negative of a number? The obvious way would be to
"flip" the sign bit, and while some very rare computers did it that way, it's
not how two's compliment arithmetic does it. And so it was that, also in high
school, I learned that to get the negative form of a number you flipped all the
bits and added one. In modern notation it looks like this:

    (3)    -X = (~X) + 1

Where ~X is a bit flipped version of X. I didn't know why this worked, I just
had grit my teeth and memorize it. Did I ever mention that I hate memorizing
stuff I don't understand?

More recently text books have been using a different approach. They've been
using the binary digit (bit) weighting of each position to show the difference
between unsigned and signed numbers:

    (Unsigned)     128  64  32  16  8  4  2  1

    (Signed)      -128  64  32  16  8  4  2  1

This showed how -128 would be 100000000 and -2 would be 11111110 because

    -128 + 64 + 32 + 16 + 8 + 4 + 2 is -2

See? Let me show you:

    78 mysh>= -128 + 64 + 32 + 16 + 8 + 4 + 2
    -2

The thing is, while this seems less like snake oil, I still didn't understand
_why_ it worked at the hardware level. At least until I began thinking about
it in terms of algebra again.

Let's start with two easily understood bits (no pun intended) of binary math
knowledge:

   (4) X + (~X) equals All Ones

   (5) All Ones + 1 equals 0

You can easily see these yourself. The compliment of any number replaces 0s
with 1s and 1s with 0s. This means that for every position being added, there
will be a 0 and 0 + 1 (and 1 + 0, addition is commutative) add up to 1
in any math system. Thus a result of all possible ones.

And a register full of ones will roll over to all zeros when a 1 is added to
it. OK so let's put this together and go for the prize:

    (6)    0 = X + (~X) + 1

Now subtract X from both sides of the equation:

    (7)    -X = (~X) + 1

And there it is. An algebraic proof of the two's compliment of a number.

OK so now we see the special connection to our hero. You see, the 6502, more
so than any other 8-bit chip has what you might call "naked" arithmetic. I say
this because it let's a lot of it's internals hang out for all to see. You
see in order to add data, you need to:

    clc       ; Clear the carry first
    adc #55   ; A = A + 55

This reflects the fact that the _adc_ is defined as:

<pre><code>(8)     A &larr; A + m + C</code></pre>

It's subtract where it gets interesting. Here we must use:

    sec       ; Set the carry first
    sbc #55   ; A = A - 55

Now the data sheet tries to perpetuate the lie that there is a subratction
circuit in there someplace, but the truth is _sbc_ is defined as:

<pre><code>(9)     A &larr; A + (~m) + C</code></pre>

With the _sec_ intstruction we can simplify this to:

<pre><code>(10)    A &larr; A + (~m) + 1</code></pre>

And there is the (~value) + 1 from the two's complement above.

Like I said earlier, every processor most of us will ever see, do subraction
this way, but most hide it by making the carry look optional or inverting the
carry when it is used in subtraction. Few express it as eloquently, and dare I
say, as nakedly as the 6502.

## Playing Favorites

wip

## Missing Instructions

wip

## Flag that Instruction

wip

## Tricky Tools

wip
