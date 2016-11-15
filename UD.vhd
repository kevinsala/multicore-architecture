----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:56:04 05/14/2014 
-- Design Name: 
-- Module Name:    UD - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UD is
	Port(
		Codigo_OP : in STD_LOGIC_VECTOR(5 downto 0);
		ReadMem_EX : in STD_LOGIC;
		Rs_ID : in STD_LOGIC_VECTOR (4 downto 0);
		Rt_ID	: in STD_LOGIC_VECTOR (4 downto 0);
		Rt_EX	: in STD_LOGIC_VECTOR (4 downto 0);
		Sout : out STD_LOGIC;
		PC_Write : out STD_LOGIC;
		ID_Write : out STD_LOGIC
	);
end UD;

architecture Behavioral of UD is
begin
	Sout <= '0' when (ReadMem_EX='1' AND (Rs_ID=Rt_EX OR Rt_ID=Rt_EX) AND (Codigo_OP="000001" OR Codigo_OP="000011"))
	else '1';
	PC_Write <= '0' when (ReadMem_EX='1' AND (Rs_ID=Rt_EX OR Rt_ID=Rt_EX) AND (Codigo_OP="000001" OR Codigo_OP="000011"))
	else '1';
	ID_Write <= '0' when (ReadMem_EX='1' AND (Rs_ID=Rt_EX OR Rt_ID=Rt_EX) AND (Codigo_OP="000001" OR Codigo_OP="000011"))
	else '1';
end Behavioral;