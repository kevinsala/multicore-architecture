LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.utils.all;

ENTITY cache_stage IS
	PORT(
		clk             : IN  STD_LOGIC;
		reset           : IN  STD_LOGIC;
		priv_status     : IN  STD_LOGIC;
		addr            : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_in         : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		re              : IN  STD_LOGIC;
		we              : IN  STD_LOGIC;
		is_byte         : IN  STD_LOGIC;
		id              : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		done            : OUT STD_LOGIC;
		invalid_access  : OUT STD_LOGIC;
		mem_req         : OUT STD_LOGIC;
		mem_addr        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_we          : OUT STD_LOGIC;
		mem_done        : IN  STD_LOGIC;
		mem_data_in     : IN  STD_LOGIC_VECTOR(127 DOWNTO 0);
		mem_data_out    : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
		sb_store_id     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		sb_store_commit : IN  STD_LOGIC;
		sb_squash       : IN  STD_LOGIC
	);
END cache_stage;

ARCHITECTURE cache_stage_behavior OF cache_stage IS
	COMPONENT cache_data IS
		PORT(
			clk            : IN  STD_LOGIC;
			reset          : IN  STD_LOGIC;
			addr           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			re             : IN  STD_LOGIC;
			we             : IN  STD_LOGIC;
			is_byte        : IN  STD_LOGIC;
			data_out       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			hit            : OUT STD_LOGIC;
			done           : OUT STD_LOGIC;
			invalid_access : OUT STD_LOGIC;
			mem_req        : OUT STD_LOGIC;
			mem_addr       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we         : OUT STD_LOGIC;
			mem_done       : IN  STD_LOGIC;
			mem_data_in    : IN  STD_LOGIC_VECTOR(127 DOWNTO 0);
			mem_data_out   : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			repl           : OUT STD_LOGIC;
			repl_addr      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			sb_done        : IN  STD_LOGIC;
			sb_addr        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			sb_we          : IN  STD_LOGIC;
			sb_is_byte     : IN  STD_LOGIC;
			sb_data_in     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT store_buffer IS
		PORT(
			clk            : IN  STD_LOGIC;
			reset          : IN  STD_LOGIC;
			addr           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_in        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_out       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			re             : IN  STD_LOGIC;
			we             : IN  STD_LOGIC;
			is_byte        : IN  STD_LOGIC;
			invalid_access : IN  STD_LOGIC;
			id             : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			sleep          : IN  STD_LOGIC;
			repl           : IN  STD_LOGIC;
			repl_addr      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			done           : OUT STD_LOGIC;
			hit            : OUT STD_LOGIC;
			cache_addr     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			cache_we       : OUT STD_LOGIC;
			cache_is_byte  : OUT STD_LOGIC;
			cache_data     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			store_id       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			store_commit   : IN  STD_LOGIC;
			squash         : IN  STD_LOGIC
		);
	END COMPONENT;

	SIGNAL cache_hit : STD_LOGIC;
	SIGNAL cache_done : STD_LOGIC;
	SIGNAL cache_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL sb_hit : STD_LOGIC;
	SIGNAL sb_done : STD_LOGIC;
	SIGNAL sb_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL invalid_access_i : STD_LOGIC;
	SIGNAL mem_req_i : STD_LOGIC;

	-- Interface between cache and store buffer
	SIGNAL cache_sb_repl      : STD_LOGIC;
	SIGNAL cache_sb_repl_addr : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL sb_cache_addr : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL sb_cache_we   : STD_LOGIC;
	SIGNAL sb_cache_is_byte : STD_LOGIC;
	SIGNAL sb_cache_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	cache : cache_data PORT MAP(
		clk => clk,
		reset => reset,
		addr => addr,
		re => re,
		we => we,
		is_byte => is_byte,
		data_out => cache_data_out,
		hit => cache_hit,
		done => cache_done,
		invalid_access => invalid_access_i,
		mem_req => mem_req_i,
		mem_addr => mem_addr,
		mem_we => mem_we,
		mem_done => mem_done,
		mem_data_in => mem_data_in,
		mem_data_out => mem_data_out,
		repl => cache_sb_repl,
		repl_addr => cache_sb_repl_addr,
		sb_done => sb_done,
		sb_addr => sb_cache_addr,
		sb_we => sb_cache_we,
		sb_is_byte => sb_cache_is_byte,
		sb_data_in => sb_cache_data
	);

	sb : store_buffer PORT MAP(
		clk => clk,
		reset => reset,
		addr => addr,
		data_in => data_in,
		data_out => sb_data_out,
		re => re,
		we => we,
		is_byte => is_byte,
		invalid_access => invalid_access_i,
		id => id,
		sleep => mem_req_i,
		repl => cache_sb_repl,
		repl_addr => cache_sb_repl_addr,
		done => sb_done,
		hit => sb_hit,
		cache_addr => sb_cache_addr,
		cache_we => sb_cache_we,
		cache_is_byte => sb_cache_is_byte,
		cache_data => sb_cache_data,
		store_id => sb_store_id,
		store_commit => sb_store_commit,
		squash => sb_squash
	);

	done <= cache_done AND sb_done;
	data_out <= sb_data_out WHEN sb_hit = '1' ELSE cache_data_out;
	invalid_access <= invalid_access_i;
	mem_req <= mem_req_i;

END cache_stage_behavior;
