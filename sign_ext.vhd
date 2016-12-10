LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY sign_ext IS
	PORT(
		opcode : IN STD_LOGIC_VECTOR (6 downto 0);
		offsethi : IN  STD_LOGIC_VECTOR (4 downto 0);
		offsetm : IN  STD_LOGIC_VECTOR (4 downto 0);
		offsetlo : IN  STD_LOGIC_VECTOR (9 downto 0);
		inm_ext : OUT  STD_LOGIC_VECTOR (31 downto 0)
	);
END sign_ext;

ARCHITECTURE Behavioral OF sign_ext IS
BEGIN
	inm_ext(9 downto 0) <= offsetlo;
	inm_ext(14 downto 10) <= offsetm when (opcode(6 downto 3)="0010" OR opcode(6 downto 0)="0110001")
		else offsethi;
	inm_ext(19 downto 15) <= offsethi when opcode(6 downto 0)="0110001"
		else "00000" when (offsetm(4)='0' AND opcode(6 downto 3)="0010")
		else "00000" when (offsethi(4)='0' AND opcode(6 downto 0)="0110000")
		else "11111";
	inm_ext(31 downto 20) <= "000000000000" when (offsetm(4)='0' AND opcode(6 downto 3)="0010")
		else "000000000000" when (offsethi(4)='0' AND opcode(6 downto 1)="011000")
		else "111111111111";
END Behavioral;
