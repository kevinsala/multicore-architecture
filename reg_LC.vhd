LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.utils.all;

ENTITY reg_LC IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		dtlb_we_in : IN STD_LOGIC;
		itlb_we_in : IN STD_LOGIC;
		mem_we_in : IN STD_LOGIC;
		byte_in : IN STD_LOGIC;
		mem_read_in : IN STD_LOGIC;
		reg_we_in : IN STD_LOGIC;
		reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		ALU_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		hit_in : IN STD_LOGIC;
		line_num_in : IN INTEGER RANGE 0 TO 3;
		line_we_in : IN STD_LOGIC;
		line_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
		dtlb_we_out : OUT STD_LOGIC;
		itlb_we_out : OUT STD_LOGIC;
		mem_we_out : OUT STD_LOGIC;
		byte_out : OUT STD_LOGIC;
		mem_read_out : OUT STD_LOGIC;
		reg_we_out : OUT STD_LOGIC;
		reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		ALU_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		hit_out : OUT STD_LOGIC;
		line_num_out : OUT INTEGER RANGE 0 TO 3;
		line_we_out : OUT STD_LOGIC;
		line_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);
END reg_LC;

ARCHITECTURE structure OF reg_LC IS

BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				dtlb_we_out <= '0';
				itlb_we_out <= '0';
				mem_we_out <= '0';
				byte_out <= '0';
				mem_read_out <= '0';
				reg_we_out <= '0';
				reg_dest_out <= (OTHERS => '0');
				ALU_out_out <= (OTHERS => '0');
				mem_data_out <= (OTHERS => '0');
				hit_out <= '0';
				line_num_out <= 0;
				line_we_out <= '0';
				line_data_out <= (OTHERS => '0');
			ELSE
				IF we = '1' THEN
					mem_we_out <= mem_we_in;
					byte_out <= byte_in;
					mem_read_out <= mem_read_in;
					reg_we_out <= reg_we_in;
					reg_dest_out <= reg_dest_in;
					ALU_out_out <= ALU_out_in;
					mem_data_out <= mem_data_in;
					hit_out <= hit_in;
					line_num_out <= line_num_in;
					line_we_out <= line_we_in;
					line_data_out <= line_data_in;
					dtlb_we_out <= dtlb_we_in;
					itlb_we_out <= itlb_we_in;
				END IF;
			END IF;
		END IF;
	END PROCESS p;
END structure;
