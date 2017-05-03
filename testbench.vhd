LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE structure OF testbench IS
    COMPONENT inkel_pentiun is
        PORT(
    		clk     : IN  STD_LOGIC;
    		reset   : IN  STD_LOGIC;
    		pc_out  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    	);
	END COMPONENT;

    SIGNAL clk, reset :  STD_LOGIC;
    SIGNAL pc :  STD_LOGIC_VECTOR(31 DOWNTO 0);

    CONSTANT CLK_period : TIME := 1 ns;
BEGIN
    -- Component Instantiation
    uut: inkel_pentiun PORT MAP(clk => clk, reset => reset, pc_out => pc);

    -- Clock process definitions
    CLK_process : PROCESS
    BEGIN
	    clk <= '1';
	    WAIT FOR CLK_period / 2;
        clk <= '0';
	    WAIT FOR CLK_period / 2;
    END PROCESS;

    stim_proc: PROCESS
    BEGIN
        reset <= '1';
        WAIT FOR CLK_period * 2;
	    reset <= '0';
	    WAIT FOR CLK_period * 20;
	    WAIT;
    END PROCESS;
END;
