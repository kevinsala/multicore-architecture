LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;
USE work.utils.ALL;

ENTITY fetch IS
	PORT (
		clk            : IN    STD_LOGIC;
		reset          : IN    STD_LOGIC;
		priv_status_r  : IN    STD_LOGIC;
		priv_status_w  : IN    STD_LOGIC;
		pc             : IN    STD_LOGIC_VECTOR(31  DOWNTO 0);
		pred_error   : IN    STD_LOGIC;
		inst           : OUT   STD_LOGIC_VECTOR(31  DOWNTO 0);
		inst_v         : OUT   STD_LOGIC;
		invalid_access : OUT   STD_LOGIC;
		arb_req        : OUT   STD_LOGIC;
		arb_ack        : IN    STD_LOGIC;
		mem_cmd        : INOUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		mem_addr       : INOUT STD_LOGIC_VECTOR(31  DOWNTO 0);
		mem_done       : INOUT STD_LOGIC;
		mem_data       : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);
END fetch;

ARCHITECTURE structure OF fetch IS
	COMPONENT cache_inst IS
		PORT (
			clk            : IN    STD_LOGIC;
			reset          : IN    STD_LOGIC;
			addr           : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_out       : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
			done           : OUT   STD_LOGIC;
			invalid_access : OUT   STD_LOGIC;
			state          : IN    inst_cache_state_t;
			state_nx       : OUT   inst_cache_state_t;
			arb_req        : OUT   STD_LOGIC;
			arb_ack        : IN    STD_LOGIC;
			mem_cmd        : INOUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			mem_req_abort  : IN    STD_LOGIC;
			mem_addr       : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_done       : INOUT STD_LOGIC;
			mem_data       : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

    SIGNAL cache_done : STD_LOGIC;
    SIGNAL cache_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cache_state : inst_cache_state_t;
    SIGNAL cache_state_nx : inst_cache_state_t;

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

    ci : cache_inst PORT MAP(
        clk => clk,
        reset => reset,
        addr => pc,
        data_out => cache_data_out,
        done => cache_done,
        invalid_access => invalid_access,
        state => cache_state,
        state_nx => cache_state_nx,
		arb_req => arb_req,
		arb_ack => arb_ack,
		mem_cmd => mem_cmd,
        mem_req_abort => pred_error,
        mem_addr => mem_addr,
        mem_done => mem_done,
        mem_data => mem_data
    );

    inst <= cache_data_out;
    inst_v <= cache_done;

END structure;
