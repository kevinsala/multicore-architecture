LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg_status IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status_in : IN STD_LOGIC;
		exc_in : IN STD_LOGIC;
		exc_code_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		priv_status_out : OUT STD_LOGIC;
		exc_out : OUT STD_LOGIC;
		exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END reg_status;

ARCHITECTURE structure OF reg_status IS
BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				pc_out <= x"00000000";
				priv_status_out <= '0';
				exc_out <= '0';
			ELSE
				IF we = '1' THEN
					pc_out <= pc_in;
					priv_status_out <= priv_status_in;
					exc_out <= exc_in;
					exc_code_out <= exc_code_in;
					exc_data_out <= exc_data_in;
				END IF;
			END IF;
		END IF;
	END PROCESS p;
END structure;

