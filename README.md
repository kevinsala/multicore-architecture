# Inkel Pentwice processor
"Blocking is for cowards, but it always works" - Development Team, 2017

This repository contains the source code of a processor in VHDL, and other tools to ease the development. It was developed in the context of the UPC MIRI in the course Processor Architecture by Carlos Escuín, Marc Marí and Kevin Sala and later continued on the course Multicore Architecture by Adrià Aguilà, Marc Marí, Antoni Navarro and Kevin Sala.

To read about the architecture details, please head to the documentation:

## Tools
### Compilation
The script `compiler/compile.py` compiles an assembly file into binary code that can later be used in the processor. The output file `memory_boot` should be placed at the root of the project, in order to be read properly by the processor.

### Simulation
The utility `simulator/run_code.py` simulates the binary code passed as an argument as if it was run on an Inkel Pentwice processor

### Validation
It is also possible to validate the VHDL processor against the simulator.

The packages necessary to run this validator are:
 - GHDL
 - python-devel

To finish the installation get the cocotb testbench (on the project root folder):

    git clone https://github.com/potentialventures/cocotb

If everything is right, you could now go to the `test` directory and run `make`. You should be validating the processor!

#### Known issues
 - If you get the error `vpi_get: unknown property`, download and compile the latest version of GHDL from sources (https://github.com/tgingold/ghdl.git)

### Voyeur
To observe transactions that cross the bus, you need the same infrastructure described on "Validation".

To run, go to the `voyeur` directory and run `make`. You will be asked to press `<Enter>` before every transaction.
