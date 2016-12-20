LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

ENTITY reg_bank IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		src1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		src2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		we : IN STD_LOGIC;
		dest : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END reg_bank;

ARCHITECTURE structure OF reg_bank IS
	TYPE reg_array IS ARRAY(31 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_file : reg_array;
BEGIN
	p: PROCESS(clk)
	BEGIN
		-- Write on falling edge
		IF falling_edge(clk) THEN
			IF reset = '1' THEN
				FOR i IN 0 TO 31 LOOP
					reg_file(i) <= (OTHERS => '0');
				END LOOP;
			ELSE
				IF we = '1' then
					reg_file(conv_integer(dest)) <= data_in;
				END IF;
			END IF;
		END IF;
	END PROCESS p;

	data1 <= reg_file(conv_integer(src1));
	data2 <= reg_file(conv_integer(src2));
END structure;
