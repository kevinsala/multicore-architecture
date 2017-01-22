LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

ENTITY ALU_MUL_seg IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		load : IN STD_LOGIC;
		done_L : IN STD_LOGIC;
		DA : IN  STD_LOGIC_VECTOR (31 downto 0); --entrada 1
		DB : IN  STD_LOGIC_VECTOR (31 downto 0); --entrada 2
		reg_dest_in : IN STD_LOGIC_VECTOR(4 downto 0);
		reg_we_in : IN STD_LOGIC;
		M2_mul : OUT STD_LOGIC;
		reg_dest_M2 : OUT STD_LOGIC_VECTOR(4 downto 0);
		M3_mul : OUT STD_LOGIC;
		reg_dest_M3 : OUT STD_LOGIC_VECTOR (4 downto 0);
		M4_mul : OUT STD_LOGIC;
		reg_dest_M4 : OUT STD_LOGIC_VECTOR (4 downto 0);
		M5_mul : OUT STD_LOGIC;
		reg_dest_out : OUT STD_LOGIC_VECTOR(4 downto 0);
		reg_we_out : OUT STD_LOGIC;
		Dout : OUT  STD_LOGIC_VECTOR (31 downto 0);
		-- reg status signals --
		pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status_in : IN STD_LOGIC;
		exc_new : IN STD_LOGIC;
		exc_code_new : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_new : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_old : IN STD_LOGIC;
		exc_code_old : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_old : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		rob_idx_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		inst_type_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status_out : OUT STD_LOGIC;
		exc_out : OUT STD_LOGIC;
		exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		rob_idx_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		inst_type_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END ALU_MUL_seg;

ARCHITECTURE Behavioral OF ALU_MUL_seg IS

COMPONENT reg_MUL IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		DA : IN STD_LOGIC_VECTOR(31 downto 0);
		DB : IN STD_LOGIC_VECTOR(31 downto 0);
		rd_in : IN STD_LOGIC_VECTOR(4 downto 0);
		rwe_in : IN STD_LOGIC;
		mul : OUT STD_LOGIC;
		rd_out : OUT STD_LOGIC_VECTOR(4 downto 0);
		rwe_out : OUT STD_LOGIC;
		DA_out : OUT STD_LOGIC_VECTOR(31 downto 0);
		DB_out : OUT STD_LOGIC_VECTOR(31 downto 0)
	);
END COMPONENT;

COMPONENT reg_status IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status_in : IN STD_LOGIC;
		exc_new : IN STD_LOGIC;
		exc_code_new : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_new : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_old : IN STD_LOGIC;
		exc_code_old : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_old : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		rob_idx_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		inst_type_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status_out : OUT STD_LOGIC;
		exc_out : OUT STD_LOGIC;
		exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		rob_idx_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		inst_type_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

-- Mul Signals
SIGNAL load_M1 : STD_LOGIC;
SIGNAL DA_2 : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL DB_2 : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL mul_M2 : STD_LOGIC;
SIGNAL reg_dest_2 : STD_LOGIC_VECTOR(4 downto 0);
SIGNAL reg_we_2 : STD_LOGIC;
SIGNAL DA_3 : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL DB_3 : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL mul_M3: STD_LOGIC;
SIGNAL reg_dest_3 : STD_LOGIC_VECTOR(4 downto 0);
SIGNAL reg_we_3 : STD_LOGIC;
SIGNAL DA_4 : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL DB_4 : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL mul_M4 : STD_LOGIC;
SIGNAL reg_dest_4 : STD_LOGIC_VECTOR(4 downto 0);
SIGNAL reg_we_4 : STD_LOGIC;
SIGNAL DA_5 : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL DB_5 : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL mul_M5 : STD_LOGIC;

--Reg status Signals
SIGNAL pc_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL priv_status_2 : STD_LOGIC;
SIGNAL exc_2 : STD_LOGIC;
SIGNAL exc_code_2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL exc_data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL rob_idx_2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL inst_type_2 : STD_LOGIC_VECTOR(1 DOWNTO 0);

SIGNAL pc_3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL priv_status_3 : STD_LOGIC;
SIGNAL exc_3 : STD_LOGIC;
SIGNAL exc_code_3 : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL exc_data_3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL rob_idx_3 : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL inst_type_3 : STD_LOGIC_VECTOR(1 DOWNTO 0);

SIGNAL pc_4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL priv_status_4 : STD_LOGIC;
SIGNAL exc_4 : STD_LOGIC;
SIGNAL exc_code_4 : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL exc_data_4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL rob_idx_4 : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL inst_type_4 : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

	m1_2: reg_MUL PORT MAP(
		clk => clk,
		reset => reset,
		we => load_M1,
		DA => DA,
		DB => DB,
		rd_in => reg_dest_in,
		rwe_in => reg_we_in,
		mul => mul_M2,
		rd_out => reg_dest_2,
		rwe_out => reg_we_2,
		DA_out => DA_2,
		DB_out => DB_2
	);

	reg_status_M1_2: reg_status PORT MAP(
		clk => clk,
		reset => reset,
		we => load_M1,
		pc_in => pc_in,
		priv_status_in => priv_status_in,
		exc_new => '0',
		exc_code_new => (OTHERS => 'X'),
		exc_data_new => (OTHERS => 'X'),
		exc_old => exc_old,
		exc_code_old => exc_code_old,
		exc_data_old => exc_data_old,
		rob_idx_in => rob_idx_in,
		inst_type_in => inst_type_in,
		pc_out => pc_2,
		priv_status_out => priv_status_2,
		exc_out => exc_2,
		exc_code_out => exc_code_2,
		exc_data_out => exc_data_2,
		rob_idx_out => rob_idx_2,
		inst_type_out => inst_type_2
	);

	m2_3: reg_MUL PORT MAP(
		clk => clk,
		reset => reset,
		we => mul_M2,
		DA => DA_2,
		DB => DB_2,
		rd_in => reg_dest_2,
		rwe_in => reg_we_2,
		mul => mul_M3,
		rd_out => reg_dest_3,
		rwe_out => reg_we_3,
		DA_out => DA_3,
		DB_out => DB_3
	);

	reg_status_M2_3: reg_status PORT MAP(
		clk => clk,
		reset => reset,
		we => mul_M2,
		pc_in => pc_2,
		priv_status_in => priv_status_2,
		exc_new => '0',
		exc_code_new => (OTHERS => 'X'),
		exc_data_new => (OTHERS => 'X'),
		exc_old => exc_2,
		exc_code_old => exc_code_2,
		exc_data_old => exc_data_2,
		rob_idx_in => rob_idx_2,
		inst_type_in => inst_type_2,
		pc_out => pc_3,
		priv_status_out => priv_status_3,
		exc_out => exc_3,
		exc_code_out => exc_code_3,
		exc_data_out => exc_data_3,
		rob_idx_out => rob_idx_3,
		inst_type_out => inst_type_3
	);

	m3_4: reg_MUL PORT MAP(
		clk => clk,
		reset => reset,
		we => mul_M3,
		DA => DA_3,
		DB => DB_3,
		rd_in => reg_dest_3,
		rwe_in => reg_we_3,
		mul => mul_M4,
		rd_out => reg_dest_4,
		rwe_out => reg_we_4,
		DA_out => DA_4,
		DB_out => DB_4
	);

	reg_status_M3_4: reg_status PORT MAP(
		clk => clk,
		reset => reset,
		we => mul_M3,
		pc_in => pc_3,
		priv_status_in => priv_status_3,
		exc_new => '0',
		exc_code_new => (OTHERS => 'X'),
		exc_data_new => (OTHERS => 'X'),
		exc_old => exc_3,
		exc_code_old => exc_code_3,
		exc_data_old => exc_data_3,
		rob_idx_in => rob_idx_3,
		inst_type_in => inst_type_3,
		pc_out => pc_4,
		priv_status_out => priv_status_4,
		exc_out => exc_4,
		exc_code_out => exc_code_4,
		exc_data_out => exc_data_4,
		rob_idx_out => rob_idx_4,
		inst_type_out => inst_type_4
	);

	m4_5: reg_MUL PORT MAP(
		clk => clk,
		reset => reset,
		we => mul_M4,
		DA => DA_4,
		DB => DB_4,
		rd_in => reg_dest_4,
		rwe_in => reg_we_4,
		mul => mul_M5,
		rd_out => reg_dest_out,
		rwe_out => reg_we_out,
		DA_out => DA_5,
		DB_out => DB_5
	);

	reg_status_M4_5: reg_status PORT MAP(
		clk => clk,
		reset => reset,
		we => mul_M4,
		pc_in => pc_4,
		priv_status_in => priv_status_4,
		exc_new => '0',
		exc_code_new => (OTHERS => 'X'),
		exc_data_new => (OTHERS => 'X'),
		exc_old => exc_4,
		exc_code_old => exc_code_4,
		exc_data_old => exc_data_4,
		rob_idx_in => rob_idx_4,
		inst_type_in => inst_type_4,
		pc_out => pc_out,
		priv_status_out => priv_status_out,
		exc_out => exc_out,
		exc_code_out => exc_code_out,
		exc_data_out => exc_data_out,
		rob_idx_out => rob_idx_out,
		inst_type_out => inst_type_out
	);

	load_M1 <= load AND done_L;

	M2_mul <= mul_M2;
	M3_mul <= mul_M3;
	M4_mul <= mul_M4;
	M5_mul <= mul_M5;

	reg_dest_M2 <= reg_dest_2;
	reg_dest_M3 <= reg_dest_3;
	reg_dest_M4 <= reg_dest_4;

	Dout <= DA_5(15 downto 0) * DB_5(15 downto 0);

END Behavioral;
