LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg_MUL IS
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
END reg_MUL;

ARCHITECTURE structure OF reg_MUL IS

BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' OR we = '0' THEN
				mul <= '0';
				rd_out <= "00000";
				rwe_out <= '0';
				DA_out <= "00000000000000000000000000000000";
				DB_out <= "00000000000000000000000000000000";
			ELSE
				mul <= we;
				rd_out <= rd_in;
				rwe_out <= rwe_in;
				DA_out <= DA;
				DB_out <= DB;
			END IF;
		END IF;
	END PROCESS p;
END structure;