LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY reorder_buffer IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		rob_we_1 : IN STD_LOGIC;
		rob_w_pos_1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		reg_v_in_1 : IN STD_LOGIC;
		reg_in_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_in_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_in_1 : IN STD_LOGIC;
		exc_code_in_1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_in_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_in_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		debug_dump_in_1 : IN STD_LOGIC;
		rob_we_2 : IN STD_LOGIC;
		rob_w_pos_2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		reg_v_in_2 : IN STD_LOGIC;
		reg_in_2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_in_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_in_2 : IN STD_LOGIC;
		exc_code_in_2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_in_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_in_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		debug_dump_in_2 : IN STD_LOGIC;
		rob_we_3 : IN STD_LOGIC;
		rob_w_pos_3 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		reg_v_in_3 : IN STD_LOGIC;
		reg_in_3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_in_3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_in_3 : IN STD_LOGIC;
		exc_code_in_3 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_in_3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_in_3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		debug_dump_in_3 : IN STD_LOGIC;
		reg_v_out : OUT STD_LOGIC;
		reg_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_out : OUT STD_LOGIC;
		exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		debug_dump_out : OUT STD_LOGIC;
		tail_we : IN STD_LOGIC;
		branch_taken : IN STD_LOGIC;
		tail_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END reorder_buffer;

ARCHITECTURE structure OF reorder_buffer IS
	CONSTANT ROB_POSITIONS : INTEGER := 10;

	TYPE valid_fields_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC;

	TYPE reg_v_fields_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC;
	TYPE reg_fields_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(4 DOWNTO 0);
	TYPE reg_data_fields_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	TYPE exc_fields_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC;
	TYPE exc_code_fields_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(1 DOWNTO 0);
	TYPE exc_data_fields_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	TYPE pc_fields_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	TYPE debug_dump_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC;

	SIGNAL valid_fields : valid_fields_t;
	SIGNAL reg_v_fields : reg_v_fields_t;
	SIGNAL reg_fields : reg_fields_t;
	SIGNAL reg_data_fields : reg_data_fields_t;
	SIGNAL exc_fields : exc_fields_t;
	SIGNAL exc_code_fields : exc_code_fields_t;
	SIGNAL exc_data_fields : exc_data_fields_t;
	SIGNAL pc_fields : pc_fields_t;
	SIGNAL debug_dump_fields : debug_dump_t;

	SIGNAL head : INTEGER RANGE 0 TO ROB_POSITIONS - 1;
	SIGNAL tail : INTEGER RANGE 0 TO ROB_POSITIONS - 1;

	PROCEDURE reset_rob(
			SIGNAL valid_fields : OUT valid_fields_t;
			SIGNAL head : OUT INTEGER RANGE 0 TO ROB_POSITIONS - 1;
			SIGNAL tail : OUT INTEGER RANGE 0 TO ROB_POSITIONS - 1
		) IS
	BEGIN
		FOR i in 0 TO ROB_POSITIONS - 1 LOOP
			valid_fields(i) <= '0';
		END LOOP;

		head <= 0;
		tail <= 0;
	END PROCEDURE;

BEGIN
	p: PROCESS(clk)
		VARIABLE rob_entry : INTEGER RANGE 0 TO ROB_POSITIONS - 1;
	BEGIN
		IF reset = '1' THEN
			reset_rob(valid_fields, head, tail);
		ELSE
			IF falling_edge(clk) THEN
				-- Write stuff on falling edge
				IF rob_we_1 = '1' THEN
					rob_entry := conv_integer(rob_w_pos_1);

					valid_fields(rob_entry) <= '1';
					reg_v_fields(rob_entry) <= reg_v_in_1;
					reg_fields(rob_entry) <= reg_in_1;
					reg_data_fields(rob_entry) <= reg_data_in_1;
					exc_fields(rob_entry) <= exc_in_1;
					exc_code_fields(rob_entry) <= exc_code_in_1;
					exc_data_fields(rob_entry) <= exc_data_in_1;
					pc_fields(rob_entry) <= pc_in_1;
					debug_dump_fields(rob_entry) <= debug_dump_in_1;
				END IF;

				IF rob_we_2 = '1' THEN
					rob_entry := conv_integer(rob_w_pos_2);

					valid_fields(rob_entry) <= '1';
					reg_v_fields(rob_entry) <= reg_v_in_2;
					reg_fields(rob_entry) <= reg_in_2;
					reg_data_fields(rob_entry) <= reg_data_in_2;
					exc_fields(rob_entry) <= exc_in_2;
					exc_code_fields(rob_entry) <= exc_code_in_2;
					exc_data_fields(rob_entry) <= exc_data_in_2;
					pc_fields(rob_entry) <= pc_in_2;
					debug_dump_fields(rob_entry) <= debug_dump_in_2;
				END IF;

				IF rob_we_3 = '1' THEN
					rob_entry := conv_integer(rob_w_pos_3);

					valid_fields(rob_entry) <= '1';
					reg_v_fields(rob_entry) <= reg_v_in_3;
					reg_fields(rob_entry) <= reg_in_3;
					reg_data_fields(rob_entry) <= reg_data_in_3;
					exc_fields(rob_entry) <= exc_in_3;
					exc_code_fields(rob_entry) <= exc_code_in_3;
					exc_data_fields(rob_entry) <= exc_data_in_3;
					pc_fields(rob_entry) <= pc_in_3;
					debug_dump_fields(rob_entry) <= debug_dump_in_3;
				END IF;
			ELSIF rising_edge(clk) THEN
				-- Commit instructions on rising edge
				IF valid_fields(head) = '1' THEN
					reg_v_out <= reg_v_fields(head);
					reg_out <= reg_fields(head);
					reg_data_out <= reg_data_fields(head);
					exc_out <= exc_fields(head);
					exc_code_out <= exc_code_fields(head);
					exc_data_out <= exc_data_fields(head);
					pc_out <= pc_fields(head);
					debug_dump_out <= debug_dump_fields(head);

					valid_fields(head) <= '0';
					head <= (head + 1) mod ROB_POSITIONS;
				ELSE
					reg_v_out <= '0';
					exc_out <= '0';
					debug_dump_out <= '0';
					pc_out <= x"00000000";
				END IF;

				IF branch_taken = '1' THEN
					-- We messed up!
					tail <= (tail - 1) mod ROB_POSITIONS;
				ELSIF tail_we = '1' THEN
					-- Increment tail if necessary
					tail <= (tail + 1) mod ROB_POSITIONS;
				END IF;
			END IF;
		END IF;
	END PROCESS p;

	-- Output current tail
	tail_out <= STD_LOGIC_VECTOR(TO_UNSIGNED(tail, 4));
END structure;

