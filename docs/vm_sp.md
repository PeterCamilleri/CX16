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
3. Getting return values back from functions.
4. Allocation of local variables.

[Back to the Top](#implementing-vm-stacks)
