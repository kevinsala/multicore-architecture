# Inkel Pentiun processor
"Blocking is for cowards, but it always works" - Development Team, 2017

## Simulation
The utility `simulator/run_code.py` simulates the binary code passed as an argument as if it was run on an Inkel Pentiun processor

## Validation
It is also possible to validate the VHDL processor against the simulator.

The packages necessary to run this validator are:
 - GHDL
 - python-devel

To finish the installation get the cocotb testbench (on the project root folder):

    git clone https://github.com/potentialventures/cocotb

If everything is right, you could now go to the `test` directory and run `make`. You should be validating the processor!

### Known issues
 - If you get the error `vpi_get: unknown property`, download and compile the latest version of GHDL from sources (https://github.com/tgingold/ghdl.git)
