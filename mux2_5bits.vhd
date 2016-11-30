----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:13:42 04/07/2014 
-- Design Name: 
-- Module Name:    mux2_5bits - Behavioral 
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

entity mux2_5bits is
Port(
   DIn0 : in  STD_LOGIC_VECTOR (4 downto 0);
   DIn1 : in  STD_LOGIC_VECTOR (4 downto 0);
   ctrl : in  STD_LOGIC;
   Dout : out  STD_LOGIC_VECTOR (4 downto 0)
);
end mux2_5bits;

architecture Behavioral of mux2_5bits is

begin

Dout <= DIn1 when (ctrl ='1') else DIn0;
end Behavioral;

