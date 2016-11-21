LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY comp_28bits IS
PORT(	input1 : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
		input2 : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
		output : OUT STD_LOGIC
	);
END comp_28bits;

ARCHITECTURE comp_28bits_behavior OF comp_28bits IS
BEGIN
output <= '1' WHEN input1 = input2 ELSE '0';
END comp_28bits_behavior;
