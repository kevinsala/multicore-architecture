----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:14:14 04/04/2014 
-- Design Name: 
-- Module Name:    adder32 - Behavioral 
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder32 is
    Port(
	 Din0 : in  STD_LOGIC_VECTOR (31 downto 0);
         Din1 : in  STD_LOGIC_VECTOR (31 downto 0);
         Dout : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end adder32;

architecture Behavioral of adder32 is

begin
Dout <= Din0+Din1;

end Behavioral;

