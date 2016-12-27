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
		Dout : OUT  STD_LOGIC_VECTOR (31 downto 0)
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

BEGIN

	m1_2: reg_MUL PORT MAP(
		clk => clk,
		reset => reset,
		we => load,
		DA => DA,
		DB => DB,
		rd_in => reg_dest_in,
		rwe_in => reg_we_in,
		mul => mul_M2,
		rd_out => reg_dest_out,
		rwe_out => reg_we_2,
		DA_out => DA_2,
		DB_out => DB_2
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

	m4_5: reg_MUL PORT MAP(
		clk => clk,
		reset => reset,
		we => mul_m4,
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

	Dout <= DA_5(15 downto 0) * DB_5(15 downto 0);
	M2_mul <= mul_M2;
	reg_dest_M2 <= reg_dest_2;
	M3_mul <= mul_M3;
	reg_dest_M3 <= reg_dest_3;
	M4_mul <= mul_M4;
	reg_dest_M4 <= reg_dest_4;
	M5_mul <= mul_M5;

END Behavioral;