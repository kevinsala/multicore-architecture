library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2_5bits is
	Port(
		Din0 : in STD_LOGIC_VECTOR(4 downto 0);
		Din1 : in STD_LOGIC_VECTOR(4 downto 0);
		ctrl : in STD_LOGIC;
		Dout : out STD_LOGIC_VECTOR(4 downto 0)
	);
end mux2_5bits;

architecture Behavioral of mux2_5bits is

begin	
	Dout <= Din1 when (ctrl ='1') else Din0;
end Behavioral;

