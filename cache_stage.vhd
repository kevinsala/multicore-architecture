LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.utils.all;

ENTITY cache_stage IS
	PORT (
		clk             : IN    STD_LOGIC;
		reset           : IN    STD_LOGIC;
		priv_status     : IN    STD_LOGIC;
		addr            : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_in         : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out        : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
		re              : IN    STD_LOGIC;
		we              : IN    STD_LOGIC;
		atomic          : IN    STD_LOGIC;
		id              : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
		done            : OUT   STD_LOGIC;
		invalid_access  : OUT   STD_LOGIC;
		arb_req         : OUT   STD_LOGIC;
		arb_ack         : IN    STD_LOGIC;
		mem_cmd         : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
		mem_addr        : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_done        : IN    STD_LOGIC;
		mem_data        : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0);
		sb_store_id     : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
		sb_store_commit : IN    STD_LOGIC;
		sb_squash       : IN    STD_LOGIC
	);
END cache_stage;

ARCHITECTURE cache_stage_behavior OF cache_stage IS
	COMPONENT cache_data IS
		PORT(
			clk            : IN    STD_LOGIC;
			reset          : IN    STD_LOGIC;
			addr           : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
			re             : IN    STD_LOGIC;
			we             : IN    STD_LOGIC;
			data_out       : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
			hit            : OUT   STD_LOGIC;
			done           : OUT   STD_LOGIC;
			invalid_access : OUT   STD_LOGIC;
			arb_req        : OUT   STD_LOGIC;
			arb_ack        : IN    STD_LOGIC;
			mem_cmd        : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
			mem_addr       : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_done       : IN    STD_LOGIC;
			mem_data       : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			repl           : OUT   STD_LOGIC;
			repl_addr      : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
			sb_done        : IN    STD_LOGIC;
			sb_addr        : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
			sb_we          : IN    STD_LOGIC;
			sb_data_in     : IN    STD_LOGIC_VECTOR(31 DOWNTO 0)
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
			atomic         : IN  STD_LOGIC;
			invalid_access : IN  STD_LOGIC;
			id             : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			sleep          : IN  STD_LOGIC;
			repl           : IN  STD_LOGIC;
			repl_addr      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			done           : OUT STD_LOGIC;
			hit            : OUT STD_LOGIC;
			cache_addr     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			cache_we       : OUT STD_LOGIC;
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
	SIGNAL sb_sleep : STD_LOGIC;
	SIGNAL sb_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL invalid_access_i : STD_LOGIC;
	SIGNAL arb_req_i : STD_LOGIC;
	SIGNAL mem_cmd_i : STD_LOGIC_VECTOR(2 DOWNTO 0);

	-- Interface between cache and store buffer
	SIGNAL cache_sb_repl      : STD_LOGIC;
	SIGNAL cache_sb_repl_addr : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL sb_cache_addr : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL sb_cache_we   : STD_LOGIC;
	SIGNAL sb_cache_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	cache : cache_data PORT MAP(
		clk => clk,
		reset => reset,
		addr => addr,
		re => re,
		we => we,
		data_out => cache_data_out,
		hit => cache_hit,
		done => cache_done,
		invalid_access => invalid_access_i,
		arb_req => arb_req_i,
		arb_ack => arb_ack,
		mem_cmd => mem_cmd_i,
		mem_addr => mem_addr,
		mem_done => mem_done,
		mem_data => mem_data,
		repl => cache_sb_repl,
		repl_addr => cache_sb_repl_addr,
		sb_done => sb_done,
		sb_addr => sb_cache_addr,
		sb_we => sb_cache_we,
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
		atomic => atomic,
		invalid_access => invalid_access_i,
		id => id,
		sleep => sb_sleep,
		repl => cache_sb_repl,
		repl_addr => cache_sb_repl_addr,
		done => sb_done,
		hit => sb_hit,
		cache_addr => sb_cache_addr,
		cache_we => sb_cache_we,
		cache_data => sb_cache_data,
		store_id => sb_store_id,
		store_commit => sb_store_commit,
		squash => sb_squash
	);

	done <= cache_done AND sb_done;
	data_out <= sb_data_out WHEN sb_hit = '1' ELSE cache_data_out;
	invalid_access <= invalid_access_i;
	arb_req <= arb_req_i;
	mem_cmd <= mem_cmd_i;

	sb_sleep <= '1' WHEN arb_req_i = '1' OR mem_cmd_i = CMD_GET OR mem_cmd_i = CMD_PUT ELSE '0';
END cache_stage_behavior;
