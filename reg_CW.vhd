LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg_CW IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		mem_inst_in : IN STD_LOGIC;
		reg_we_in : IN STD_LOGIC;
		reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		MUL_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mul_in : IN STD_LOGIC;
		reg_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_inst_out : OUT STD_LOGIC;
		reg_we_out : OUT STD_LOGIC;
		reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		MUL_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mul_out : OUT STD_LOGIC
	);
END reg_CW;

ARCHITECTURE structure OF reg_CW IS
BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				mem_inst_out <= '0';
				reg_we_out <= '0';
				reg_dest_out <= (OTHERS => '0');
				reg_data_out <= (OTHERS => '0');
				MUL_out_out <= (OTHERS => '0');
				mul_out <= '0';
			ELSE
				IF we = '1' THEN
					mem_inst_out <= mem_inst_in;
					reg_we_out <= reg_we_in;
					reg_dest_out <= reg_dest_in;
					reg_data_out <= reg_data_in;
					MUL_out_out <= MUL_out_in;
					mul_out <= mul_in;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END structure;
