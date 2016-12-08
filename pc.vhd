LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY pc IS
    PORT (clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        addr_jump : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        jump_D : IN STD_LOGIC;
        branch_D : IN STD_LOGIC;
        Z_D : IN STD_LOGIC;
        load_PC_F : IN STD_LOGIC;
        load_PC_UD : IN STD_LOGIC;
        pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END pc;

ARCHITECTURE structure OF pc IS
    CONSTANT addr_boot : STD_LOGIC_VECTOR := x"00001000";
    CONSTANT addr_exc : STD_LOGIC_VECTOR := x"00002000";

    SIGNAL pc_int : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    p : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                pc_int <= addr_boot;
            ELSE
                pc_int <= pc_next;
            END IF;
        END IF;
    END PROCESS p;


    pc_next <= addr_jump WHEN (Z_D AND branch_D) = '1' OR jump_D = '1'
                ELSE pc_int + 4 WHEN load_PC_F = '1' AND load_PC_UD = '1'
                ELSE pc_int;

    pc <= pc_int;
END structure;
