LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY sign_ext IS
	PORT(
		inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		inm_ext : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END sign_ext;

ARCHITECTURE Behavioral OF sign_ext IS
	SIGNAL opcode   : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL offsethi : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL offsetm  : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL offsetlo : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL inm_ext_int : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

	opcode <= inst(31 DOWNTO 25);
	offsethi <= inst(24 DOWNTO 20);
	offsetm <= inst(14 DOWNTO 10);
	offsetlo <= inst(9 DOWNTO 0);

	inm_ext_int(9 DOWNTO 0) <= offsetlo;
	inm_ext_int(14 DOWNTO 10) <= offsetm WHEN (opcode(6 DOWNTO 3) = "0010" OR opcode = "0110001" OR opcode = "0001111")
		ELSE offsethi;
	inm_ext_int(19 DOWNTO 15) <= offsethi WHEN opcode = "0110001"
		ELSE "00000" WHEN (offsetm(4)='0' AND opcode(6 DOWNTO 3) = "0010")
		ELSE "00000" WHEN (offsethi(4)='0' AND (opcode = "0110000" OR opcode = "0110010"))
		ELSE inst(19 DOWNTO 15) WHEN opcode = "0001111"
		ELSE "11111";
	inm_ext_int(31 DOWNTO 20) <= "000000000000" WHEN inm_ext_int(19) = '0'
		ELSE "111111111111";

	inm_ext <= inm_ext_int;
END Behavioral;
