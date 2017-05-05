LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.utils.ALL;

ENTITY reorder_buffer IS
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		-- Pipeline inputs
		rob_we_1 : IN STD_LOGIC;
		rob_w_pos_1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		reg_v_in_1 : IN STD_LOGIC;
		reg_in_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_in_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_in_1 : IN STD_LOGIC;
		exc_code_in_1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_in_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_in_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		inst_type_1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		store_1 : IN STD_LOGIC;
		rob_we_2 : IN STD_LOGIC;
		rob_w_pos_2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		reg_v_in_2 : IN STD_LOGIC;
		reg_in_2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_in_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_in_2 : IN STD_LOGIC;
		exc_code_in_2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_in_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_in_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		inst_type_2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		rob_we_3 : IN STD_LOGIC;
		rob_w_pos_3 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		reg_v_in_3 : IN STD_LOGIC;
		reg_in_3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_in_3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_in_3 : IN STD_LOGIC;
		exc_code_in_3 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_in_3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_in_3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		inst_type_3 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Pipeline outputs
		reg_v_out : OUT STD_LOGIC;
		reg_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_out : OUT STD_LOGIC;
		exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- Counter
		tail_we : IN STD_LOGIC;
		rollback_tail : IN STD_LOGIC;
		tail_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- Bypasses
		reg_src1_D_BP : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src1_D_v_BP : IN STD_LOGIC;
		reg_src1_D_p_BP : OUT STD_LOGIC;
		reg_src1_D_inst_type_BP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		reg_src1_D_data_BP : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		reg_src2_D_BP : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_src2_D_v_BP : IN STD_LOGIC;
		reg_src2_D_p_BP : OUT STD_LOGIC;
		reg_src2_D_inst_type_BP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		reg_src2_D_data_BP : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- Store buffer
		sb_store_id : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		sb_store_commit : OUT STD_LOGIC;
		sb_squash : OUT STD_LOGIC
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

	TYPE inst_type_fields_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(1 DOWNTO 0);

	TYPE store_fields_t IS ARRAY(ROB_POSITIONS - 1 DOWNTO 0) OF STD_LOGIC;

	SIGNAL valid_fields : valid_fields_t;
	SIGNAL reg_v_fields : reg_v_fields_t;
	SIGNAL reg_fields : reg_fields_t;
	SIGNAL reg_data_fields : reg_data_fields_t;
	SIGNAL exc_fields : exc_fields_t;
	SIGNAL exc_code_fields : exc_code_fields_t;
	SIGNAL exc_data_fields : exc_data_fields_t;
	SIGNAL pc_fields : pc_fields_t;
	SIGNAL inst_type_fields : inst_type_fields_t;
	SIGNAL store_fields : store_fields_t;

	SIGNAL head : INTEGER RANGE 0 TO ROB_POSITIONS - 1;
	SIGNAL tail : INTEGER RANGE 0 TO ROB_POSITIONS - 1;

	PROCEDURE reset_rob(
			SIGNAL valid_fields : OUT valid_fields_t;
			SIGNAL head : OUT INTEGER RANGE 0 TO ROB_POSITIONS - 1;
			SIGNAL tail : OUT INTEGER RANGE 0 TO ROB_POSITIONS - 1
		) IS
	BEGIN
		FOR i IN 0 TO ROB_POSITIONS - 1 LOOP
			valid_fields(i) <= '0';
		END LOOP;

		head <= 0;
		tail <= 0;
	END PROCEDURE;

	PROCEDURE bypass(
			SIGNAL head : IN INTEGER RANGE 0 TO ROB_POSITIONS - 1;
			SIGNAL tail : IN INTEGER RANGE 0 TO ROB_POSITIONS - 1;
			SIGNAL valid_fields : IN valid_fields_t;
			SIGNAL reg_v_fields : IN reg_v_fields_t;
			SIGNAL reg_fields : IN reg_fields_t;
			SIGNAL reg_data_fields : IN reg_data_fields_t;
			SIGNAL inst_type_fields : IN inst_type_fields_t;
			SIGNAL reg_src_v : IN STD_LOGIC;
			SIGNAL reg_src : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			SIGNAL reg_p : OUT STD_LOGIC;
			SIGNAL reg_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			SIGNAL inst_type : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		) IS
		VARIABLE i : INTEGER RANGE 0 TO ROB_POSITIONS - 1;
	BEGIN
		IF reg_src_v = '0' THEN
			reg_p <= '0';
		ELSE
			reg_p <= '0';
			i := tail;
			L: LOOP
				IF valid_fields(i) = '1' THEN
					IF reg_v_fields(i) = '1' AND reg_fields(i) = reg_src THEN
						reg_p <= '1';
						reg_data <= reg_data_fields(i);
						inst_type <= inst_type_fields(i);
						EXIT;
					END IF;
				END IF;

				EXIT L WHEN i = head;
				i := (i - 1) mod ROB_POSITIONS;
			END LOOP;
		END IF;
	END PROCEDURE;

BEGIN
	p: PROCESS(clk)
		VARIABLE rob_entry : INTEGER RANGE 0 TO ROB_POSITIONS - 1;
		VARIABLE exception : BOOLEAN;
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
					inst_type_fields(rob_entry) <= inst_type_1;
					store_fields(rob_entry) <= store_1;
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
					inst_type_fields(rob_entry) <= inst_type_2;
					store_fields(rob_entry) <= '0';
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
					inst_type_fields(rob_entry) <= inst_type_3;
					store_fields(rob_entry) <= '0';
				END IF;
			ELSIF rising_edge(clk) THEN
				exception := FALSE;

				sb_store_commit <= '0';
				sb_squash <= '0';

				-- Commit instructions on rising edge
				IF valid_fields(head) = '1' THEN
					reg_v_out <= reg_v_fields(head);
					reg_out <= reg_fields(head);
					reg_data_out <= reg_data_fields(head);
					exc_out <= exc_fields(head);
					exc_code_out <= exc_code_fields(head);
					exc_data_out <= exc_data_fields(head);
					pc_out <= pc_fields(head);

					valid_fields(head) <= '0';
					head <= (head + 1) mod ROB_POSITIONS;

					IF exc_fields(head) = '1' THEN
						exception := TRUE;
					END IF;

					-- Commit the store buffer entry only when
					-- no exception has been detected
					IF store_fields(head) = '1' AND NOT exception THEN
						sb_store_id <= STD_LOGIC_VECTOR(to_unsigned(head, sb_store_id'LENGTH));
						sb_store_commit <= '1';
					END IF;
				ELSE
					reg_v_out <= '0';
					exc_out <= '0';
					pc_out <= x"00000000";
				END IF;

				IF exception THEN
					-- Mayday, mayday, stop all instructions
					-- Be careful: head still doesn't have the new value
					rob_entry := (head + 1) mod ROB_POSITIONS;
					L: LOOP
						valid_fields(rob_entry) <= '0';

						EXIT L WHEN rob_entry = tail;
						rob_entry := (rob_entry + 1) mod ROB_POSITIONS;
					END LOOP;
					sb_squash <= '1';
					tail <= (head + 1) mod ROB_POSITIONS;
				ELSIF rollback_tail = '1' THEN
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

	-- Bypasses
	bypass(head, tail, valid_fields, reg_v_fields, reg_fields, reg_data_fields,
			inst_type_fields, reg_src1_D_v_BP, reg_src1_D_BP, reg_src1_D_p_BP,
			reg_src1_D_data_BP, reg_src1_D_inst_type_BP);
	bypass(head, tail, valid_fields, reg_v_fields, reg_fields, reg_data_fields,
			inst_type_fields, reg_src2_D_v_BP, reg_src2_D_BP, reg_src2_D_p_BP,
			reg_src2_D_data_BP, reg_src2_D_inst_type_BP);
END structure;

