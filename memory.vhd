LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_arith.all;

ENTITY memory IS
    -- Assuming that:
    --  - Instruction cache never writes to memory
    PORT (clk : IN STD_LOGIC;
          reset : IN STD_LOGIC;
          debug_dump : IN STD_LOGIC;
          f_req : IN STD_LOGIC;
          d_req : IN STD_LOGIC;
          d_we : IN STD_LOGIC;
          f_done : OUT STD_LOGIC;
          d_done : OUT STD_LOGIC;
          f_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          d_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          d_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
          f_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
          d_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
    );
END memory;

ARCHITECTURE structure OF memory IS
    COMPONENT arbiter IS
        PORT (clk : IN STD_LOGIC;
              reset : IN STD_LOGIC;
              f_req : IN STD_LOGIC;
              d_req : IN STD_LOGIC;
              mem_req : OUT STD_LOGIC;
              d_we : IN STD_LOGIC;
              mem_we : OUT STD_LOGIC;
              f_done : OUT STD_LOGIC;
              d_done : OUT STD_LOGIC;
              mem_done : IN STD_LOGIC;
              f_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
              d_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
              mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
              d_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
              mem_data_in : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
              f_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
              d_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
              mem_data_out : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
        );
    END COMPONENT;

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

    SIGNAL mem_req : STD_LOGIC;
    SIGNAL mem_we : STD_LOGIC;
    SIGNAL mem_done : STD_LOGIC;
    SIGNAL mem_addr : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_data_in : STD_LOGIC_VECTOR(127 DOWNTO 0);
    SIGNAL mem_data_out : STD_LOGIC_VECTOR(127 DOWNTO 0);
BEGIN
    r: ram PORT MAP (
        clk => clk,
        reset => reset,
        debug_dump => debug_dump,
        req => mem_req,
        we => mem_we,
        done => mem_done,
        addr => mem_addr,
        data_in => mem_data_in,
        data_out => mem_data_out
    );

    arb: arbiter PORT MAP (
        clk => clk,
        reset => reset,
        f_req => f_req,
        d_req => d_req,
        mem_req => mem_req,
        d_we => d_we,
        mem_we => mem_we,
        f_done => f_done,
        d_done => d_done,
        mem_done => mem_done,
        f_addr => f_addr,
        d_addr => d_addr,
        mem_addr => mem_addr,
        d_data_in => d_data_in,
        mem_data_in => mem_data_in,
        f_data_out => f_data_out,
        d_data_out => d_data_out,
        mem_data_out => mem_data_out
    );

END structure;
