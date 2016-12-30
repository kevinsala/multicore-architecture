library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux2_1bit is
	Port(
		Din0 : in STD_LOGIC;
		Din1 : in STD_LOGIC;
		ctrl : in STD_LOGIC;
		Dout : out STD_LOGIC
	);
end Mux2_1bit;

architecture Behavioral of Mux2_1bit is

begin	
	Dout <= Din1 when (ctrl ='1') else Din0;
end Behavioral;

