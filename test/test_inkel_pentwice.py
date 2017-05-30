import sys
import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.result import TestFailure

sys.path.append("../../simulator")
import processor_model
import memory_model

class ModelState:
    max_cycles = 30

    def __init__(self, proc_id, memory):
        self.proc_id = proc_id
        self.model = processor_model.InkelPentiun(self.proc_id, memory)
        memory.add_processor(self.model)
        self.finished = False;
        self.pc = 0x1000
        self.first_dump = True
        self.reset_cycles()

    def has_finished(self):
        return self.finished

    def step(self):
        self.pc = self.model.step()
        if self.pc == 0:
            self.finished = True

    def count_cycles(self):
        self.cycles = self.cycles + 1
        if self.cycles == self.max_cycles:
            raise TestFailure("Processor is in an infinite loop at PC 0x%08x" % self.pc)

    def reset_cycles(self):
        self.cycles = 1

    def check_dump(self):
        if not self.first_dump:
            if self.model.check_dump("dump"):
                raise TestFailure("Processor register bank doesn't have the expected values")
        else:
            self.first_dump = False

    def commit(self):
        self.model.commit()

    def check_pc(self, pc):
        if self.pc != pc:
            raise TestFailure("Processor is at PC 0x%08x, whereas model is at PC 0x%08x" % (pc, self.pc))


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
    clk_rising = RisingEdge(dut.clk)
    memory = memory_model.MemoryModel("memory_boot")
    model = ModelState(0, memory)

    # Init test
    dut.reset <= 1
    yield clk_rising
    yield clk_rising
    dut.reset <= 0
    yield clk_rising

    dut.debug_dump <= 1

    dump_count = 0
    while not model.has_finished():
        # Move simulation forward
        yield clk_rising

        # One instruction may take many cycles
        while dut.proc.pc_out == 0:
            yield clk_rising
            model.count_cycles()

        model.reset_cycles()

        cur_pc = int(dut.proc.pc_out)
        model.check_pc(cur_pc)
        dut._log.info("Processor PC 0x%08x ok", cur_pc)

        # Update model
        model.step()

        # Check memory after the step is done, in case there is an eviction and memory gets out of sync
        model.check_dump()
        if dump_count > 2:
            if memory.check_dump("dump"):
                raise TestFailure("Memory doesn't have the expected values")
        else:
            dump_count = dump_count + 1

        dut._log.info("Processor PC 0x%08x (memory) ok" % cur_pc)

        model.commit()
        memory.commit()

    dut._log.info("Test run successfully!")
