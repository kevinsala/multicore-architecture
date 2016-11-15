----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:25:11 04/07/2014 
-- Design Name: 
-- Module Name:    Banco_WB - Behavioral 
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

entity Banco_WB is
Port ( 	ALU_out_MEM : in  STD_LOGIC_VECTOR (31 downto 0); 
	ALU_out_WB : out  STD_LOGIC_VECTOR (31 downto 0); 
	MEM_out : in  STD_LOGIC_VECTOR (31 downto 0); 
	MDR : out  STD_LOGIC_VECTOR (31 downto 0); --memory data register
        clk : in  STD_LOGIC;
	reset : in  STD_LOGIC;
        load : in  STD_LOGIC;
	MemtoReg_MEM : in  STD_LOGIC;
        RegWrite_MEM : in  STD_LOGIC;
	MemtoReg_WB : out  STD_LOGIC;
        RegWrite_WB : out  STD_LOGIC;
        RW_MEM : in  STD_LOGIC_VECTOR (4 downto 0); -- registro destino de la escritura
        RW_WB : out  STD_LOGIC_VECTOR (4 downto 0)); -- PC+4 en la etapa IDend Banco_WB;
end Banco_WB;

architecture Behavioral of Banco_WB is

begin
SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
		ALU_out_WB <= "00000000000000000000000000000000";
		MDR <= "00000000000000000000000000000000";
		RW_WB <= "00000";
		MemtoReg_WB <= '0';
		RegWrite_WB <= '0';
         else
            if (load='1') then 
		ALU_out_WB <= ALU_out_MEM;
		MDR <= Mem_out;
		RW_WB <= RW_MEM;
		MemtoReg_WB <= MemtoReg_MEM;
		RegWrite_WB <= RegWrite_MEM;
	     end if;	
         end if;        
      end if;
   end process;

end Behavioral;

