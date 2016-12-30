LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY exception_unit IS
	PORT (invalid_inst_D : IN STD_LOGIC;
		inst_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		invalid_access_L : IN STD_LOGIC;
		mem_addr_L : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_F : OUT STD_LOGIC;
		exc_code_F : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_D : OUT STD_LOGIC;
		exc_code_D : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_D : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_A : OUT STD_LOGIC;
		exc_code_A : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_A : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_L : OUT STD_LOGIC;
		exc_code_L : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_L : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_C : OUT STD_LOGIC;
		exc_code_C : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_C : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END exception_unit;

ARCHITECTURE structure OF exception_unit IS
BEGIN
	exc_F <= '0';
	exc_code_F <= (OTHERS => 'X');
	exc_data_F <= (OTHERS => 'X');

	exc_D <= invalid_inst_D;
	exc_code_D <= "00" WHEN invalid_inst_D = '1' ELSE
					(OTHERS => 'X');
	exc_data_D <= inst_D WHEN invalid_inst_D = '1' ELSE
					(OTHERS => 'X');

	exc_A <= '0';
	exc_code_A <= (OTHERS => 'X');
	exc_data_A <= (OTHERS => 'X');

	exc_L <= invalid_access_L;
	exc_code_L <= "01" WHEN invalid_access_L = '1' ELSE
					(OTHERS => 'X');
	exc_data_L <= mem_addr_L WHEN invalid_access_L = '1' ELSE
					(OTHERS => 'X');

	exc_C <= '0';
	exc_code_C <= (OTHERS => 'X');
	exc_data_C <= (OTHERS => 'X');
END structure;
