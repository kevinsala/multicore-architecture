LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;
USE work.utils.ALL;

ENTITY reg_bank IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		debug_dump : IN STD_LOGIC;
		src1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		src2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		we : IN STD_LOGIC;
		dest : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exception : IN STD_LOGIC;
		exc_code : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END reg_bank;

ARCHITECTURE structure OF reg_bank IS
	TYPE reg_array IS ARRAY(31 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL reg_bank : reg_array;

	PROCEDURE dump_reg_bank(CONSTANT filename : IN STRING;
						SIGNAL reg : IN reg_array) IS
		FILE dumpfile : TEXT OPEN write_mode IS filename;
		VARIABLE lbuf : LINE;
	BEGIN
		FOR n_line IN 0 TO 31 LOOP
			-- Hex convert
			hwrite(lbuf, reg(n_line));
			-- Write to file
			writeline(dumpfile, lbuf);
		END LOOP;
	END PROCEDURE;
BEGIN
	p: PROCESS(clk)
	BEGIN
		-- Write on falling edge
		IF falling_edge(clk) THEN
			IF debug_dump = '1' THEN
				dump_reg_bank("dump/reg", reg_bank);
			END IF;

			IF reset = '1' THEN
				FOR i IN 0 TO 31 LOOP
					reg_bank(i) <= (OTHERS => '0');
				END LOOP;
			ELSE
				IF we = '1' THEN
					reg_bank(conv_integer(dest)) <= data_in;
				END IF;

				IF exception = '1' THEN
					reg_bank(conv_integer(REG_EXC_CODE)) <= x"0000000" & "00" & exc_code;
					reg_bank(conv_integer(REG_EXC_DATA)) <= exc_data;
				END IF;
			END IF;
		END IF;
	END PROCESS p;

	data1 <= reg_bank(conv_integer(src1));
	data2 <= reg_bank(conv_integer(src2));
END structure;
