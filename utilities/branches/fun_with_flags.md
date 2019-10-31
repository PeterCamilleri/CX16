# Fun with Flags

This installment of Fun with Flags is _not_ presented by Dr Sheldon Cooper.

In order to get a better understanding of branch instructions and macros based
on one or more flags, it is very useful to understand the flags themselves. In
particular, this section will examine how flags are used to convey the results
of comparing two numbers.

The P register contains eight bits, four of which are involved in the
comparison process. These flags (in bold) are:

Bit # | Name  | Description
:----:|:-----:|--------------
**0** | **C** | **The carry/borrow bit.**
**1** | **Z** | **The zero bit.**
2     | I     | The interrupt disable bit.
3     | D     | The decimal mode bit.
4     | B     | The break interrupt bit.
5     | 1     | Always 1.
**6** | **V** | **The overflow bit.**
**7** | **N** | **The negative bit.**

Now a lot of instructions and even inputs to the CPU can have an affect on
these flag bits. However, we are interested in those instructions that can be
used to compare data. That is those instructions that perform subtraction.
These are the _sbc_ and _cmp_ instructions which are subtract with carry and
compare respectively.

So let's take a closer look at the four bits of data that are used make
decisions about data:

### The Carry Flag:

Despite its many other uses, the carry flag is named after the task of keeping
track of the _carry_ between bytes in multi-byte addition. A _high_ (1) state
indicates that a carry has been generated by the addition. This is why, before
adding numbers, one usually uses the clc instruction since there is no
previous carry and the 6502 lacks an instruction to add without carry.

In spite of this, its use in subtraction is the exact opposite. In
subtraction, this flag is used to represent a _borrow_ condition. To make
things more interesting, a borrow exists when this flag is in the _low_ (0)
state. This is why, before subtracting numbers, one usually uses the _sec_
instruction to set the carry (and thus clear the borrow). This reflects the
fact that  there is no previous borrow and again, the quirky 6502 processor
lacks an instruction to subtract without borrow.

The _cmp_ instruction is special because it sets up the no borrow condition on
its own without the need for extra code. Further, since it does not change the
value of the A register, multiple values can be tested with ease. So _cmp_ is
better than _sbc_ right? Not always, keep reading.

The borrow bit is used with unsigned values. After a comparison instruction, a
borrow (which is carry clear) condition represents a less-than state while a
no borrow (which is carry set) represents a greater-than-or-equal-to state.


### The Zero Flag:

If the result of an operation is zero, this flag is set. If the result is not
zero, this flag is cleared. After a comparison operation, a zero result (Z set)
means the two values were equal. An non-zero result means that they were not
equal. This is reflected in the branch operations that use this flag, namely
_beq_ and _bne_ for branch if equal and branch if not-equal respectively.

Unlike the other flags described here, this holds true whether that data
involved are signed or unsigned.

### The Overflow Flag:

The Overflow (V) flag is one of the most confusing aspects of 65C02
programming but its role in comparison is really not all that complex.

The V flag, together with the N flag are used to compare signed data
quantities. So what does it mean? To keep things simple, when the V flag is
set, the N flag is flipped. That's all really. How this is used is covered
in the next section.

Branches on the V flag are simply _bvc_ to branch when it is 0 and _bvs_ to do
so when it is 1.

And now for some truly evil inconsistency. The _cmp_ instruction does not set
the V flag and so it cannot be used for most signed comparisons. You must use
the _sbc_ instruction instead. On the bright side, the cmp_16 macro that is
part of the assist_16 folder of utilities sets _all_ of the required flags.

So when is it OK to use the _cmp_ instruction with signed data? Well there
are two areas where this will work:

* When checking for equal (=) or not equal (&ne;) only the Z flag is used and
that works correctly with _cmp_.
* When the numbers will not overflow. If the values are restricted to the
range -64 through 63 there will be no overflow to be lost and the _cmp_ will
yield correct results. I do not recommend taking advantage of this loop hole
since the overflow flag is not cleared either. This means that if conventional
(N+V) signed comparison logic is used, incorrect operation may still occur.

### The Negative Flag:

The The Negative (N) flag is used to signal that the result of an operation
are negative. Clearly this flag is used with signed data. Things get
interesting because the results of the subtraction may not be able to fit
in 8-bits. This is where the V flag augments the N flag to allow such cases
to still be handled.

Branches on the N flag are _bpl_ to branch when it is 0 (normally positive or
plus) and _bmi_ (normally negative or minus) to do so when it is 1.

The following table shows how the N and V bits are interpreted after executing
an _sbc_ instruction:

 N   | V   | Meaning        | Interpretation |
:---:|:---:|:--------------:|:--------------:|
 0   | 0   | Positive       | A &ge; value   |
 1   | 0   | Negative       | A < value      |
 0   | 1   | False Positive | A < value      |
 1   | 1   | False Negative | A &ge; value   |

## Putting it All Together:

So lets see how we can put these flags to work.

First for unsigned data:

  C  |  Z  | Meaning      |    <     |   &le;   |    =     |   &ne;   |   &ge;   |    >     |
:---:|:---:|:------------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|
  0  |  X  | A < value    | &#x2714; | &#x2714; |          |          |          |          |
  1  |  X  | A &ge; value |          |          |          |          | &#x2714; |          |
  1  |  0  | A > value    |          |          |          |          |          | &#x2714; |
  X  |  0  | A &ne; value |          |          |          | &#x2714; |          |          |
  X  |  1  | A = value    |          | &#x2714; | &#x2714; |          |          |          |

And for signed data:

  N  |  V  |  Z  | Meaning       |    <     |  &le;    |    =     |   &ne;   |  &ge;    |    >     |
:---:|:---:|:---:|:-------------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|
  0  |  0  |  X  | A &ge; value  |          |          |          |          | &#x2714; |          |
  0  |  0  |  0  | A > value     |          |          |          |          |          | &#x2714; |
  1  |  0  |  X  | A < value     |          | &#x2714; |          |          |          |          |
  1  |  0  |  0  | A < value     | &#x2714; |          |          |          |          |          |
  0  |  1  |  X  | A < value     |          | &#x2714; |          |          |          |          |
  0  |  1  |  0  | A < value     | &#x2714; |          |          |          |          |          |
  1  |  1  |  X  | A &ge; value  |          |          |          |          | &#x2714; |          |
  1  |  1  |  0  | A > value     |          |          |          |          |          | &#x2714; |
  X  |  X  |  0  | A &ne; value  |          |          |          | &#x2714; |          |          |
  X  |  X  |  1  | A = value     |          | &#x2714; | &#x2714; |          |          |          |

The notation "X" is used for those times that a flag is ignored.