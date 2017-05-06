LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.UTILS.ALL;

ENTITY inkel_pentwice IS
	PORT(
		clk    : IN STD_LOGIC;
		reset  : IN STD_LOGIC;
		pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END inkel_pentwice;

ARCHITECTURE structure OF inkel_pentwice IS
	COMPONENT inkel_pentiun IS
		PORT(
			clk            : IN  STD_LOGIC;
			reset          : IN  STD_LOGIC;
			i_req_mem      : OUT STD_LOGIC;
			d_req_mem      : OUT STD_LOGIC;
			i_addr_mem     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			d_addr_mem     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			d_we_mem       : OUT STD_LOGIC;
			i_done_mem     : IN  STD_LOGIC;
			d_done_mem     : IN  STD_LOGIC;
			d_data_out_mem : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			i_data_in_mem  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			d_data_in_mem  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			pc_out         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT memory IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			debug_dump : IN STD_LOGIC;
			req : IN STD_LOGIC;
			we : IN STD_LOGIC;
			done : OUT STD_LOGIC;
			addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;
    
	COMPONENT arbiter IS
        PORT (clk : IN STD_LOGIC;
              reset : IN STD_LOGIC;
              i_req : IN STD_LOGIC;
              d_req : IN STD_LOGIC;
              mem_req : OUT STD_LOGIC;
              d_we : IN STD_LOGIC;
              mem_we : OUT STD_LOGIC;
              i_done : OUT STD_LOGIC;
              d_done : OUT STD_LOGIC;
              mem_done : IN STD_LOGIC;
              i_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
              d_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
              mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
              d_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
              mem_data_in : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
              i_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
              d_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
              mem_data_out : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
        );
    END COMPONENT;

	SIGNAL i_req_MEM : STD_LOGIC;
	SIGNAL d_req_MEM : STD_LOGIC;
	SIGNAL i_addr_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL d_addr_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL d_we_MEM : STD_LOGIC;
	SIGNAL i_done_MEM : STD_LOGIC;
	SIGNAL d_done_MEM : STD_LOGIC;
	SIGNAL d_data_in_MEM : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL i_data_out_MEM : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL d_data_out_MEM : STD_LOGIC_VECTOR(127 DOWNTO 0);

	SIGNAL req_MEM : STD_LOGIC;
	SIGNAL we_MEM : STD_LOGIC;
	SIGNAL addr_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL done_MEM : STD_LOGIC;
	SIGNAL data_in_MEM : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL data_out_MEM : STD_LOGIC_VECTOR(127 DOWNTO 0);
BEGIN

	mem : memory PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => '0',
		req => req_MEM,
		we => we_MEM,
		done => done_MEM,
		addr => addr_MEM,
		data_in => data_in_MEM,
		data_out => data_out_MEM
	);

	arb : arbiter PORT MAP (
        clk => clk,
        reset => reset,
        i_req => i_req_MEM,
        d_req => d_req_MEM,
        mem_req => req_MEM,
        d_we => d_we_MEM,
        mem_we => we_MEM,
        i_done => i_done_MEM,
        d_done => d_done_MEM,
        mem_done => done_MEM,
        i_addr => i_addr_MEM,
        d_addr => d_addr_MEM,
        mem_addr => addr_MEM,
        d_data_in => d_data_in_MEM,
        mem_data_in => data_in_MEM,
        i_data_out => i_data_out_MEM,
        d_data_out => d_data_out_MEM,
        mem_data_out => data_out_MEM
    );

	proc : inkel_pentiun PORT MAP(
		clk => clk,
		reset => reset,
		i_req_mem => i_req_MEM,
		d_req_mem => d_req_MEM,
		i_addr_mem => i_addr_MEM,
		d_addr_mem => d_addr_MEM,
		d_we_mem => d_we_MEM,
		i_done_mem => i_done_MEM,
		d_done_mem => d_done_MEM,
		d_data_out_mem => d_data_in_MEM,
		i_data_in_mem => i_data_out_MEM,
		d_data_in_mem => d_data_out_MEM,
		pc_out => pc_out
	);
END structure;
