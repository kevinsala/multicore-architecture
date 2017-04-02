LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg_DA IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		mem_we_in : IN STD_LOGIC;
		byte_in : IN STD_LOGIC;
		mem_read_in : IN STD_LOGIC;
		reg_we_in : IN STD_LOGIC;
		branch_in : IN STD_LOGIC;
		branch_if_eq_in : IN STD_LOGIC;
		jump_in : IN STD_LOGIC;
		inm_ext_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_ctrl_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		reg_src1_v_in : IN STD_LOGIC;
		reg_src2_v_in : IN STD_LOGIC;
		inm_src2_v_in : IN STD_LOGIC;
		reg_src1_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src2_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		reg_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		iret_in : IN STD_LOGIC;
		mem_we_out : OUT STD_LOGIC;
		byte_out : OUT STD_LOGIC;
		mem_read_out : OUT STD_LOGIC;
		reg_we_out : OUT STD_LOGIC;
		branch_out : OUT STD_LOGIC;
		branch_if_eq_out : OUT STD_LOGIC;
		jump_out : OUT STD_LOGIC;
		inm_ext_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALU_ctrl_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		reg_src1_v_out : OUT STD_LOGIC;
		reg_src2_v_out : OUT STD_LOGIC;
		inm_src2_v_out : OUT STD_LOGIC;
		reg_src1_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src2_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		reg_data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		iret_out : OUT STD_LOGIC
	);
END reg_DA;

ARCHITECTURE structure OF reg_DA IS
BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				mem_we_out <= '0';
				byte_out <= '0';
				mem_read_out <= '0';
				reg_we_out <= '0';
				branch_out <= '0';
				branch_if_eq_out <= '0';
				jump_out <= '0';
				inm_ext_out <= (OTHERS => '0');
				reg_src1_out <= (OTHERS => '0');
				ALU_ctrl_out <= (OTHERS => '0');
				reg_src1_v_out <= '0';
				reg_src2_v_out <= '0';
				inm_src2_v_out <= '0';
				reg_src2_out <= (OTHERS => '0');
				reg_dest_out <= (OTHERS => '0');
				reg_data1_out <= (OTHERS => '0');
				reg_data2_out <= (OTHERS => '0');
				mem_data_out <= (OTHERS => '0');
				iret_out <= '0';
			ELSE
				IF we = '1' THEN
					mem_we_out <= mem_we_in;
					byte_out <= byte_in;
					mem_read_out <= mem_read_in;
					reg_we_out <= reg_we_in;
					branch_out <= branch_in;
					branch_if_eq_out <= branch_if_eq_in;
					jump_out <= jump_in;
					inm_ext_out <= inm_ext_in;
					ALU_ctrl_out <= ALU_ctrl_in;
					reg_src1_v_out <= reg_src1_v_in;
					reg_src2_v_out <= reg_src2_v_in;
					inm_src2_v_out <= inm_src2_v_in;
					reg_src1_out <= reg_src1_in;
					reg_src2_out <= reg_src2_in;
					reg_dest_out <= reg_dest_in;
					reg_data1_out <= reg_data1_in;
					reg_data2_out <= reg_data2_in;
					mem_data_out <= mem_data_in;
					iret_out <= iret_in;
				END IF;
			END IF;
		END IF;
	END PROCESS p;
END structure;

