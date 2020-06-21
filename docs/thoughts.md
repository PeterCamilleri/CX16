# Topics in W65C02S Programming

## Contents

* [Introduction](#introduction)
* [Modular Programming](#modular-programming)

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
precious memory space. Sharing code was difficult as code libraries had to
be "pasted" into programs manually and integrated somehow. As a result,
code libraries were rare beyond routines stored in system ROM that were
application accessible.

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
implementation.
2. This part tells other modules what code and data are on offer from this
module. That is the public part mentioned above. Only here, we do not define
this stuff, we only make it available. I steal another term from Object Pascal
and call this part the interface. As sort of grey area, this part can also
include publicly accessible macros, as these do not generate any code or data
until they are expanded.

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

wip

[Back to the Top](#topics-in-w65c02s-programming)
