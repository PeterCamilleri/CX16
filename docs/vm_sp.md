# Implementing VM Stacks

## Contents

* [Introduction](#introduction)

## Introduction

This section will focus on the options available for providing stack support.
This means test cases will be designed with the goal of making the best use
of the limited resources of the W65C02S. Studies will note the resources of
memory and clock cycles used by each design.

To compare the designs, the following uses for stacks are examined:

1. Holding subroutine return addresses.
2. Passing parameters to a function or procedure.
3. Accessing parameters to this function or procedure.
4. Setting the return value for this function.
5. Getting return values back from functions.
6. Allocation of local variables.
7. Accessing those local variables.

[Back to the Top](#implementing-vm-stacks)

## Stack Options

In this section, let's take a look at the sorts of stacks available for use.
In very general terms these fall into one of two camps:

* Small stacks of 256 bytes or less.
* Larger stacks with no 256 byte size limit.

[Back to the Top](#implementing-vm-stacks)
