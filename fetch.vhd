LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;
USE work.utils.ALL;

ENTITY fetch IS
    PORT (clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        debug_dump : IN STD_LOGIC;
        priv_status_r : IN STD_LOGIC;
        priv_status_w : IN STD_LOGIC;
        itlb_we : IN STD_LOGIC;
        itlb_data_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_taken : IN STD_LOGIC;
        inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        itlb_miss_out : OUT STD_LOGIC;
        inst_v : OUT STD_LOGIC;
        invalid_access : OUT STD_LOGIC;
        mem_req : OUT STD_LOGIC;
        mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_done : IN STD_LOGIC;
        mem_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
    );
END fetch;

ARCHITECTURE structure OF fetch IS
    COMPONENT cache_inst IS
        PORT (clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			debug_dump : IN STD_LOGIC;
			addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            itlb_miss : IN STD_LOGIC;
			data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			done : OUT STD_LOGIC;
			invalid_access : OUT STD_LOGIC;
			state : IN inst_cache_state_t;
			state_nx : OUT inst_cache_state_t;
			mem_req : OUT STD_LOGIC;
			mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	        mem_req_abort : IN STD_LOGIC;
			mem_done : IN STD_LOGIC;
			mem_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

    COMPONENT tlb IS
        PORT(
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            debug_dump : IN STD_LOGIC;
            mem_access : IN STD_LOGIC;
            VA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            priv_status_r : IN STD_LOGIC;
            PA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            tlb_hit_out : OUT STD_LOGIC;
            priv_status_w : IN STD_LOGIC;
            tlb_we : IN STD_LOGIC;
            data_in : IN STD_LOGIC_VECTOR(19 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL cache_done : STD_LOGIC;
    SIGNAL cache_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cache_state : inst_cache_state_t;
    SIGNAL cache_state_nx : inst_cache_state_t;
    --itlb signals
    SIGNAL PA_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL itlb_hit : STD_LOGIC;
    SIGNAL itlb_miss : STD_LOGIC;

BEGIN
    p : PROCESS(clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				cache_state <= READY;
			ELSE
				cache_state <= cache_state_nx;
			END IF;
		END IF;
	END PROCESS p;

    itlb : tlb PORT MAP(
        clk => clk,
        reset => reset,
        debug_dump => debug_dump,
        mem_access => '1',
        VA => pc,
        priv_status_r => priv_status_r,
        PA => PA_pc,
        tlb_hit_out => itlb_hit,
        priv_status_w => priv_status_w,
        tlb_we => itlb_we,
        data_in => itlb_data_in(31 DOWNTO 12)
    );

    itlb_miss <= NOT priv_status_r AND NOT itlb_hit;

    ci: cache_inst PORT MAP(
        clk => clk,
        reset => reset,
        debug_dump => debug_dump,
        addr => PA_pc,
        itlb_miss => itlb_miss,
        data_out => cache_data_out,
        done => cache_done,
        invalid_access => invalid_access,
        state => cache_state,
        state_nx => cache_state_nx,
        mem_req => mem_req,
        mem_req_abort => branch_taken,
        mem_addr => mem_addr,
        mem_done => mem_done,
        mem_data_in => mem_data_in
    );

    inst <= cache_data_out;
    inst_v <= cache_done OR itlb_miss;
    itlb_miss_out <= itlb_miss;
END structure;
