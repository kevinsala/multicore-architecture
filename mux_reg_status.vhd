library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_reg_status is
	Port(
		pc_C : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status_C : IN STD_LOGIC;
		exc_C_E : IN STD_LOGIC;
		exc_code_C_E : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_C_E : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_C : IN STD_LOGIC;
		exc_code_C : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_C : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		debug_dump_C : IN STD_LOGIC;
		pc_M5 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status_M5 : IN STD_LOGIC;
		exc_M5_E : IN STD_LOGIC;
		exc_code_M5_E : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_M5_E : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_M5 : IN STD_LOGIC;
		exc_code_M5 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_M5 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		debug_dump_M5 : IN STD_LOGIC;
		ctrl : IN STD_LOGIC;
		pc_M5_C : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status_M5_C : OUT STD_LOGIC;
		exc_M5_C_E : OUT STD_LOGIC;
		exc_code_M5_C_E : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_M5_C_E : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_M5_C : OUT STD_LOGIC;
		exc_code_M5_C : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_M5_C : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		debug_dump_M5_C : OUT STD_LOGIC
	);
end mux_reg_status;

architecture Behavioral of mux_reg_status is

begin	
	pc_M5_C <= pc_M5 when (ctrl ='1') else pc_C;
	priv_status_M5_C <= priv_status_M5 when (ctrl ='1') else priv_status_C;
	exc_M5_C_E <= exc_M5_E when (ctrl ='1') else exc_C_E;
	exc_code_M5_C_E <= exc_code_M5_E when (ctrl ='1') else exc_code_C_E;
	exc_data_M5_C_E <= exc_data_M5_E when (ctrl ='1') else exc_data_C_E;
	exc_M5_C <= exc_M5 when (ctrl ='1') else exc_C;
	exc_code_M5_C <= exc_code_M5 when (ctrl ='1') else exc_code_C;
	exc_data_M5_C <= exc_data_M5 when (ctrl ='1') else exc_data_C;
	debug_dump_M5_C <= debug_dump_M5 when (ctrl ='1') else debug_dump_C;
end Behavioral;