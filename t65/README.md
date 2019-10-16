# Unit Tests

This file describes the facilities in the cx16 repo for testing the code
herein. It also gives some guidance on creating tests for new repos. My
motto: *If it ain't tested, it ain't no good!*

This folder contains the unit tests for the CX16 repository. These consist of
65C02 assembly language files, which are identified by an ".a65" suffix.

To accomplish the task of executing these tests, parts of the cc65 "C"
compiler are employed. These are:

Name  | Description
------|-------------
ca65  | Assembler. Converts assembly source code to an object file.
ld65  | Linker. Brings object files together to create an executable file.
sim65 | Simulator. Runs an executable file by simulating a 6502 family CPU.

Note that the "C" compiler itself is not used at this time. However, don't
delete it because it may yet be of some use :-)

To install the cc65 compiler, take a look [here](https://cc65.github.io/) You
will also need to deal with a teensy glitch in the simulator's cfg file (see
below).

## Running the tests:

There are a number of ways to run these tests. These are:

### Ruby Gem

The test65 gem is a package of Ruby code that automates the task of running
the tests and also provides macros that simplify the task of writing those
tests.

Unlike most Ruby gems, it is not hosted on RubyGems.org. Instead it is to be
found on github.com is [this](https://github.com/PeterCamilleri/test65) repo.
To use this gem, you will need to first install Ruby. Help on this topic may
be found at [ruby-lang.org](https://www.ruby-lang.org/en/).

You should also have git installed, for so many reasons. If you are careful
enough to want to test your code, you probably want to have control over
changes to that code. Get git, sign up to github. Both are free.

To run the tests, go to the root folder of the repo and type:

    test65

for more details on what is going on, use:

    test65 -d

As I write this file, here is a typical test run:

    11 mysh>test65 -d
    Using path: C:\Sites\cx16\t65
    Processing 12 test file(s)
    C:/Sites/CX16/t65/t65_adj_16.a65
    C:/Sites/CX16/t65/t65_cmp_16a.a65
    C:/Sites/CX16/t65/t65_cmp_16b.a65
    C:/Sites/CX16/t65/t65_cmp_16c.a65
    C:/Sites/CX16/t65/t65_cmp_16d.a65
    C:/Sites/CX16/t65/t65_dec_16.a65
    C:/Sites/CX16/t65/t65_eql_16.a65
    C:/Sites/CX16/t65/t65_gte_16.a65
    C:/Sites/CX16/t65/t65_inc_16.a65
    C:/Sites/CX16/t65/t65_set_16.a65
    C:/Sites/CX16/t65/t65_template.a65
    C:/Sites/CX16/t65/t65_tst_16.a65
    OK: All tests passed.

### Command Line

OK, so maybe installing Ruby is not for you. So you can do all of this from the
command line. In order for the tests to run you will need to make one file from
the test65 Ruby gem available to be included. That file is:

    test65/asminc/test65.i65

You can either path to it explicitly on the command line, or add it to th
CA65_INC environment variable, or just drop a copy in your test folder. So
here is an example used to run a test:

    ca65 --target sim65c02 t65/t65_adj_16.a65 -o test.o
    ld65 --target sim65c02 --lib sim65c02.lib test.o -o test.out
    sim65 test.out
    echo Test status is %ERRORLEVEL%
    rm test.o test.out

Here's how it looks:

    mysh>set CA65_INC=C:/Sites/test65/asminc
    mysh>ca65 --target sim65c02 t65/t65_adj_16.a65 -o test.o
    mysh>ld65 --target sim65c02 --lib sim65c02.lib test.o -o test.out
    mysh>sim65 test.out
    mysh>echo Test status is %ERRORLEVEL%
    Test status is 0
    mysh>rm test.o test.out

### Write Your Own Script

Needless to say, the above is a lot of work, so feel free to automate using
your favorite scripting tools. If you are a true masochist, you might even try
to build this as a gnu make task. Go ahead and try and may *Gilbert Gottfried*
have mercy on your soul!

## Glitches

As shipped, the linker will be unable to generate executable files for the
various test programs. In the cc65/cfg folder you will find the file
"sim65c02.cfg". It contains the following definition of simulated memory:

    MEMORY {
        ZP:     file = "",               start = $0000, size = $001B;
        HEADER: file = %O,               start = $0000, size = $000C;
        MAIN:   file = %O, define = yes, start = $0200, size = $FDF0 - __STACKSIZE__;
    }

The problem here is the the zero page is defined as being a mere $1B or 27
byte long. This makes it impossible to define zero page variables in tests.
To correct this issue, change the entry to allow the proper 256 byte long
zero page:

    MEMORY {
        ZP:     file = "",               start = $0000, size = $0100;
        HEADER: file = %O,               start = $0000, size = $000C;
        MAIN:   file = %O, define = yes, start = $0200, size = $FDF0 - __STACKSIZE__;
    }

### More

Not totally sure about this, but the cc65 tools seem to want paths (or at
least the CA65_INC environment variable) to be specified with forward
slashes (/) and are unhappy with Windows style back slashes (\).

Unhappy:

    set CA65_INC=C:\Sites\test65\asminc

Happy:

    set CA65_INC=C:/Sites/test65/asminc

Well at least in my tests.