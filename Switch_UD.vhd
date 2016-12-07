----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:40:35 05/14/2014 
-- Design Name: 
-- Module Name:    Switch_UD - Behavioral 
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

entity Switch_UD is
Port(
	Reg_Write : in STD_LOGIC;
	Mem_Read : in STD_LOGIC;
	Byte : in STD_LOGIC;
	Mem_Write : in STD_LOGIC;
	MemtoReg : in STD_LOGIC;
	ALU_Src_A : in STD_LOGIC;
	ALU_Src_B : in STD_LOGIC;
	ctrl : in STD_LOGIC;
	Reg_Write_out : out STD_LOGIC;
	Mem_Read_out : out STD_LOGIC;
	Byte_out : out STD_LOGIC;
	Mem_Write_out : out STD_LOGIC;
	MemtoReg_out : out STD_LOGIC;
	ALU_Src_A_out : out STD_LOGIC;
	ALU_Src_B_out : out STD_LOGIC);
end Switch_UD;

architecture Behavioral of Switch_UD is

begin	
	Reg_Write_out <= Reg_Write when (ctrl ='1') else '0';
	Mem_Read_out <= Mem_Read when (ctrl ='1') else '0';
	Byte_out <= Byte when (ctrl ='1') else '0';
	Mem_Write_out <= Mem_Write when (ctrl ='1') else '0';
	MemtoReg_out <= MemtoReg when (ctrl ='1') else '0';
	ALU_Src_A_out <= ALU_Src_A when (ctrl ='1') else '0';
	ALU_Src_B_out <= ALU_Src_B when (ctrl ='1') else '0';
end Behavioral;

