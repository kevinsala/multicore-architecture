LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg_FD IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		inst_v_in : IN STD_LOGIC;
		inst_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		inst_v_out : OUT STD_LOGIC;
		inst_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END reg_FD;

ARCHITECTURE structure OF reg_FD IS
BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				inst_v_out <= '0';
				inst_out <= x"FE000000";
			ELSE
				IF we = '1' THEN
					inst_v_out <= inst_v_in;
					inst_out <= inst_in;
				END IF;
			END IF;
		END IF;
	END PROCESS p;
end structure;
