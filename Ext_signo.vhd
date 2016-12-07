LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY Ext_signo IS
	PORT(
		opcode : IN STD_LOGIC_VECTOR (6 downto 0);
		offsethi : IN  STD_LOGIC_VECTOR (4 downto 0);
		offsetm : IN  STD_LOGIC_VECTOR (4 downto 0);
		offsetlo : IN  STD_LOGIC_VECTOR (9 downto 0);
		inm_ext : OUT  STD_LOGIC_VECTOR (31 downto 0)
	);
END Ext_signo;

ARCHITECTURE Behavioral OF Ext_signo IS
BEGIN
	inm_ext(9 downto 0) <= offsetlo;
	inm_ext(14 downto 10) <= offsetm when (opcode(6 downto 2)="00100" OR opcode(6 downto 0)="0110001") 
		else offsethi;
	inm_ext(19 downto 15) <= offsethi when opcode(6 downto 0)="0110001"
		else "00000" when (offsetm(4)='0' AND opcode(6 downto 2)="00100")
		else "00000" when (offsethi(4)='0' AND opcode(6 downto 0)="0110000")
		else "11111";
	inm_ext(31 downto 20) <= "000000000000" when (offsetm(4)='0' AND opcode(6 downto 2)="00100")
		else "000000000000" when (offsethi(4)='0' AND opcode(6 downto 1)="011000")
		else "111111111111";
END Behavioral;