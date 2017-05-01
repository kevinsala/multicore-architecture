LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.utils.all;

ENTITY reg_W IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		reg_we_in : IN STD_LOGIC;
		reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_we_in : IN STD_LOGIC;
		v : OUT STD_LOGIC;
		reg_we_out : OUT STD_LOGIC;
		reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_we_out : OUT STD_LOGIC
	);
END reg_W;

ARCHITECTURE structure OF reg_W IS
BEGIN
	p: PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				reg_we_out <= '0';
				reg_dest_out <= (OTHERS => '0');
				reg_data_out <= (OTHERS => '0');
				mem_we_out <= '0';
				v <= '0';
			ELSE
				IF we = '1' THEN
					reg_we_out <= reg_we_in;
					reg_dest_out <= reg_dest_in;
					reg_data_out <= reg_data_in;
					mem_we_out <= mem_we_in;
					v <= '1';
				ELSE
					v <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
END structure;
