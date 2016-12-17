LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.utils.all;

ENTITY cache_stage IS
	PORT(
		clk      : IN STD_LOGIC;
		reset    : IN STD_LOGIC;
		addr     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_in  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		re       : IN STD_LOGIC;
		we       : IN STD_LOGIC;
		is_byte  : IN STD_LOGIC;
		state    : IN data_cache_state_t;
		state_nx : OUT data_cache_state_t;
		done     : OUT STD_LOGIC;
		mem_req  : OUT STD_LOGIC;
		mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_we   : OUT STD_LOGIC;
		mem_done : IN STD_LOGIC;
		mem_data_in  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
		mem_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);
END cache_stage;

ARCHITECTURE cache_stage_behavior OF cache_stage IS
	COMPONENT cache_data IS
		PORT(
			clk      : IN STD_LOGIC;
			reset    : IN STD_LOGIC;
			addr     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_in  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			re       : IN STD_LOGIC;
			we       : IN STD_LOGIC;
			is_byte  : IN STD_LOGIC;
			state    : IN data_cache_state_t;
			state_nx : OUT data_cache_state_t;
			done     : OUT STD_LOGIC;
			mem_req  : OUT STD_LOGIC;
			mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we   : OUT STD_LOGIC;
			mem_done : IN STD_LOGIC;
			mem_data_in  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			mem_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;
BEGIN
	cache : cache_data PORT MAP(
			clk => clk,
			reset => reset,
			addr => addr,
			data_in => data_in,
			data_out => data_out,
			re => re,
			we => we,
			is_byte => is_byte,
			state => state,
			state_nx => state_nx,
			done => done,
			mem_req => mem_req,
			mem_addr => mem_addr,
			mem_we => mem_we,
			mem_done => mem_done,
			mem_data_in => mem_data_in,
			mem_data_out => mem_data_out);

END cache_stage_behavior;
