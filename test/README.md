# Inkel Pentiun processor testbench

## Simulator
The utility `run_code.py` simulates the binary code passed as an argument as if it was run on an Inkel Pentiun processor

## Validator
It is also possible to validate the VHDL processor against the simulator.

The packages necessary to run this validator are:
 - GHDL
 - python-devel

To finish the installation go to multicore-architecture/test and get the cocotb testbench:

    git clone https://github.com/potentialventures/cocotb

If everything is right, you could now run `make` and you should be validating the processor!

### Known issues
 - If you get the error `vpi_get: unknown property`, download and compile the latest version of GHDL from sources (https://github.com/tgingold/ghdl.git)

 - Sometimes, after updating `memory_boot`, the validator fails (it detects errors in memory where the instructions are loaded). Simply run again the validator and it will work.
