import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.result import TestFailure

def is_valid(signal):
	str_signal = str(signal)
	return not ("z" in str_signal or "Z" in str_signal or "u" in str_signal or "U" in str_signal)

def mem_line_to_str(signal):
	if is_valid(signal):
		return "0x%032x" % int(signal)
	else:
		return "0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

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

	# Init test
	dut.reset <= 1
	yield clk_rising
	yield clk_rising
	dut.reset <= 0
	yield clk_rising

	while True:
		raw_input("<Enter> to continue")

		while dut.ack_one_i_ARB == 0 and dut.ack_one_d_ARB == 0 and dut.ack_two_i_ARB == 0 and dut.ack_two_d_ARB == 0:
			yield clk_rising

		if dut.ack_one_i_ARB == 1:
			dut._log.info("P0, iCache has permission to use the bus")
		elif dut.ack_one_d_ARB == 1:
			dut._log.info("P0, dCache has permission to use the bus")
		elif dut.ack_two_i_ARB == 1:
			dut._log.info("P1, iCache has permission to use the bus")
		elif dut.ack_two_d_ARB == 1:
			dut._log.info("P1, dCache has permission to use the bus")

		while not is_valid(dut.cmd_MEM) or dut.cmd_MEM == 0:
			yield clk_rising

		cmd = int(dut.cmd_MEM)
		addr = hex(int(dut.addr_MEM))
		if cmd == 1:
			dut._log.info("Sent a GET petition on address " + addr)
		elif cmd == 2:
			data = mem_line_to_str(dut.data_MEM)
			dut._log.info("Sent a PUT petition on address " + addr)
			dut._log.info("Data: " + data)
		else:
			dut._log.info("Unknown petition (" + cmd + ") on address " + addr)

		old_data = dut.data_MEM
		while not is_valid(dut.done_MEM) or dut.done_MEM != 1:
			old_data = dut.data_MEM
			yield clk_rising

		old_data = mem_line_to_str(old_data)

		if cmd == 1:
			dut._log.info("Received data " + old_data)

		dut._log.info("Transaction finished")
