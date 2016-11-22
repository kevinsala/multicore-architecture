LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_textio.all;
USE std.textio.all;

ENTITY fetch IS
    PORT (clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_D : IN STD_LOGIC;
        inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        load_PC : OUT STD_LOGIC;
        mem_req : OUT STD_LOGIC;
        mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_done : IN STD_LOGIC;
        mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END fetch;

ARCHITECTURE structure OF fetch IS
    SIGNAL request: STD_LOGIC := '1';
BEGIN
    -- When there is a branch in the D stage, abort and restart the request
    request <= NOT branch_D;

    WITH mem_done SELECT inst <=
        mem_data_in WHEN '1',
        (OTHERS => '0') WHEN OTHERS;

    load_PC <= mem_done;
    mem_req <= request;
    mem_addr <= pc;
END structure;
