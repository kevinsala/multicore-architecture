LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg_CW IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		dtlb_we_in : IN STD_LOGIC;
		itlb_we_in : IN STD_LOGIC;
		reg_we_in : IN STD_LOGIC;
		reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_inst_out : OUT STD_LOGIC;
		dtlb_we_out : OUT STD_LOGIC;
		itlb_we_out : OUT STD_LOGIC;
		reg_we_out : OUT STD_LOGIC;
		reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END reg_CW;

ARCHITECTURE structure OF reg_CW IS
BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				dtlb_we_out <= '0';
				itlb_we_out <= '0';
				reg_we_out <= '0';
				reg_dest_out <= (OTHERS => '0');
				reg_data_out <= (OTHERS => '0');
			ELSE
				IF we = '1' THEN
					dtlb_we_out <= dtlb_we_in;
					itlb_we_out <= itlb_we_in;
					reg_we_out <= reg_we_in;
					reg_dest_out <= reg_dest_in;
					reg_data_out <= reg_data_in;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END structure;
