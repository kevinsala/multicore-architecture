LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_arith.all;

ENTITY arbiter IS
	PORT(
		clk       : IN  STD_LOGIC;
		reset     : IN  STD_LOGIC;
		mem_done  : IN  STD_LOGIC;
		req_one_i : IN  STD_LOGIC;
		req_one_d : IN  STD_LOGIC;
		ack_one_i : OUT STD_LOGIC;
		ack_one_d : OUT STD_LOGIC;
		req_two_i : IN  STD_LOGIC;
		req_two_d : IN  STD_LOGIC;
		ack_two_i : OUT STD_LOGIC;
		ack_two_d : OUT STD_LOGIC
	);
END arbiter;

ARCHITECTURE structure OF arbiter IS
		TYPE old_state_t IS (NONE, ONEWORKED, TWOWORKED);
		TYPE cur_state_t IS (IDLE, REQONE_I, REQONE_D, REQTWO_I, REQTWO_D, WAITING_MEM);

		-- Using old_state to establish some kind of fairness
		-- Fairness: If you have just worked, you will only work again
		--           immediately after if other workers don't want to. 
		--           (This would not run smoothly in an Andalucian processor) 
		SIGNAL cur_state : cur_state_t := IDLE;
		SIGNAL old_state : old_state_t := NONE;

BEGIN

		p : PROCESS(clk)
		BEGIN
				IF rising_edge(clk) THEN
						IF cur_state = IDLE THEN
								IF	(req_one_i = '1' OR req_one_d = '1') AND						-- Both pentiuns want to work (either their instruction or data caches)
										(req_two_i = '1' OR req_two_d = '1') THEN
										IF old_state = TWOWORKED OR old_state = NONE THEN		-- 'two' or nobody (priority to 'one') worked before
												IF req_one_d = '1' THEN
														cur_state <= REQONE_D;											-- Priority to data cache requests
														old_state <= ONEWORKED;
												ELSIF req_one_i = '1' THEN
														cur_state <= REQONE_I;
														old_state <= ONEWORKED;
												END IF;
										ELSIF old_state = ONEWORKED THEN										-- 'one' worked before   
												IF req_two_d = '1' THEN
														cur_state <= REQTWO_D;											-- Priority to data cache requests
														old_state <= TWOWORKED;
												ELSIF req_two_i = '1' THEN
														cur_state <= REQTWO_I;
														old_state <= TWOWORKED;
												END IF;
										END IF;
								ELSIF	(req_one_i = '1' OR  req_one_d = '1') AND					-- Only 'one' wants to work
											(req_two_i = '0' AND req_two_d = '0') THEN 
										IF req_one_d = '1' THEN
												cur_state <= REQONE_D;
												old_state <= ONEWORKED;
										ELSIF req_one_i = '1' THEN
												cur_state <= REQONE_I;
												old_state <= ONEWORKED;
										END IF;
								ELSIF	(req_two_i = '1' OR  req_two_d = '1') AND					-- Only 'two' wants to work
											(req_one_i = '0' AND req_one_d = '0') THEN 
										IF req_two_d = '1' THEN
												cur_state <= REQTWO_D;
												old_state <= TWOWORKED;
										ELSIF req_two_i = '1' THEN
												cur_state <= REQTWO_I;
												old_state <= TWOWORKED;
										END IF;
								END IF;
						ELSIF cur_state = REQONE_I THEN
								IF mem_done = '1' THEN
										cur_state <= IDLE;
								ELSIF req_one_i = '0' THEN
										cur_state <= WAITING_MEM;
								END IF;
						ELSIF cur_state = REQONE_D THEN
								IF mem_done = '1' THEN
										cur_state <= IDLE;
								ELSIF req_one_d = '0' THEN
										cur_state <= WAITING_MEM;
								END IF;
						ELSIF cur_state = REQTWO_I THEN
								IF mem_done = '1' THEN
										cur_state <= IDLE;
								ELSIF req_two_i = '0' THEN
										cur_state <= WAITING_MEM;
								END IF;
						ELSIF cur_state = REQTWO_D THEN
								IF mem_done = '1' THEN
										cur_state <= IDLE;
								ELSIF req_two_d = '0' THEN
										cur_state <= WAITING_MEM;
								END IF;
						ELSIF cur_state = WAITING_MEM THEN
								IF mem_done = '1' THEN
									cur_state <= IDLE;
								END IF;
						END IF;
				END IF;
		
		END PROCESS p;
		
		
		ack_one_i <=	'1' WHEN cur_state = REQONE_I AND req_one_i = '1' ELSE
									'0';
									
		ack_one_d <=	'1' WHEN cur_state = REQONE_D AND req_one_d = '1' ELSE
									'0';

		ack_two_i <=	'1' WHEN cur_state = REQTWO_I AND req_two_i = '1' ELSE
									'0';
									
		ack_two_d <=	'1' WHEN cur_state = REQTWO_D AND req_two_d = '1' ELSE
									'0';
									
END structure;
