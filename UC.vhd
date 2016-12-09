LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY UC IS
    PORT(
    	reset : IN STD_LOGIC;
		IR_op_code : IN  STD_LOGIC_VECTOR (6 downto 0);
		Branch : OUT  STD_LOGIC;
		Jump : OUT STD_LOGIC;
		ALUSrc_A : OUT STD_LOGIC;
		ALUSrc_B : OUT STD_LOGIC;
		Mul : OUT STD_LOGIC;
		MemWrite : OUT  STD_LOGIC;
		Byte : OUT STD_LOGIC;
		MemRead : OUT  STD_LOGIC;
		MemtoReg : OUT  STD_LOGIC;
		RegWrite : OUT  STD_LOGIC
	);
END UC;

ARCHITECTURE Behavioral OF UC IS

BEGIN
UC_mux : PROCESS (IR_op_code)
BEGIN
	if (reset = '1') then
		Branch <= '0';
		Jump <= '0';
		ALUSrc_A <= '0';
		ALUSrc_B <= '0';
		Mul <= '0';
		MemWrite <= '0';
		Byte <= '0';
		MemRead <= '0';
		MemtoReg <= '0';
		RegWrite <= '0';
	else
		CASE IR_op_code IS
			-- ADD
			WHEN "0000000" => Branch <= '0'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '0'; Mul <= '0'; MemWrite <= '0'; Byte <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '1';
			-- SUB
			WHEN "0000001" => Branch <= '0'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '0'; Mul <= '0'; MemWrite <= '0'; Byte <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '1';
			-- MUL
			WHEN "0000010" => Branch <= '0'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '0'; Mul <= '1'; MemWrite <= '0'; Byte <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '1';
			-- LDB
			WHEN "0010000" => Branch <= '0'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '1'; Mul <= '0'; MemWrite <= '0'; Byte <= '1'; MemRead <= '1'; MemtoReg <= '1'; RegWrite <= '1';
			-- LDW
			WHEN "0010001" => Branch <= '0'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '1'; Mul <= '0'; MemWrite <= '0'; Byte <= '0'; MemRead <= '1'; MemtoReg <= '1'; RegWrite <= '1';
			-- STB
			WHEN "0010010" => Branch <= '0'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '1'; Mul <= '0'; MemWrite <= '1'; Byte <= '1'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0';
			-- STW
			WHEN "0010011" => Branch <= '0'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '1'; Mul <= '0'; MemWrite <= '1'; Byte <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0';
			-- MOV
			WHEN "0010100" => Branch <= '0'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '1'; Mul <= '0'; MemWrite <= '0'; Byte <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '1';
			-- BEQ
			WHEN "0110000" => Branch <= '1'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '1'; Mul <= '0'; MemWrite <= '0'; Byte <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0';
			-- JUMP
			WHEN "0110001" => Branch <= '0'; Jump <= '1'; ALUSrc_A <= '0'; ALUSrc_B <= '1'; Mul <= '0'; MemWrite <= '0'; Byte <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0';
			-- NOP
			WHEN "1111111" => Branch <= '0'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '0'; Mul <= '0'; MemWrite <= '0'; Byte <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0';
			WHEN  OTHERS => Branch <= '0'; Jump <= '0'; ALUSrc_A <= '0'; ALUSrc_B <= '0'; Mul <= '0'; MemWrite <= '0'; Byte <= '0'; MemRead <= '0'; MemtoReg <= '0'; RegWrite <= '0';
		END CASE;
	end if;
END PROCESS;
END Behavioral;

