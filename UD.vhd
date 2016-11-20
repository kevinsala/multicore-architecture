LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY UD IS
	PORT(
		Codigo_OP : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		ReadMem_EX : IN STD_LOGIC;
		Rs_ID : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		Rt_ID	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		Rt_EX	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		Sout : OUT STD_LOGIC;
		PC_Write : OUT STD_LOGIC;
		ID_Write : OUT STD_LOGIC;
		ID_branch : OUT STD_LOGIC
	);
END UD;

ARCHITECTURE structure OF UD IS
BEGIN
	Sout <= '0' WHEN (ReadMem_EX='1' AND (Rs_ID=Rt_EX OR Rt_ID=Rt_EX) AND (Codigo_OP="000001" OR Codigo_OP="000011"))
	ELSE '1';
	PC_Write <= '0' WHEN (ReadMem_EX='1' AND (Rs_ID=Rt_EX OR Rt_ID=Rt_EX) AND (Codigo_OP="000001" OR Codigo_OP="000011"))
	ELSE '1';
	ID_Write <= '0' WHEN (ReadMem_EX='1' AND (Rs_ID=Rt_EX OR Rt_ID=Rt_EX) AND (Codigo_OP="000001" OR Codigo_OP="000011"))
	ELSE '1';
	ID_branch <= '1' WHEN Codigo_OP = "000100"
	ELSE '0';
END structure;
