LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg_CW IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		mem_to_reg_in : IN STD_LOGIC;
		reg_we_in : IN STD_LOGIC;
		reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		ALU_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_to_reg_out : OUT STD_LOGIC;
		reg_we_out : OUT STD_LOGIC;
		reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		ALU_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END reg_CW;

ARCHITECTURE structure OF reg_CW IS
BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				mem_to_reg_out <= '0';
				reg_we_out <= '0';
				reg_dest_out <= (OTHERS => '0');
				ALU_out_out <= (OTHERS => '0');
				mem_data_out_out <= (OTHERS => '0');
			ELSE
				IF we = '1' THEN
					mem_to_reg_out <= mem_to_reg_in;
					reg_we_out <= reg_we_in;
					reg_dest_out <= reg_dest_in;
					ALU_out_out <= ALU_out_in;
					mem_data_out_out <= mem_data_out_in;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END structure;
