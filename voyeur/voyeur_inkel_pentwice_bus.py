import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.result import TestFailure

def is_valid(signal):
	str_signal = str(signal)

	valid = False
	for c in str_signal:
		if c != "z" and c != "Z" and c != "u" and c != "U":
			valid = True
			break

	return valid

def mem_line_to_str(signal):
	str_signal = str(signal)

	if is_valid(signal):
		str_signal = str_signal.replace("z", "0")
		str_signal = str_signal.replace("Z", "0")
		str_signal = str_signal.replace("u", "0")
		str_signal = str_signal.replace("U", "0")

		return "0x%032x" % int(str_signal, 2)
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

		while dut.ack_one_i_ARB == 0 and dut.ack_one_d_ARB == 0 and dut.ack_two_i_ARB == 0 and dut.ack_two_d_ARB == 0 and dut.ack_llc_ARB == 0:
			yield clk_rising

		cycles = 0

		if dut.ack_one_i_ARB == 1:
			dut._log.info("P0, iCache has permission to use the bus")
		elif dut.ack_one_d_ARB == 1:
			dut._log.info("P0, dCache has permission to use the bus")
		elif dut.ack_two_i_ARB == 1:
			dut._log.info("P1, iCache has permission to use the bus")
		elif dut.ack_two_d_ARB == 1:
			dut._log.info("P1, dCache has permission to use the bus")
		elif dut.ack_llc_ARB == 1:
			dut._log.info("LLC has permission to use the bus")

		while not is_valid(dut.cmd_BUS) or dut.cmd_BUS == 0:
			yield clk_rising
			cycles = cycles + 1

		cmd = int(dut.cmd_BUS)
		addr = hex(int(dut.addr_BUS))
		if cmd == 1:
			dut._log.info("Sent a GET petition on address " + addr)
		elif cmd == 2:
			data = mem_line_to_str(dut.data_BUS)
			dut._log.info("Sent a PUT petition on address " + addr)
			dut._log.info("Data: " + data)
		elif cmd == 3:
			data = mem_line_to_str(dut.data_BUS)
			dut._log.info("Sent a GET_RO petition on address " + addr)
		else:
			dut._log.info("Unknown petition (" + str(cmd) + ") on address " + addr)

		while not is_valid(dut.done_BUS) or dut.done_BUS != 1:
			yield clk_rising
			cycles = cycles + 1

		old_data = mem_line_to_str(dut.data_BUS)

		if cmd == 1 or cmd == 3:
			dut._log.info("Received data " + old_data)

		yield clk_rising
		cycles = cycles + 1

		dut._log.info("Transaction finished in %d cycles" % cycles)
