LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_arith.all;

ENTITY memory IS
	-- Assuming that:
	--  - Instruction cache never writes to memory
	PORT (
		clk        : IN    STD_LOGIC;
		reset      : IN    STD_LOGIC;
		debug_dump : IN    STD_LOGIC;
		cmd        : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
		done       : OUT   STD_LOGIC;
		addr       : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
		data       : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);
END memory;

ARCHITECTURE structure OF memory IS

	COMPONENT memory_controller IS
		PORT (
			clk          : IN    STD_LOGIC;
			reset        : IN    STD_LOGIC;
			cmd          : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
			done         : OUT   STD_LOGIC;
			addr         : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
			data         : INOUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			mem_req      : OUT   STD_LOGIC;
			mem_we       : OUT   STD_LOGIC;
			mem_done     : IN    STD_LOGIC;
			mem_addr     : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_in  : OUT   STD_LOGIC_VECTOR(127 DOWNTO 0);
			mem_data_out : IN    STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ram IS
		PORT (
			clk        : IN  STD_LOGIC;
			reset      : IN  STD_LOGIC;
			debug_dump : IN  STD_LOGIC;
			req        : IN  STD_LOGIC;
			we         : IN  STD_LOGIC;
			done       : OUT STD_LOGIC;
			addr       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_in    : IN  STD_LOGIC_VECTOR(127 DOWNTO 0);
			data_out   : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL mem_req : STD_LOGIC;
	SIGNAL mem_we  : STD_LOGIC;
	SIGNAL mem_done : STD_LOGIC;
	SIGNAL mem_addr : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_in : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL mem_data_out : STD_LOGIC_VECTOR(127 DOWNTO 0);
BEGIN

	controller : memory_controller PORT MAP (
		clk => clk,
		reset => reset,
		cmd => cmd,
		done => done,
		addr => addr,
		data => data,
		mem_req => mem_req,
		mem_we => mem_we,
		mem_done => mem_done,
		mem_addr => mem_addr,
		mem_data_in => mem_data_in,
		mem_data_out => mem_data_out
	);

	r : ram PORT MAP (
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

END structure;
