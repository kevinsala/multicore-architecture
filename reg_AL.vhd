LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.utils.all;

ENTITY reg_AL IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		alu_inst_in : IN STD_LOGIC;
		mem_inst_in : IN STD_LOGIC;
		dtlb_we_in : IN STD_LOGIC;
		itlb_we_in : IN STD_LOGIC;
		mem_we_in : IN STD_LOGIC;
		byte_in : IN STD_LOGIC;
		mem_read_in : IN STD_LOGIC;
		reg_we_in : IN STD_LOGIC;
		reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		ALU_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		cache_state_in : IN data_cache_state_t;
		alu_inst_out : OUT STD_LOGIC;
		mem_inst_out : OUT STD_LOGIC;
		dtlb_we_out : OUT STD_LOGIC;
		itlb_we_out : OUT STD_LOGIC;
		mem_we_out : OUT STD_LOGIC;
		byte_out : OUT STD_LOGIC;
		mem_read_out : OUT STD_LOGIC;
		reg_we_out : OUT STD_LOGIC;
		reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		ALU_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		cache_state_out : OUT data_cache_state_t
	);
END reg_AL;

ARCHITECTURE structure OF reg_AL IS
BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				alu_inst_out <= '0';
				mem_inst_out <= '0';
				dtlb_we_out <= '0';
				itlb_we_out <= '0';
				mem_we_out <= '0';
				byte_out <= '0';
				mem_read_out <= '0';
				reg_we_out <= '0';
				reg_dest_out <= (OTHERS => '0');
				ALU_out_out <= (OTHERS => '0');
				mem_data_out <= (OTHERS => '0');
				cache_state_out <= READY;
			ELSE
				IF we = '1' THEN
					alu_inst_out <= alu_inst_in;
					mem_inst_out <= mem_inst_in;
					dtlb_we_out <= dtlb_we_in;
					itlb_we_out <= itlb_we_in;
					mem_we_out <= mem_we_in;
					byte_out <= byte_in;
					mem_read_out <= mem_read_in;
					reg_we_out <= reg_we_in;
					reg_dest_out <= reg_dest_in;
					ALU_out_out <= ALU_out_in;
					mem_data_out <= mem_data_in;
				END IF;
				cache_state_out <= cache_state_in;
			END IF;
		END IF;
	END PROCESS p;
END structure;
