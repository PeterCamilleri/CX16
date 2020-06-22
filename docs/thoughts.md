# Topics in W65C02S Programming

## Contents

* [Introduction](#introduction)
* [Modular Programming](#modular-programming)
   * [What Goes Where?](#what-goes-where)

## Introduction

To start, I will admit that this project has more than its share of me
rambling on with my thoughts and opinions. In this section, I try to distil
the relevant lessons learned from my over 40 years experience in
programming.

Besides, this is my project! I get to speak here! If you want your voice
heard, create your own project! Or... Raise an issue in this project and
your thoughts and questions will be addressed. As the code of conduct
mentions, this is an open and inclusive project. All are welcome.

[Back to the Top](#topics-in-w65c02s-programming)

## Modular Programming

In many older languages, like early versions BASIC or assembly, code was
contained in a single source file. If the program got big, that single
source file got big too. In fact it got HUGE. Keeping ideas and concepts
clear was tricky, especially since comments ("rem" statements) consumed
precious memory space and processor cycles. Sharing code was difficult as
code libraries had to be "pasted" into programs manually and integrated
somehow. As a result, code libraries were rare.

Later languages included a linker to bring code from multiple sources and
libraries together. Languages included features to export and import various
attributes of the code. This allowed shared code. More importantly, it
allowed a large program, filled with complex ideas, to be broken down into
smaller chinks, with simpler, more easily understood ideas. Thankfully,
they also stripped out comments, allowing code to be clearly explained
without a any run-time penalty. The problem of writing _useful_ comments
still remains however.

Another benefit of modular design is that the connections in the code are
constrained to what is permitted. This helps to discourage "spaghetti"
code that is often so convoluted, it can be impossible to understand. Working
on such code is a pain, simply because it is hard to debug or enhance code
that is hard to understand. This principle goes by the name "Information
Hiding".

So how is this modularity to be accomplished? Most languages go at this by
dividing each bundle of code, let's call it a module, into two parts:

1. The code of the module itself, containing any variables and code. Some
of these will be private to the module. Stuff that no other module should
poke its nose into. And some will be accessible to other modules. We'll
call that public. I steal a term from Object Pascal and call this part the
implementation section.
2. This part tells other modules what code and data are on offer from this
module. That is the public part mentioned above. Only here, we do not define
this stuff, we only make it available. I steal another term from Object Pascal
and call this part the interface section. As sort of grey area, this part can
also include publicly accessible macros, as these do not generate any code or
data until they are expanded.

Now in earlier languages, these roles were handled by putting things in
separate files. It is this sort of modular programming that we examine here.
In particular, the file extension indicates which role a file fulfils. This
varied by language:

| Language  | Interface | Implementation |
|:---------:|:---------:|:--------------:|
| C         |   ".h"    |    ".c"        |
| cc65      |   ".h65"  |    ".c65"      |
| Assembler |   ".inc"  |    ".asm"      |
| ca65      |   ".i65"  |    ".a65"      |

[Back to the Top](#topics-in-w65c02s-programming)

Let's take a deeper dive into what must be accomplished:

* Interface is responsible for _declaring_ entities. That is, providing
enough information for the compiler (assembler) to generate code using the
resource but not the full definition of that resource. An example in C
is a function prototype. These are held in files that are "included" by
source files.
* Implementation is responsible for fully _defining_ entities. That is
providing all the information/code for that resource. An example in C is
a function. These file "include" the interface or include files.

The question may arise, why are include files not permitted to fully declare
stuff? The reason goes to the fact that as a sharing mechanism, they are
likely to be included by multiple modules in a project. Any declared items
would be declared multiples times and almost certainly result in cryptic
linker errors.

Yes, you _can_ use conditional compilation (assembly) to avoid multiple
declarations, but that would violate the concept of keeping things simple.
Do yourself a favour and avoid being too clever for your own good.

### What Goes Where?

Now that we have two kinds of files, the question arises: What things do I
put in each type of file? While C and Assembler provide the primitive
mechanisms needed for modular programming, they do not provide any help in
actually getting right. In my years as a programmer, a very common
mistake is putting the kind in the wrong places.

So let's review what goes where.

**ca65 - Assembler .i65 and .inc files.**

* _.import_ and _.importzp_ - These declare public symbols defined in this
module. When other modules include this file, they gain access to the symbols
imported.
*_.struct_ and _.endstruct_ - These declare structures, but do not actually
allocated any memory. Thus they may declare the contents of the structure.
* _.union_ and _.endunion_ - Like structures except with unions.
* _.macr_ and _.endmacro_ - These define macros but no declaration occurs
until the macro is expanded in some code. The include file allows macros to
be shared.
* _.enum_ - Is used to define groups of constants.

The naughty list contains a sampling of things that should not be in an
include file. In general if it lays down bytes, it does not belong here.
You can verify this by checking the .lst file see that no bytes are created
as in this snippet:

```
000005r 1                 .struct Point
000005r 1                   xcoord  .word
000005r 1                   ycoord  .word
000005r 1                 .endstruct
000005r 1
000005r 1  xx xx xx xx  foo: .tag Point
000009r 1
```
It can be seen that the _.struct_ emits no bytes but the _.tag_ emits four.

This is a summary of some of the excluded commands:

_.addr_, _.align_, _.asciiz_, _.bankbytes_, _.bss_, _.byt_, _.byte_,
_.code_, _.data_, _.dbyt_, _.dword_, _.export_, _.faraddr_, _.hibytes_,
_.include_, _.lobytes_, _.org_, _.proc_, _.pushseg_, _.res_, _.rodata_,
_.segment_, _.tag_, _.word_, and _.zeropage_.

I know this is a long list but it may not even be complete. To be certain,
check your ".lst" files to ensure that no bytes are being emitted into
the object file.

Of these, the exclusion of _.include_ is controversial. Including another
file in an include file can be useful when the module in question has many
parts, but it can make it very complicated to figure out what is actually
being included and where.

And again things are complicated because many of these can appear in a macro.
Some of the more esoteric commands are not covered here and are left as an
exercise for the reader sophisticated enough to need those commands.

[Back to the Top](#topics-in-w65c02s-programming)
