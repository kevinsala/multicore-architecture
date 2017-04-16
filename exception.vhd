LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY exception_unit IS
	PORT (
		invalid_access_F : IN STD_LOGIC;
		mem_addr_F : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		invalid_inst_D : IN STD_LOGIC;
		inst_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		invalid_access_C : IN STD_LOGIC;
		mem_addr_C : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_F : OUT STD_LOGIC;
		exc_code_F : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_D : OUT STD_LOGIC;
		exc_code_D : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_D : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_A : OUT STD_LOGIC;
		exc_code_A : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_A : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_C : OUT STD_LOGIC;
		exc_code_C : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_C : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END exception_unit;

ARCHITECTURE structure OF exception_unit IS

	CONSTANT INVALID_INST_CODE : STD_LOGIC_VECTOR := "00";
	CONSTANT INVALID_ACCESS_CODE : STD_LOGIC_VECTOR := "01";

BEGIN
	exc_F <= '0';
	exc_code_F <= (OTHERS => 'X');
	exc_data_F <= (OTHERS => 'X');

	exc_D <= invalid_inst_D;
	exc_code_D <= INVALID_INST_CODE WHEN invalid_inst_D = '1' ELSE
					(OTHERS => 'X');
	exc_data_D <= inst_D WHEN invalid_inst_D = '1' ELSE
					(OTHERS => 'X');

	exc_A <= '0';
	exc_code_A <= (OTHERS => 'X');
	exc_data_A <= (OTHERS => 'X');

	exc_C <= invalid_access_C;
	exc_code_C <= INVALID_ACCESS_CODE WHEN invalid_access_C = '1' ELSE
					(OTHERS => 'X');
	exc_data_C <= mem_addr_C WHEN invalid_access_C = '1' ELSE
					(OTHERS => 'X');
END structure;
