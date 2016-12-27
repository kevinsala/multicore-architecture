library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

