library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UA is
    Port(
	 Rt : in  STD_LOGIC_VECTOR (4 downto 0);
	 ExMem_Rd : in  STD_LOGIC_VECTOR (4 downto 0);
	 MemWB_Rd : in STD_LOGIC_VECTOR (4 downto 0);
	 Rs : in  STD_LOGIC_VECTOR (4 downto 0);
	 ALUSrc_A : in STD_LOGIC;
	 ALUSrc_B : in STD_LOGIC;
	 MemWrite_EX : in STD_LOGIC;
	 RegWrite_Mem : in STD_LOGIC;
	 RegWrite_WB : in STD_LOGIC;
	 Mux_ant_A : out  STD_LOGIC_VECTOR (1 downto 0);
         Mux_ant_B : out  STD_LOGIC_VECTOR (1 downto 0);
	 Mux_ant_C : out  STD_LOGIC_VECTOR (1 downto 0));
end UA;

architecture Behavioral of UA is

begin
	Mux_ant_A <= "10" when (Rs=ExMem_Rd AND RegWrite_Mem='1')
	else "01" when (Rs=MemWB_Rd AND RegWrite_WB='1')
	else "00" when (ALUSrc_A='0')
	else "11";
	
	Mux_ant_B <= "01" when (Rt=MemWB_Rd AND MemWrite_EX='0' AND RegWrite_WB='1')
	else "10" when (Rt=ExMem_Rd AND MemWrite_EX='0' AND RegWrite_Mem='1')
	else "00" when (ALUSrc_B='0')
	else "11";
	
	Mux_ant_C <= "01" when (Rt=MemWB_Rd AND MemWrite_EX='1' AND RegWrite_WB='1')
	else "10" when (Rt=ExMem_Rd AND MemWrite_EX='1' AND RegWrite_Mem='1')
	else "00";
end Behavioral;
