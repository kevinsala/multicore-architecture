LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg_priv_status IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		exc_W : IN STD_LOGIC;
		iret_A : IN STD_LOGIC;
		priv_status : OUT STD_LOGIC
	);
END reg_priv_status;

ARCHITECTURE structure OF reg_priv_status IS
	SIGNAL priv_status_int : STD_LOGIC;
BEGIN
	p: PROCESS(clk)
	BEGIN
		IF falling_edge(clk) THEN
			IF reset = '1' THEN
				priv_status_int <= '0';
			ELSE
				IF iret_A = '1' THEN
					priv_status_int <= '0';
				ELSIF exc_W = '1' THEN
					priv_status_int <= '1';
				END IF;
			END IF;
		END IF;
	END PROCESS p;

	priv_status <= priv_status_int;
END structure;

