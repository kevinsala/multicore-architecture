LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_arith.all;

ENTITY arbiter IS
    -- Assuming that:
    --  - Instruction cache never writes to memory
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
END arbiter;

ARCHITECTURE structure OF arbiter IS
    TYPE state_t IS (IDLE, REQD, REQI);

    SIGNAL state : state_t := IDLE;
BEGIN
    p : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF state = IDLE THEN
                IF d_req = '1' THEN
                    state <= REQD;
                ELSIF f_req = '1' THEN
                    state <= REQI;
                END IF;
            ELSIF state = REQD THEN
                IF mem_done = '1' OR d_req = '0' THEN
                    state <= IDLE;
                END IF;
            ELSIF state = REQI THEN
                IF mem_done = '1' OR f_req = '0' THEN
                    state <= IDLE;
                END IF;
            END IF;
        END IF;
    END PROCESS p;

    WITH state SELECT mem_req <=
        d_req WHEN REQD,
        f_req WHEN REQI,
        '0' WHEN OTHERS;

    WITH state SELECT mem_we <=
        d_we WHEN REQD,
        '0' WHEN OTHERS;

    WITH state SELECT f_done <=
        mem_done WHEN REQI,
        '0' WHEN OTHERS;

    WITH state SELECT d_done <=
        mem_done WHEN REQD,
        '0' WHEN OTHERS;

    WITH state SELECT mem_addr <=
        f_addr WHEN REQI,
        d_addr WHEN REQD,
        (OTHERS => 'Z') WHEN OTHERS;

    WITH state SELECT mem_data_in <=
        d_data_in WHEN REQD,
        (OTHERS => 'Z') WHEN OTHERS;

    f_data_out <= mem_data_out;
    d_data_out <= mem_data_out;
END structure;
