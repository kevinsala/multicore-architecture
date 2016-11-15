----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:40:35 05/14/2014 
-- Design Name: 
-- Module Name:    Mux_2_3bits - Behavioral 
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

entity Mux_2_3bits is
	Port(
		Din0 : in STD_LOGIC_VECTOR(2 downto 0);
		Din1 : in STD_LOGIC_VECTOR(2 downto 0);
		ctrl : in STD_LOGIC;
		Dout : out STD_LOGIC_VECTOR(2 downto 0)
	);
end Mux_2_3bits;

architecture Behavioral of Mux_2_3bits is

begin	
	Dout <= Din1 when (ctrl ='1') else Din0;
end Behavioral;

