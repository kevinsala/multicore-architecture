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
		Codigo_OP : in STD_LOGIC_VECTOR(6 downto 0);
		ReadMem_EX : in STD_LOGIC;
		Rs1_ID : in STD_LOGIC_VECTOR (4 downto 0);
		Rs2_ID	: in STD_LOGIC_VECTOR (4 downto 0);
		Rd_EX	: in STD_LOGIC_VECTOR (4 downto 0);
		Sout : out STD_LOGIC;
		PC_Write : out STD_LOGIC;
		ID_Write : out STD_LOGIC
	);
end UD;

architecture Behavioral of UD is
begin
	Sout <= '0' when (ReadMem_EX='1' AND (Rs1_ID=Rd_EX OR Rs2_ID=Rd_EX) AND (Codigo_OP="0000000" OR Codigo_OP="0010011"))
	else '1';
	PC_Write <= '0' when (ReadMem_EX='1' AND (Rs1_ID=Rd_EX OR Rs2_ID=Rd_EX) AND (Codigo_OP="0000000" OR Codigo_OP="0010011"))
	else '1';
	ID_Write <= '0' when (ReadMem_EX='1' AND (Rs1_ID=Rd_EX OR Rs2_ID=Rd_EX) AND (Codigo_OP="0000000" OR Codigo_OP="0010011"))
	else '1';
end Behavioral;