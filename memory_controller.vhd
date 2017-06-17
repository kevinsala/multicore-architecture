LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_textio.ALL;
USE work.utils.ALL;

ENTITY memory_controller IS
	PORT (
		clk          : IN STD_LOGIC;
		reset        : IN STD_LOGIC;
		cmd          : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		done         : OUT STD_LOGIC;
		addr         : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data         : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0);
		mem_req      : OUT STD_LOGIC;
		mem_we       : OUT STD_LOGIC;
		mem_done     : IN STD_LOGIC;
		mem_addr     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_in  : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
		mem_data_out : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
	);
END memory_controller;

ARCHITECTURE structure OF memory_controller IS
	TYPE memory_controller_state_t IS (READY, WAIT_GET, WAIT_PUT);

	SIGNAL state : memory_controller_state_t;
	SIGNAL state_nx : memory_controller_state_t;

	PROCEDURE clear_bus(
			SIGNAL done : OUT STD_LOGIC;
			SIGNAL data : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		) IS
	BEGIN
		done <= 'Z';
		data <= (OTHERS => 'Z');
	END PROCEDURE;
BEGIN

internal_register : PROCESS(clk, reset)
BEGIN
	IF rising_edge(clk) THEN
		IF reset = '1' THEN
			state <= READY;
		ELSE
			state <= state_nx;
		END IF;
	END IF;
END PROCESS internal_register;

next_state : PROCESS(reset, cmd, addr, mem_done)
BEGIN
	IF reset = '1' THEN
		state_nx <= READY;
	ELSE
		state_nx <= state;
		IF state = READY THEN
			IF is_cmd(cmd) THEN
				IF cmd = CMD_GET THEN
					state_nx <= WAIT_GET;
				ELSIF cmd = CMD_PUT THEN
					state_nx <= WAIT_PUT;
				END IF;
			END IF;
		ELSE
			IF mem_done = '1' THEN
				state_nx <= READY;
			END IF;
		END IF;
	END IF;
END PROCESS next_state;

execution : PROCESS(clk, reset)
BEGIN
	IF rising_edge(clk) THEN
		IF reset = '1' THEN
			clear_bus(done, data);
			mem_req <= '0';
		ELSE
			clear_bus(done, data);

			IF state = READY THEN
				IF state_nx = READY THEN
					mem_req <= '0';
					mem_we <= '0';
				ELSIF state_nx = WAIT_GET THEN
					mem_req <= '1';
					mem_we <= '0';
				ELSIF state_nx = WAIT_PUT THEN
					mem_req <= '1';
					mem_we <= '1';
				END IF;
			ELSIF state = WAIT_GET THEN
				IF state_nx = READY THEN
					mem_req <= '0';
					data <= mem_data_out;
					done <= '1';
				END IF;
			ELSIF state = WAIT_PUT THEN
				IF state_nx = READY THEN
					mem_req <= '0';
					done <= '1';
				END IF;
			END IF;
		END IF;
	END IF;
END PROCESS execution;

mem_addr <= addr;
mem_data_in <= data;

END structure;
