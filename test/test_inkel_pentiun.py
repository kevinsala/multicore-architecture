import processor_model
import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.result import TestFailure

@cocotb.coroutine
def clock_gen(signal):
    while True:
        signal <= 0
        yield Timer(1)
        signal <= 1
        yield Timer(1)

@cocotb.test()
def init_test(dut):
    cocotb.fork(clock_gen(dut.clk))
    clkedge = RisingEdge(dut.clk)
    model = processor_model.InkelPentiun("../memory_boot")

    # Init test
    dut.reset <= 1
    yield clkedge
    yield clkedge
    dut.reset <= 0
    yield clkedge

    while True:
        mod_pc = model.step()
        if mod_pc == 0:
            break

        yield clkedge
        count = 1
        while count < 15 and dut.pc_out == 0:
            yield clkedge

        if count == 15:
            raise TestFailure("Processor is in an infinite loop at PC 0x%08x" % mod_pc)

        proc_pc = dut.pc_out
        if mod_pc != proc_pc:
            raise TestFailure("Processor is at PC 0x%08x, whereas model is at PC 0x%08x" % (proc_pc, mod_pc))
        else:
            dut._log.info("PC 0x%08x ok", proc_pc)

    dut._log.info("Test run successfully, checking memory")
