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
        load_PC : OUT STD_LOGIC
    );
END fetch;

ARCHITECTURE structure OF fetch IS
    COMPONENT ram IS
        PORT (clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            req : IN STD_LOGIC;
            we : IN STD_LOGIC;
            done : OUT STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL done_int: STD_LOGIC;
    SIGNAL request: STD_LOGIC := '1';
    SIGNAL mem_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    r: ram PORT MAP(
        clk => clk,
        reset => reset,
        req => request,
        we => '0',
        data_in => (OTHERS => 'Z'),
        done => done_int,
        addr => pc,
        data_out => mem_out
    );

    -- When there is a branch in the D stage, abort and restart the request
    request <= NOT branch_D;

    WITH done_int SELECT inst <=
        mem_out WHEN '1',
        (OTHERS => '0') WHEN OTHERS;

    load_PC <= done_int;
END structure;
