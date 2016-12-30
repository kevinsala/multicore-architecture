library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4_32bits is
Port(
	DIn0 : in  STD_LOGIC_VECTOR (31 downto 0);
	DIn1 : in  STD_LOGIC_VECTOR (31 downto 0);
	DIn2 : in  STD_LOGIC_VECTOR (31 downto 0);
	DIn3 : in  STD_LOGIC_VECTOR (31 downto 0);
	ctrl : in  STD_LOGIC_VECTOR (1 downto 0);
	Dout : out  STD_LOGIC_VECTOR (31 downto 0)
);
end mux4_32bits;

architecture Behavioral of mux4_32bits is

begin
Dout <= DIn0 when (ctrl = "00")
	else DIn1 when (ctrl = "01")
	else DIn2 when (ctrl = "10")
	else DIn3;
end Behavioral;
