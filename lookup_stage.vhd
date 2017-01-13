LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.utils.all;

ENTITY lookup_stage IS
	PORT(
		clk            : IN  STD_LOGIC;
		reset          : IN  STD_LOGIC;
		debug_dump     : IN  STD_LOGIC;
		priv_status    : IN  STD_LOGIC;
		dtlb_we		   : IN  STD_LOGIC;
		addr           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		re             : IN  STD_LOGIC;
		we             : IN  STD_LOGIC;
		is_byte        : IN  STD_LOGIC;
		state          : IN  data_cache_state_t;
		state_nx       : OUT data_cache_state_t;
		hit            : OUT STD_LOGIC;
		done           : OUT STD_LOGIC;
		line_num       : OUT INTEGER RANGE 0 TO 3;
		line_we        : OUT STD_LOGIC;
		lru_line_num   : OUT INTEGER RANGE 0 TO 3;
		dtlb_miss	   : OUT STD_LOGIC;
		invalid_access : OUT STD_LOGIC;
		mem_req        : OUT STD_LOGIC;
		mem_addr       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_we         : OUT STD_LOGIC;
		mem_done       : IN  STD_LOGIC
	);
END lookup_stage;

ARCHITECTURE lookup_stage_behavior OF lookup_stage IS
	COMPONENT cache_tags IS
		PORT(
			clk            : IN  STD_LOGIC;
			reset          : IN  STD_LOGIC;
			debug_dump     : IN  STD_LOGIC;
			addr           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			re             : IN  STD_LOGIC;
			we             : IN  STD_LOGIC;
			is_byte        : IN  STD_LOGIC;
			state          : IN  data_cache_state_t;
			state_nx       : OUT data_cache_state_t;
			hit            : OUT STD_LOGIC;
			done           : OUT STD_LOGIC;
			line_num       : OUT INTEGER RANGE 0 TO 3;
			line_we        : OUT STD_LOGIC;
			lru_line_num   : OUT INTEGER RANGE 0 TO 3;
			invalid_access : OUT STD_LOGIC;
			mem_req        : OUT STD_LOGIC;
			mem_addr       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we         : OUT STD_LOGIC;
			mem_done       : IN  STD_LOGIC
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

	SIGNAL mem_access : STD_LOGIC;
	SIGNAL PA_tlb : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL dtlb_hit : STD_LOGIC;
	SIGNAL tags_re : STD_LOGIC;
	SIGNAL tags_we : STD_LOGIC;

BEGIN

	mem_access <= re OR we;

	dtlb : tlb PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump,
		mem_access => mem_access,
		VA => addr,
		priv_status_r => priv_status,
		PA => PA_tlb,
		tlb_hit_out => dtlb_hit,
		priv_status_w => priv_status,
		tlb_we => dtlb_we,
		data_in => addr(31 DOWNTO 12)
	);

	tags_re <= re AND (priv_status OR dtlb_hit);
	tags_we <= we AND (priv_status OR dtlb_hit);

	tags : cache_tags PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump,
		addr => PA_tlb,
		re => tags_re,
		we => tags_we,
		is_byte => is_byte,
		state => state,
		state_nx => state_nx,
		hit => hit,
		done => done,
		line_num => line_num,
		line_we => line_we,
		lru_line_num => lru_line_num,
		invalid_access => invalid_access,
		mem_req => mem_req,
		mem_addr => mem_addr,
		mem_we => mem_we,
		mem_done => mem_done
	);

	dtlb_miss <= mem_access AND NOT priv_status AND NOT dtlb_hit;

END lookup_stage_behavior;
