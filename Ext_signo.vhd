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
	 inm : in  STD_LOGIC_VECTOR (15 downto 0);
         inm_ext : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end Ext_signo;

architecture Behavioral of Ext_signo is

begin

inm_ext(15 downto 0) <= inm;
inm_ext(31 downto 16) <= "0000000000000000" when inm(15)='0' else "1111111111111111";

end Behavioral;

