# The VM Instruction Decoder

[Back to Virtual Machines](./virtual_machines.md)

## Contents

* [Introduction](#introduction)

## Introduction

Perhaps the most overlooked aspect of most processors is the instruction
decoder. It does not even have any programmer visible registers and is
usually a nondescript block in high level diagrams of the CPU, if it even
appears at all.

And yes, in our virtual machine designs instruction decoding has a huge
impact, not only on the instructions we implement but also the addressing
modes available. Providing these adequately and efficiently is quite a
challenge.

Thus, this is the point of focus of this document.
