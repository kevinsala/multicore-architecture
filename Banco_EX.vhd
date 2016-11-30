LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Banco_EX IS
    PORT(
		clk : IN  STD_LOGIC;
		reset : IN  STD_LOGIC;
		load : IN  STD_LOGIC;
		busA : IN  STD_LOGIC_VECTOR (31 downto 0);
		busB : IN  STD_LOGIC_VECTOR (31 downto 0);
		busA_EX : OUT  STD_LOGIC_VECTOR (31 downto 0);
		busB_EX : OUT  STD_LOGIC_VECTOR (31 downto 0);
		ALUSrc_A_ID : IN  STD_LOGIC;
		ALUSrc_B_ID : IN  STD_LOGIC;
		MemWrite_ID : IN  STD_LOGIC;
		MemRead_ID : IN  STD_LOGIC;
		MemtoReg_ID : IN  STD_LOGIC;
		RegWrite_ID : IN  STD_LOGIC;
		inm_ext: IN  std_logic_vector(31 downto 0);
		inm_ext_EX: OUT  std_logic_vector(31 downto 0);
		ALUSrc_A_EX : OUT STD_LOGIC;
		ALUSrc_B_EX : OUT STD_LOGIC;
		MemWrite_EX : OUT STD_LOGIC;
		MemRead_EX : OUT STD_LOGIC;
		MemtoReg_EX : OUT STD_LOGIC;
		RegWrite_EX : OUT STD_LOGIC;
		ALUctrl_ID: IN STD_LOGIC_VECTOR (2 downto 0);
	 	ALUctrl_EX: OUT STD_LOGIC_VECTOR (2 downto 0);
        Reg_Rs2_ID : IN  STD_LOGIC_VECTOR (4 downto 0);
        Reg_Rd_ID : IN STD_LOGIC_VECTOR (4 downto 0);
        Reg_Rs1_ID : IN STD_LOGIC_VECTOR (4 downto 0);
        Reg_Rs2_EX : OUT STD_LOGIC_VECTOR (4 downto 0);
        Reg_Rd_EX : OUT STD_LOGIC_VECTOR (4 downto 0);
        Reg_Rs1_EX : OUT STD_LOGIC_VECTOR (4 downto 0)); 
END Banco_EX;

ARCHITECTURE Behavioral OF Banco_EX IS

BEGIN
SYNC_PROC: PROCESS (clk)
	BEGIN
		if (clk'event and clk = '1') then
			if (reset = '1') then
				busA_EX <= "00000000000000000000000000000000";
				busB_EX <= "00000000000000000000000000000000";
				inm_ext_EX <= "00000000000000000000000000000000";
				ALUSrc_A_EX <= '0';
				ALUSrc_B_EX <= '0';
				MemWrite_EX <= '0';
				MemRead_EX <= '0';
				MemtoReg_EX <= '0';
				RegWrite_EX <= '0';
				Reg_Rs2_EX <= "00000";
				Reg_Rd_EX <= "00000";
				Reg_Rs1_EX <= "00000";
				ALUctrl_EX <= "000";
			else
            	if (load='1') then 
            		busA_EX <= busA;
            		busB_EX <= busB;
            		ALUSrc_A_EX <= ALUSrc_A_ID;
            		ALUSrc_B_EX <= ALUSrc_B_ID;
            		MemWrite_EX <= MemWrite_ID;
            		MemRead_EX <= MemRead_ID;
            		MemtoReg_EX <= MemtoReg_ID;
            		RegWrite_EX <= RegWrite_ID;
            		Reg_Rs2_EX <= Reg_Rs2_ID;
            		Reg_Rd_EX <= Reg_Rd_ID;
            		Reg_Rs1_EX <= Reg_Rs1_ID;
            		ALUctrl_EX <= ALUctrl_ID;
            		inm_ext_EX <= inm_ext;
            	end if;	
            end if;
        end if;
    END PROCESS;

END Behavioral;

