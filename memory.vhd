LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_arith.all;

ENTITY memory IS
    -- Assuming that:
    --  - Instruction cache never writes to memory
    PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		debug_dump : IN STD_LOGIC;
		req : IN STD_LOGIC;
		we : IN STD_LOGIC;
		done : OUT STD_LOGIC;
		addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
		data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
    );
END memory;

ARCHITECTURE structure OF memory IS
    COMPONENT ram IS
        PORT (clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            debug_dump : IN STD_LOGIC;
            req : IN STD_LOGIC;
            we : IN STD_LOGIC;
            done : OUT STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
        );
    END COMPONENT;
BEGIN
    r: ram PORT MAP (
        clk => clk,
        reset => reset,
        debug_dump => debug_dump,
        req => req,
        we => we,
        done => done,
        addr => addr,
        data_in => data_in,
        data_out => data_out
    );

END structure;
