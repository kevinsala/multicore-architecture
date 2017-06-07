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
        if self.has_finished():
            return

        self.pc = self.model.step()
        if self.pc == 0:
            self.finished = True

    def count_cycles(self):
        if self.has_finished():
            return

        self.cycles = self.cycles + 1
        if self.cycles == self.max_cycles:
            raise TestFailure("Processor %d is in an infinite loop at PC 0x%08x" % (self.proc_id, self.pc))

    def reset_cycles(self):
        self.cycles = 1

    def check_dump(self):
        if self.has_finished():
            return

        if not self.first_dump:
            if self.model.check_dump("dump"):
                raise TestFailure("Processor %d register bank doesn't have the expected values" % self.proc_id)
        else:
            self.first_dump = False

    def commit(self):
        if self.has_finished():
            return

        self.model.commit()

    def check_pc(self, pc):
        if self.has_finished():
            return

        if self.pc != pc:
            raise TestFailure("Processor %d is at PC 0x%08x, whereas model is at PC 0x%08x" % (self.proc_id, pc, self.pc))


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
    model0 = ModelState(0, memory)
    model1 = ModelState(1, memory)

    # Init test
    dut.reset <= 1
    yield clk_rising
    yield clk_rising
    dut.reset <= 0
    yield clk_rising

    dut.debug_dump <= 1

    dump_count = 0
    while not (model0.has_finished() and model1.has_finished()):
        # Move simulation forward
        yield clk_rising

        # One instruction may take many cycles
        while dut.proc0.pc_out == 0 and dut.proc1.pc_out == 0:
            model0.count_cycles()
            model1.count_cycles()
            yield clk_rising

        proc0_pc = int(dut.proc0.pc_out)
        proc1_pc = int(dut.proc1.pc_out)

        if proc0_pc != 0:
            model0.reset_cycles()
            model0.check_pc(proc0_pc)
            dut._log.info("Processor 0 PC 0x%08x ok", proc0_pc)

            # Update model
            model0.step()

            # Check memory after the step is done, in case there is an eviction and memory gets out of sync
            model0.check_dump()

        if proc1_pc != 0:
            model1.reset_cycles()
            model1.check_pc(proc1_pc)
            dut._log.info("Processor 1 PC 0x%08x ok", proc1_pc)

            # Update model
            model1.step()

            # Check memory after the step is done, in case there is an eviction and memory gets out of sync
            model1.check_dump()

        if dump_count > 2:
            if memory.check_dump("dump"):
                raise TestFailure("Memory doesn't have the expected values")
        else:
            dump_count = dump_count + 1

        dut._log.info("Memory ok")
        memory.commit()

        if proc0_pc != 0:
            model0.commit()

        if proc1_pc != 0:
            model1.commit()

    dut._log.info("Test run successfully!")
