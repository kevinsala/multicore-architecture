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
		data_in        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		re             : IN  STD_LOGIC;
		we             : IN  STD_LOGIC;
		is_byte        : IN  STD_LOGIC;
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
		mem_done       : IN  STD_LOGIC;
		cache_we       : OUT STD_LOGIC;
		cache_is_byte  : OUT STD_LOGIC;
		sb_data_out    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mux_data_out   : OUT STD_LOGIC
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
			done           : OUT STD_LOGIC;
			hit            : OUT STD_LOGIC;
			line_num       : OUT INTEGER RANGE 0 TO 3;
			line_we        : OUT STD_LOGIC;
			lru_line_num   : OUT INTEGER RANGE 0 TO 3;
			invalid_access : OUT STD_LOGIC;
			mem_req        : OUT STD_LOGIC;
			mem_addr       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we         : OUT STD_LOGIC;
			mem_done       : IN  STD_LOGIC;
			repl           : OUT STD_LOGIC;
			repl_addr      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			sb_done        : IN STD_LOGIC;
			sb_addr        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			sb_we          : IN STD_LOGIC
		);
	END COMPONENT;

	COMPONENT store_buffer IS
		PORT(
			clk            : IN STD_LOGIC;
			reset          : IN STD_LOGIC;
			addr           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_in        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			re             : IN STD_LOGIC;
			we             : IN STD_LOGIC;
			is_byte        : IN STD_LOGIC;
			sleep          : IN STD_LOGIC;
			repl           : IN STD_LOGIC;
			repl_addr      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			done           : OUT STD_LOGIC;
			hit            : OUT STD_LOGIC;
			tags_we        : OUT STD_LOGIC;
			tags_addr      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			cache_we       : OUT STD_LOGIC;
			cache_is_byte  : OUT STD_LOGIC;
			sb_data_out    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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
	SIGNAL real_re : STD_LOGIC;
	SIGNAL real_we : STD_LOGIC;
	SIGNAL done_tags : STD_LOGIC;
	SIGNAL done_sb : STD_LOGIC;
	SIGNAL hit_tags : STD_LOGIC;
	SIGNAL hit_sb : STD_LOGIC;
	SIGNAL mem_req_i : STD_LOGIC;

	-- Interface between tags and store buffer
	SIGNAL repl         : STD_LOGIC;
	SIGNAL repl_addr    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL sb_tags_we   : STD_LOGIC;
	SIGNAL sb_tags_addr : STD_LOGIC_VECTOR(31 DOWNTO 0);
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

	real_re <= re AND (priv_status OR dtlb_hit);
	real_we <= we AND (priv_status OR dtlb_hit);

	tags : cache_tags PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump,
		addr => PA_tlb,
		re => real_re,
		we => real_we,
		is_byte => is_byte,
		done => done_tags,
		hit => hit_tags,
		line_num => line_num,
		line_we => line_we,
		lru_line_num => lru_line_num,
		invalid_access => invalid_access,
		mem_req => mem_req_i,
		mem_addr => mem_addr,
		mem_we => mem_we,
		mem_done => mem_done,
		repl => repl,
		repl_addr => repl_addr,
		sb_done => done_sb,
		sb_addr => sb_tags_addr,
		sb_we => sb_tags_we
	);

	sb : store_buffer PORT MAP(
		clk => clk,
		reset => reset,
		addr => PA_tlb,
		data_in => data_in,
		re => real_re,
		we => real_we,
		is_byte => is_byte,
		sleep => mem_req_i,
		repl => repl,
		repl_addr => repl_addr,
		done => done_sb,
		hit => hit_sb,
		tags_we => sb_tags_we,
		tags_addr => sb_tags_addr,
		cache_we => cache_we,
		cache_is_byte => cache_is_byte,
		sb_data_out => sb_data_out
	);

	done <= done_tags AND done_sb;
	hit <= hit_tags AND hit_tags;
	mem_req <= mem_req_i;
	mux_data_out <= hit_sb;

	dtlb_miss <= mem_access AND NOT priv_status AND NOT dtlb_hit;

END lookup_stage_behavior;
