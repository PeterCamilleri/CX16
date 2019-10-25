# Tools

This section contains information and discussions about the tools used in this
repository.

## cc65

The initial work on the CX16 project will be done with the [cc65](https://cc65.github.io/)
tool chain. There are many reasons that I have made this my choice. The
assembler (ca65) supports macros, the 65C02 (among others) and it comes with
a linker (ld65) which breaks the tyranny of absolute object code and the sim65
simulator that allows me to test my code easily. Besides all of that, it's
open-sourced and free!

See the t65 folder's readme file for more information on testing the code as
well as the steps that need to be taken to get around a couple of glitches I
encountered along the way.

The tool chain may change at some point. In any event I will may provide some
helpful (?) instructions on installing what ever tool chain I settle on, when
I settle on it.

## Notepad++

Another, entirely optional, component of the toolset is the [Notepad++](https://notepad-plus-plus.org/)
editor. This program supports multi-tab edit with syntax highlighting. It also
allows effortless handling of the various line endings used in Windows, Linux,
Unix, and the Mac. It's also easy-to-use and free! You may prefer another
editor and that's OK. Go with what makes you happy.

_todo_ Create a configuration style for the cc65 assembly language so that it
looks nice while being edited.

## File Names

To avoid endless grief and suffering, choose file names that consist of lower
case letters and words joined by underscore "_" characters. In particular do
not use file names containing embedded spaces or punctuation.

Follow these rules: _Happiness_; Break these rules: _Misery_

It's all up to you!

## File Extensions

Initially, the following file extensions are used in this repository:

Extension | Use
----------|----------------------------------------------------
.a65      | Assembler Source File
.i65      | Assembler Include File
.md       | Documentation using GitHub markdown formatting.
others    | To be determined.

To clarify, assembler source files do the actual work of creating the program.
That is, they contain the variables and code that make up the actual program.
Include files are used to define the entry points, symbols, and macros that
are needed for one assembler source file to utilize another one. They should
**never** generate code or variables. Why? An include file may be included by
many assembler files. Any created entities (code or variables) will be created
multiple times leading to a linker error or "unexpected" results when run.

## Using include files

A very useful feature of the assembler is the ability to include files. When
this is done, the text if the included file is essentially read into the
current file at the point of inclusion. This allow the easy use of definitions,
macros, and other resources from other sources.

To use include files they need to use the include statement:

    .include "my_file.i65"

The include statement can also include pathing information to allow the
assembler to find the file. Note the use of forward slash characters even
though this example was run under Windows which normally uses the back-slash
character for file pathing.

    .include "../utilities/assist_16/set_16.i65"

This example uses a relative path. The use of absolute paths are discouraged
since this makes it far more difficult to build the code an another machine.

To actually perform the include step, the assembler program must first be able
to locate that file. There are a number of places that include files may exist
in order to make this work. They are:

* In the same folder as the file(s) that use it.
* Via the path specified in the include statement.
* In a folder named in a "-I <folder>" option on the command line.
* In a folder listed in the environment variable CA65_INC.
* In a folder named "asminc" of the folder defined in the environment variable
CC65_HOME.
