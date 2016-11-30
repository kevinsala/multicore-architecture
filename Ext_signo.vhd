----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:07:44 04/04/2014 
-- Design Name: 
-- Module Name:    Ext_signo - Behavioral 
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

entity Ext_signo is
    Port(
	 opcode : in STD_LOGIC_VECTOR (6 downto 0);
	 offsethi : in  STD_LOGIC_VECTOR (4 downto 0);
	 offsetm : in  STD_LOGIC_VECTOR (4 downto 0);
	 offsetlo : in  STD_LOGIC_VECTOR (9 downto 0);
         inm_ext : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end Ext_signo;

architecture Behavioral of Ext_signo is

begin

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

end Behavioral;

