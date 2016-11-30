library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    Port(
    	reset : IN STD_LOGIC;
		IR_op_code : in  STD_LOGIC_VECTOR (6 downto 0);
		Branch : out  STD_LOGIC;
		ALUSrc_A : out STD_LOGIC;
		ALUSrc_B : out STD_LOGIC;
		MemWrite : out  STD_LOGIC;
		MemRead : out  STD_LOGIC;
		MemtoReg : out  STD_LOGIC;
		RegWrite : out  STD_LOGIC
	);
end UC;

architecture Behavioral of UC is

begin
UC_mux : process (IR_op_code)
begin
	if (reset = '1') then
		Branch <= '0';
		ALUSrc_A <= '0';
		ALUSrc_B <= '0';
		MemWrite <= '0';
		MemRead <= '0';
		MemtoReg <= '0';
		RegWrite <= '0';
	else
		CASE IR_op_code IS
			-- ADD
			WHEN "0000000" => Branch <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '0'; MemWrite <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '1';
			-- LDW
			WHEN "0010001" => Branch <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '1'; MemWrite <= '0'; MemRead <= '1'; MemtoReg <= '1'; RegWrite <= '1';
			-- STW
			WHEN "0010011" => Branch <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '1'; MemWrite <= '1'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0';
			-- BEQ
			WHEN "0110000" => Branch <= '1'; ALUSrc_A <= '0'; ALUSrc_B <= '1'; MemWrite <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0';
			-- NOP
			WHEN "1111111" => Branch <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '0'; MemWrite <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0';
			WHEN  OTHERS => Branch <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '0'; MemWrite <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0';
		END CASE;
	end if;
end process;
end Behavioral;

