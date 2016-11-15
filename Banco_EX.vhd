----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:46:01 04/07/2014 
-- Design Name: 
-- Module Name:    Banco_EX - Behavioral 
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

entity Banco_EX is
    Port(
	 clk : in  STD_LOGIC;
	 reset : in  STD_LOGIC;
	 load : in  STD_LOGIC;
	 busA : in  STD_LOGIC_VECTOR (31 downto 0);
         busB : in  STD_LOGIC_VECTOR (31 downto 0);
	 busA_EX : out  STD_LOGIC_VECTOR (31 downto 0);
         busB_EX : out  STD_LOGIC_VECTOR (31 downto 0);
         RegDst_ID : in  STD_LOGIC;
	 ALUSrc_A_ID : in  STD_LOGIC;
         ALUSrc_B_ID : in  STD_LOGIC;
         MemWrite_ID : in  STD_LOGIC;
         MemRead_ID : in  STD_LOGIC;
         MemtoReg_ID : in  STD_LOGIC;
         RegWrite_ID : in  STD_LOGIC;
	 inm_ext: IN  std_logic_vector(31 downto 0);
	 inm_ext_EX: OUT  std_logic_vector(31 downto 0);
         RegDst_EX : out  STD_LOGIC;
         ALUSrc_A_EX : out  STD_LOGIC;
	 ALUSrc_B_EX : out  STD_LOGIC;
         MemWrite_EX : out  STD_LOGIC;
         MemRead_EX : out  STD_LOGIC;
         MemtoReg_EX : out  STD_LOGIC;
         RegWrite_EX : out  STD_LOGIC;
	 ALUctrl_ID: in STD_LOGIC_VECTOR (2 downto 0);
	 ALUctrl_EX: out STD_LOGIC_VECTOR (2 downto 0);
         Reg_Rt_ID : in  STD_LOGIC_VECTOR (4 downto 0);
         Reg_Rd_ID : in  STD_LOGIC_VECTOR (4 downto 0);
	 Reg_Rs_ID : in  STD_LOGIC_VECTOR (4 downto 0);
         Reg_Rt_EX : out  STD_LOGIC_VECTOR (4 downto 0);
         Reg_Rd_EX : out  STD_LOGIC_VECTOR (4 downto 0);
	 Reg_Rs_EX : out  STD_LOGIC_VECTOR (4 downto 0)); 
end Banco_EX;

architecture Behavioral of Banco_EX is

begin
SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
         	busA_EX <= "00000000000000000000000000000000";
		busB_EX <= "00000000000000000000000000000000";
		inm_ext_EX <= "00000000000000000000000000000000";
		RegDst_EX <= '0';
		ALUSrc_A_EX <= '0';
		ALUSrc_B_EX <= '0';
		MemWrite_EX <= '0';
		MemRead_EX <= '0';
		MemtoReg_EX <= '0';
		RegWrite_EX <= '0';
		Reg_Rt_EX <= "00000";
		Reg_Rd_EX <= "00000";
		Reg_Rs_EX <= "00000";
		ALUctrl_EX <= "000";
         else
            if (load='1') then 
		busA_EX <= busA;
		busB_EX <= busB;
		RegDst_EX <= RegDst_ID;
		ALUSrc_A_EX <= ALUSrc_A_ID;
		ALUSrc_B_EX <= ALUSrc_B_ID;
		MemWrite_EX <= MemWrite_ID;
		MemRead_EX <= MemRead_ID;
		MemtoReg_EX <= MemtoReg_ID;
		RegWrite_EX <= RegWrite_ID;
		Reg_Rt_EX <= Reg_Rt_ID;
		Reg_Rd_EX <= Reg_Rd_ID;
		Reg_Rs_EX <= Reg_Rs_ID;
		ALUctrl_EX <= ALUctrl_ID;
		inm_ext_EX <= inm_ext;
	    end if;	
         end if;        
      end if;
   end process;

end Behavioral;

