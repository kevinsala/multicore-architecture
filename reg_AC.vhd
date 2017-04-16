LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.utils.all;

ENTITY reg_AC IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		mem_we_in : IN STD_LOGIC;
		byte_in : IN STD_LOGIC;
		mem_read_in : IN STD_LOGIC;
		reg_we_in : IN STD_LOGIC;
		reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		ALU_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_we_out : OUT STD_LOGIC;
		byte_out : OUT STD_LOGIC;
		mem_read_out : OUT STD_LOGIC;
		reg_we_out : OUT STD_LOGIC;
		reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		ALU_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END reg_AC;

ARCHITECTURE structure OF reg_AC IS
BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				mem_we_out <= '0';
				byte_out <= '0';
				mem_read_out <= '0';
				reg_we_out <= '0';
				reg_dest_out <= (OTHERS => '0');
				ALU_out_out <= (OTHERS => '0');
				mem_data_out <= (OTHERS => '0');
			ELSE
				IF we = '1' THEN
					mem_we_out <= mem_we_in;
					byte_out <= byte_in;
					mem_read_out <= mem_read_in;
					reg_we_out <= reg_we_in;
					reg_dest_out <= reg_dest_in;
					ALU_out_out <= ALU_out_in;
					mem_data_out <= mem_data_in;
				END IF;
			END IF;
		END IF;
	END PROCESS p;
END structure;
