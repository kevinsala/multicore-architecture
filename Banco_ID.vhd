----------------------------------------------------------------------------------
-- Description: Banco de registros que separa las etapas IF e ID. Almacena la instrucción en IR_ID y el PC+4 en PC4_ID
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Banco_ID is
 Port(
  IR_in : in  STD_LOGIC_VECTOR (31 downto 0); -- instrucción leida en IF
  PC_in:  in  STD_LOGIC_VECTOR (31 downto 0); -- PC sumado en IF
	clk : in  STD_LOGIC;
	reset : in  STD_LOGIC;
  load : in  STD_LOGIC;
  IR_ID : out  STD_LOGIC_VECTOR (31 downto 0); -- instrucción en la etapa ID
  PC_ID:  out  STD_LOGIC_VECTOR (31 downto 0) -- PC en la etapa ID
);
end Banco_ID;

architecture Behavioral of Banco_ID is

begin
SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
           IR_ID <= "11111110000000000000000000000000";
	         PC_ID <= "00000000000000000000000000000000";
         else
            if (load='1') then 
		          IR_ID <= IR_in;
		          PC_ID <= PC_in;
            end if;	
         end if;        
      end if;
   end process;

end Behavioral;

