LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY UD IS
	PORT(
		Codigo_OP : IN STD_LOGIC_VECTOR(6 downto 0);
		ReadMem_EX : IN STD_LOGIC;
		Rs1_ID : IN STD_LOGIC_VECTOR (4 downto 0);
		Rs2_ID	: IN STD_LOGIC_VECTOR (4 downto 0);
		Rd_EX	: IN STD_LOGIC_VECTOR (4 downto 0);
		Mul_det : IN STD_LOGIC;
		Sout : OUT STD_LOGIC;
		PC_Write : OUT STD_LOGIC;
		ID_Write : OUT STD_LOGIC
	);
END UD;

ARCHITECTURE Behavioral OF UD IS
BEGIN
	Sout <= '0' when ((ReadMem_EX='1' AND (Rs1_ID=Rd_EX OR Rs2_ID=Rd_EX) AND (Codigo_OP="0000000" OR Codigo_OP="0010011")) OR Mul_det='1')
	else '1';
	PC_Write <= '0' when ((ReadMem_EX='1' AND (Rs1_ID=Rd_EX OR Rs2_ID=Rd_EX) AND (Codigo_OP="0000000" OR Codigo_OP="0010011")) OR Mul_det='1')
	else '1';
	ID_Write <= '0' when ((ReadMem_EX='1' AND (Rs1_ID=Rd_EX OR Rs2_ID=Rd_EX) AND (Codigo_OP="0000000" OR Codigo_OP="0010011")) OR Mul_det='1')
	else '1';
END Behavioral;