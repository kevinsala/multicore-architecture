----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:10:56 04/04/2014 
-- Design Name: 
-- Module Name:    bits_shifter - Behavioral 
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

entity two_bits_shifter is
    Port(
	 Din : in  STD_LOGIC_VECTOR (31 downto 0);
         Dout : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end two_bits_shifter;

architecture Behavioral of two_bits_shifter is

begin
Dout(1 downto 0) <= "00";
Dout(31 downto 2) <= Din(29 downto 0);

end Behavioral;

