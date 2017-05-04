LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.UTILS.ALL;

ENTITY inkel_pentiun IS
	PORT(
		clk     : IN  STD_LOGIC;
		reset   : IN  STD_LOGIC;
		pc_out  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END inkel_pentiun;

ARCHITECTURE structure OF inkel_pentiun IS
	COMPONENT reg_status IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status_in : IN STD_LOGIC;
			exc_new : IN STD_LOGIC;
			exc_code_new : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_new : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_old : IN STD_LOGIC;
			exc_code_old : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_old : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			rob_idx_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			inst_type_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status_out : OUT STD_LOGIC;
			exc_out : OUT STD_LOGIC;
			exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			rob_idx_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			inst_type_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT memory IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			debug_dump : IN STD_LOGIC;
			f_req : IN STD_LOGIC;
			d_req : IN STD_LOGIC;
			d_we : IN STD_LOGIC;
			f_done : OUT STD_LOGIC;
			d_done : OUT STD_LOGIC;
			f_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			d_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			d_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			f_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			d_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT exception_unit IS
		PORT(
			invalid_access_F : IN STD_LOGIC;
			mem_addr_F : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			invalid_inst_D : IN STD_LOGIC;
			inst_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			invalid_access_C : IN STD_LOGIC;
			mem_addr_C : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_F : OUT STD_LOGIC;
			exc_code_F : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_D : OUT STD_LOGIC;
			exc_code_D : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_D : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_A : OUT STD_LOGIC;
			exc_code_A : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_A : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_C : OUT STD_LOGIC;
			exc_code_C : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_C : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT pc IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			addr_jump : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			branch_taken : IN STD_LOGIC;
			exception_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exception : IN STD_LOGIC;
			iret : IN STD_LOGIC;
			load_PC : IN STD_LOGIC;
			pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg_priv_status IS
		PORT(clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			exc_W : IN STD_LOGIC;
			iret_A : IN STD_LOGIC;
			priv_status : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT fetch IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			priv_status_r : IN STD_LOGIC;
        	priv_status_w : IN STD_LOGIC;
			pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			branch_taken : IN STD_LOGIC;
			inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_v : OUT STD_LOGIC;
			invalid_access : OUT STD_LOGIC;
			mem_req : OUT STD_LOGIC;
			mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_done : IN STD_LOGIC;
			mem_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT cache_stage IS
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
	END COMPONENT;

	COMPONENT reg_FD IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			inst_v_in : IN STD_LOGIC;
			inst_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_v_out : OUT STD_LOGIC;
			inst_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT mux2_32bits IS
		PORT(
			DIn0 : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			DIn1 : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			ctrl : IN  STD_LOGIC;
			Dout : OUT  STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg_bank IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			debug_dump : IN STD_LOGIC;
			src1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			src2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			we : IN STD_LOGIC;
			dest : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exception : IN STD_LOGIC;
			exc_code : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT decode IS
		PORT(
			inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_v : IN STD_LOGIC;
			pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status : IN STD_LOGIC;
			inst_type : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			op_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			reg_src1 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src2 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_dest : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			inm_ext : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU_ctrl : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			branch : OUT STD_LOGIC;
			branch_if_eq : OUT STD_LOGIC;
			jump : OUT STD_LOGIC;
			reg_src1_v : OUT STD_LOGIC;
			reg_src2_v : OUT STD_LOGIC;
			inm_src2_v : OUT STD_LOGIC;
			mem_write : OUT STD_LOGIC;
			byte : OUT STD_LOGIC;
			mem_read : OUT STD_LOGIC;
			reg_we : OUT STD_LOGIC;
			iret : OUT STD_LOGIC;
			invalid_inst : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT bypass_unit IS
		PORT(
			reg_src1_D        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_src2_D        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_src1_v_D      : IN STD_LOGIC;
			reg_src2_v_D      : IN STD_LOGIC;
			inm_src2_v_D      : IN STD_LOGIC;
			reg_dest_A        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_we_A          : IN STD_LOGIC;
			reg_dest_C        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_we_C          : IN STD_LOGIC;
			reg_dest_M5       : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_we_M5         : IN STD_LOGIC;
			reg_src1_D_p_ROB  : IN STD_LOGIC;
			reg_src1_D_inst_type_ROB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			reg_src2_D_p_ROB  : IN STD_LOGIC;
			reg_src2_D_inst_type_ROB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			mux_src1_D_BP     : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			mux_src2_D_BP     : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			mux_mem_data_D_BP : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			mux_mem_data_A_BP : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT detention_unit IS
		PORT(
			reset          : IN STD_LOGIC;
			inst_type_D    : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			reg_src1_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src2_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_dest_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src1_v_D   : IN STD_LOGIC;
			reg_src2_v_D   : IN STD_LOGIC;
			mem_we_D 	   : IN STD_LOGIC;
			branch_taken_A : IN STD_LOGIC;
			mul_M1		   : IN STD_LOGIC;
			mul_M2		   : IN STD_LOGIC;
			reg_dest_M2    : IN STD_LOGIC_VECTOR(4 downto 0);
			mul_M3		   : IN STD_LOGIC;
			reg_dest_M3    : IN STD_LOGIC_VECTOR(4 downto 0);
			mul_M4		   : IN STD_LOGIC;
			reg_dest_M4    : IN STD_LOGIC_VECTOR(4 downto 0);
			reg_dest_M5    : IN STD_LOGIC_VECTOR(4 downto 0);
			mul_M5 		   : IN STD_LOGIC;
			inst_type_A    : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			reg_dest_A     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_we_A       : IN STD_LOGIC;
			mem_read_A     : IN STD_LOGIC;
			reg_dest_C     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			mem_read_C     : IN STD_LOGIC;
			done_F         : IN STD_LOGIC;
			done_C         : IN STD_LOGIC;
			exc_D          : IN STD_LOGIC;
			exc_A          : IN STD_LOGIC;
			exc_C          : IN STD_LOGIC;
			conflict       : OUT STD_LOGIC;
			reg_PC_reset   : OUT STD_LOGIC;
			reg_F_D_reset  : OUT STD_LOGIC;
			reg_D_A_reset  : OUT STD_LOGIC;
			reg_A_C_reset  : OUT STD_LOGIC;
			reg_PC_we      : OUT STD_LOGIC;
			reg_F_D_we     : OUT STD_LOGIC;
			reg_D_A_we     : OUT STD_LOGIC;
			reg_A_C_we     : OUT STD_LOGIC;
			rob_count      : OUT STD_LOGIC;
			rob_rollback   : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT reg_DA IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			mem_we_in : IN STD_LOGIC;
			byte_in : IN STD_LOGIC;
			mem_read_in : IN STD_LOGIC;
			reg_we_in : IN STD_LOGIC;
			branch_in : IN STD_LOGIC;
			branch_if_eq_in : IN STD_LOGIC;
			jump_in : IN STD_LOGIC;
			inm_ext_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU_ctrl_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			reg_src1_v_in : IN STD_LOGIC;
			reg_src2_v_in : IN STD_LOGIC;
			inm_src2_v_in : IN STD_LOGIC;
			reg_src1_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src2_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			reg_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			iret_in : IN STD_LOGIC;
			mem_we_out : OUT STD_LOGIC;
			byte_out : OUT STD_LOGIC;
			mem_read_out : OUT STD_LOGIC;
			reg_we_out : OUT STD_LOGIC;
			branch_out : OUT STD_LOGIC;
			branch_if_eq_out : OUT STD_LOGIC;
			jump_out : OUT STD_LOGIC;
			inm_ext_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU_ctrl_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			reg_src1_v_out : OUT STD_LOGIC;
			reg_src2_v_out : OUT STD_LOGIC;
			inm_src2_v_out : OUT STD_LOGIC;
			reg_src1_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src2_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			reg_data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			iret_out : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT mux4_32bits IS
		PORT(
			DIn0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			DIn1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			DIn2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			DIn3 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			ctrl : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			Dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT mux8_32bits IS
		PORT(
			Din0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din3 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din4 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din5 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din6 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din7 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			ctrl : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			Dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU IS
		PORT(
			DA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			DB : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU_MUL_seg IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			load : IN STD_LOGIC;
			done_C : IN STD_LOGIC;
			DA : IN  STD_LOGIC_VECTOR (31 downto 0); --entrada 1
			DB : IN  STD_LOGIC_VECTOR (31 downto 0); --entrada 2
			reg_dest_in : IN STD_LOGIC_VECTOR(4 downto 0);
			reg_we_in : IN STD_LOGIC;
			M2_mul : OUT STD_LOGIC;
			reg_dest_M2 : OUT STD_LOGIC_VECTOR(4 downto 0);
			M3_mul : OUT STD_LOGIC;
			reg_dest_M3 : OUT STD_LOGIC_VECTOR(4 downto 0);
			M4_mul : OUT STD_LOGIC;
			reg_dest_M4 : OUT STD_LOGIC_VECTOR(4 downto 0);
			M5_mul : OUT STD_LOGIC;
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 downto 0);
			reg_we_out : OUT STD_LOGIC;
			Dout : OUT  STD_LOGIC_VECTOR(31 downto 0);
			-- reg status signals --
			pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status_in : IN STD_LOGIC;
			exc_new : IN STD_LOGIC;
			exc_code_new : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_new : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_old : IN STD_LOGIC;
			exc_code_old : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_old : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			rob_idx_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			inst_type_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status_out : OUT STD_LOGIC;
			exc_out : OUT STD_LOGIC;
			exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			rob_idx_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			inst_type_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg_AC IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			mem_we_in : IN STD_LOGIC;
			byte_in : IN STD_LOGIC;
			mem_read_in : IN STD_LOGIC;
			reg_we_in : IN STD_LOGIC;
			reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			ALU_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we_out : OUT STD_LOGIC;
			byte_out : OUT STD_LOGIC;
			mem_read_out : OUT STD_LOGIC;
			reg_we_out : OUT STD_LOGIC;
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			ALU_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg_W IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			reg_we_in : IN STD_LOGIC;
			reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we_in : IN STD_LOGIC;
			v : OUT STD_LOGIC;
			reg_we_out : OUT STD_LOGIC;
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we_out : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT reorder_buffer IS
		PORT(
			clk : IN STD_LOGIC;
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
			reg_v_out : OUT STD_LOGIC;
			reg_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_out : OUT STD_LOGIC;
			exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			tail_we : IN STD_LOGIC;
			rollback_tail : IN STD_LOGIC;
			tail_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
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
			sb_store_id : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			sb_store_commit : OUT STD_LOGIC;
			sb_squash : OUT STD_LOGIC
		);
	END COMPONENT;

	-- Fetch stage signals
	SIGNAL inst_v_F : STD_LOGIC;
	SIGNAL mem_req_F : STD_LOGIC;
	SIGNAL mem_done_F : STD_LOGIC;
	SIGNAL priv_status_F : STD_LOGIC;
	SIGNAL invalid_access_F : STD_LOGIC;
	SIGNAL rob_idx_F : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL pc_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inst_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_addr_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_in_F : STD_LOGIC_VECTOR(127 DOWNTO 0);

	-- Decode stage signals
	SIGNAL inst_v_D : STD_LOGIC;
	SIGNAL branch_D : STD_LOGIC;
	SIGNAL jump_D : STD_LOGIC;
	SIGNAL branch_if_eq_D : STD_LOGIC;
	SIGNAL reg_we_D : STD_LOGIC;
	SIGNAL mem_read_D : STD_LOGIC;
	SIGNAL byte_D : STD_LOGIC;
	SIGNAL mem_we_D : STD_LOGIC;
	SIGNAL reg_src1_v_D : STD_LOGIC;
	SIGNAL reg_src2_v_D : STD_LOGIC;
	SIGNAL inm_src2_v_D : STD_LOGIC;
	SIGNAL priv_status_D : STD_LOGIC;
	SIGNAL invalid_inst_D : STD_LOGIC;
	SIGNAL iret_D : STD_LOGIC;
	SIGNAL inst_type_D : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL ALU_ctrl_D : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL rob_idx_D : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_src1_D : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src2_D : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_dest_D : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL op_code_D : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL inst_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data1_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data2_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inm_ext_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL conflict_D : STD_LOGIC;
	SIGNAL mem_data_D_BP : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL data1_BP_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL data2_BP_D : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- ALU stage signals
	SIGNAL Z : STD_LOGIC;
	SIGNAL branch_A : STD_LOGIC;
	SIGNAL jump_A : STD_LOGIC;
	SIGNAL jump_or_branch_A : STD_LOGIC;
	SIGNAL branch_if_eq_A : STD_LOGIC;
	SIGNAL branch_taken_A : STD_LOGIC;
	SIGNAL mem_read_A : STD_LOGIC;
	SIGNAL reg_src1_v_A : STD_LOGIC;
	SIGNAL reg_src2_v_A : STD_LOGIC;
	SIGNAL inm_src2_v_A : STD_LOGIC;
	SIGNAL mem_we_A : STD_LOGIC;
	SIGNAL byte_A : STD_LOGIC;
	SIGNAL reg_we_A : STD_LOGIC;
	SIGNAL priv_status_A : STD_LOGIC;
	SIGNAL iret_A : STD_LOGIC;
	SIGNAL inst_type_A : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL ALU_ctrl_A : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL rob_idx_A : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_dest_A : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src1_A : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src2_A : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL pc_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL jump_addr_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data1_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data2_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inm_ext_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_data1_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_data2_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_A_BP : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Cache stage signals
	SIGNAL cache_we_C : STD_LOGIC;
	SIGNAL cache_re_C : STD_LOGIC;
	SIGNAL byte_C : STD_LOGIC;
	SIGNAL reg_we_C : STD_LOGIC;
	SIGNAL priv_status_C : STD_LOGIC;
	SIGNAL invalid_access_C : STD_LOGIC;
	SIGNAL done_C : STD_LOGIC;
	SIGNAL mem_req_C : STD_LOGIC;
	SIGNAL mem_we_C : STD_LOGIC;
	SIGNAL mem_done_C : STD_LOGIC;
	SIGNAL mem_addr_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_in_C : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL mem_data_out_C : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL inst_type_C : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL rob_idx_C : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_dest_C : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL pc_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL cache_data_in_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL sb_store_id_C : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL sb_store_commit_C : STD_LOGIC;
	SIGNAL sb_squash_C : STD_LOGIC;

	-- Mul stage signals
	SIGNAL mul_M1 : STD_LOGIC;
	SIGNAL mul_M2 : STD_LOGIC;
	SIGNAL reg_dest_M2 : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL mul_M3 : STD_LOGIC;
	SIGNAL reg_dest_M3 : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL mul_M4 : STD_LOGIC;
	SIGNAL reg_dest_M4 : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL mul_M5 : STD_LOGIC;
	SIGNAL mul_out_M5 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_dest_M5 : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL reg_we_M5 : STD_LOGIC;
	SIGNAL pc_M5 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL priv_status_M5 : STD_LOGIC;
	SIGNAL rob_idx_M5 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_M5 : STD_LOGIC_VECTOR(1 DOWNTO 0);

	-- Writeback stage signals
	SIGNAL v_W_MEM : STD_LOGIC;
	SIGNAL reg_we_W_MEM : STD_LOGIC;
	SIGNAL reg_dest_W_MEM : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_we_W_MEM : STD_LOGIC;
	SIGNAL pc_W_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_W_MEM : STD_LOGIC;
	SIGNAL exc_code_W_MEM : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_W_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_MEM : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_MEM : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL v_W_ALU : STD_LOGIC;
	SIGNAL reg_we_W_ALU : STD_LOGIC;
	SIGNAL reg_dest_W_ALU : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_ALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_W_ALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_W_ALU : STD_LOGIC;
	SIGNAL exc_code_W_ALU : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_W_ALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_ALU : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_ALU : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL v_W_MUL : STD_LOGIC;
	SIGNAL reg_we_W_MUL : STD_LOGIC;
	SIGNAL reg_dest_W_MUL : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_MUL : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_W_MUL : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_W_MUL : STD_LOGIC;
	SIGNAL exc_code_W_MUL : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_W_MUL : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_MUL : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_MUL : STD_LOGIC_VECTOR(1 DOWNTO 0);

	-- ROB output signals
	SIGNAL reg_we_ROB : STD_LOGIC;
	SIGNAL reg_dest_ROB : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_ROB : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_ROB : STD_LOGIC;
	SIGNAL exc_code_ROB : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_ROB : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_ROB : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL debug_dump_ROB : STD_LOGIC;
	SIGNAL reg_src1_D_p_ROB : STD_LOGIC;
	SIGNAL reg_src1_D_inst_type_ROB : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL reg_src1_D_data_ROB : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_src2_D_p_ROB : STD_LOGIC;
	SIGNAL reg_src2_D_inst_type_ROB : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL reg_src2_D_data_ROB : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Segmentation registers signals
	SIGNAL reg_F_D_reset : STD_LOGIC;
	SIGNAL reg_F_D_reset_DU : STD_LOGIC;
	SIGNAL reg_D_A_reset : STD_LOGIC;
	SIGNAL reg_D_A_reset_DU : STD_LOGIC;
	SIGNAL reg_A_C_reset : STD_LOGIC;
	SIGNAL reg_A_C_reset_DU : STD_LOGIC;
	SIGNAL reg_W_MEM_reset : STD_LOGIC;
	SIGNAL reg_W_ALU_reset : STD_LOGIC;
	SIGNAL reg_W_MUL_reset : STD_LOGIC;
	SIGNAL reg_F_D_we : STD_LOGIC;
	SIGNAL reg_D_A_we : STD_LOGIC;
	SIGNAL reg_A_C_we : STD_LOGIC;

	-- Stall unit signals
	SIGNAL load_PC : STD_LOGIC;
	SIGNAL reset_PC : STD_LOGIC;
	SIGNAL rob_count_DU : STD_LOGIC;
	SIGNAL rob_rollback_DU : STD_LOGIC;

	-- Bypass unit signals
	SIGNAL mux_src1_D_BP_ctrl : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mux_src2_D_BP_ctrl : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mux_mem_data_D_BP_ctrl : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mux_mem_data_A_BP_ctrl : STD_LOGIC_VECTOR(1 DOWNTO 0);

	-- Exception unit signals
	SIGNAL exc_F_E : STD_LOGIC;
	SIGNAL exc_D : STD_LOGIC;
	SIGNAL exc_D_E : STD_LOGIC;
	SIGNAL exc_A : STD_LOGIC;
	SIGNAL exc_A_E : STD_LOGIC;
	SIGNAL exc_M5 : STD_LOGIC;
	SIGNAL exc_M5_E : STD_LOGIC;
	SIGNAL exc_C : STD_LOGIC;
	SIGNAL exc_C_E : STD_LOGIC;
	SIGNAL exc_code_F_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_D : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_D_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_A : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_A_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_M5 : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_M5_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_C : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_C_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_F_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_D_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_A_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_M5 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_M5_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_C_E : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

	mem: memory PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump_ROB,
		f_req => mem_req_F,
		d_req => mem_req_C,
		d_we => mem_we_C,
		f_done => mem_done_F,
		d_done => mem_done_C,
		f_addr => mem_addr_F,
		d_addr => mem_addr_C,
		d_data_in => mem_data_out_C,
		f_data_out => mem_data_in_F,
		d_data_out => mem_data_in_C
	);

	----------------------------- Control -------------------------------

	exc : exception_unit PORT MAP(
		invalid_access_F => invalid_access_F,
		mem_addr_F => pc_F,
		invalid_inst_D => invalid_inst_D,
		inst_D => inst_D,
		invalid_access_C => invalid_access_C,
		mem_addr_C => ALU_out_C,
		exc_F => exc_F_E,
		exc_code_F => exc_code_F_E,
		exc_data_F => exc_data_F_E,
		exc_D => exc_D_E,
		exc_code_D => exc_code_D_E,
		exc_data_D => exc_data_D_E,
		exc_A => exc_A_E,
		exc_code_A => exc_code_A_E,
		exc_data_A => exc_data_A_E,
		exc_C => exc_C_E,
		exc_code_C => exc_code_C_E,
		exc_data_C => exc_data_C_E
	);

	DU : detention_unit PORT MAP(
		reset => reset,
		inst_type_D => inst_type_D,
		reg_src1_D => reg_src1_D,
		reg_src2_D => reg_src2_D,
		reg_dest_D => reg_dest_D,
		reg_src1_v_D => reg_src1_v_D,
		reg_src2_v_D => reg_src2_v_D,
		mem_we_D => mem_we_D,
		branch_taken_A => branch_taken_A,
		mul_M1 => mul_M1,
		mul_M2 => mul_M2,
		reg_dest_M2 => reg_dest_M2,
		mul_M3 => mul_M3,
		reg_dest_M3 => reg_dest_M3,
		mul_M4 => mul_M4,
		reg_dest_M4 => reg_dest_M4,
		mul_M5 => mul_M5,
		reg_dest_M5 => reg_dest_M5,
		inst_type_A => inst_type_A,
		reg_dest_A => reg_dest_A,
		reg_we_A => reg_we_A,
		mem_read_A => mem_read_A,
		reg_dest_C => reg_dest_C,
		mem_read_C => cache_re_C,
		done_F => inst_v_F,
		done_C => done_C,
		exc_D => exc_D,
		exc_A => exc_A,
		exc_C => exc_C,
		conflict => conflict_D,
		reg_PC_reset => reset_PC,
		reg_F_D_reset => reg_F_D_reset_DU,
		reg_D_A_reset => reg_D_A_reset_DU,
		reg_A_C_reset => reg_A_C_reset_DU,
		reg_PC_we => load_PC,
		reg_F_D_we => reg_F_D_we,
		reg_D_A_we => reg_D_A_we,
		reg_A_C_we => reg_A_C_we,
		rob_count => rob_count_DU,
		rob_rollback => rob_rollback_DU
	);

	BP : bypass_unit PORT MAP(
		reg_src1_D => reg_src1_D,
		reg_src2_D => reg_src2_D,
		reg_src1_v_D => reg_src1_v_D,
		reg_src2_v_D => reg_src2_v_D,
		inm_src2_v_D => inm_src2_v_D,
		reg_dest_A => reg_dest_A,
		reg_we_A => reg_we_A,
		reg_dest_C => reg_dest_C,
		reg_we_C => reg_we_C,
		reg_dest_M5 => reg_dest_M5,
		reg_we_M5 => reg_we_M5,
		reg_src1_D_p_ROB => reg_src1_D_p_ROB,
		reg_src1_D_inst_type_ROB => reg_src1_D_inst_type_ROB,
		reg_src2_D_p_ROB => reg_src2_D_p_ROB,
		reg_src2_D_inst_type_ROB => reg_src2_D_inst_type_ROB,
		mux_src1_D_BP => mux_src1_D_BP_ctrl,
		mux_src2_D_BP => mux_src2_D_BP_ctrl,
		mux_mem_data_D_BP => mux_mem_data_D_BP_ctrl,
		mux_mem_data_A_BP => mux_mem_data_A_BP_ctrl
	);

	----------------------------- Fetch -------------------------------

	reg_pc: pc PORT MAP(
		clk => clk,
		reset => reset_PC,
		addr_jump => jump_addr_A,
		branch_taken => branch_taken_A,
		exception_addr => pc_ROB,
		exception => exc_ROB,
		iret => iret_A,
		load_PC => load_PC,
		pc => pc_F
	);

	priv_status : reg_priv_status PORT MAP(
		clk => clk,
		reset => reset,
		exc_W => exc_ROB,
		iret_A => iret_A,
		priv_status => priv_status_F
	);

	f: fetch PORT MAP(
		clk => clk,
		reset => reset,
		priv_status_r => priv_status_F,
		priv_status_w => priv_status_C,
		pc => pc_F,
		branch_taken => branch_taken_A,
		inst => inst_F,
		inst_v => inst_v_F,
		invalid_access => invalid_access_F,
		mem_req => mem_req_F,
		mem_addr => mem_addr_F,
		mem_done => mem_done_F,
		mem_data_in => mem_data_in_F
	);

	reg_F_D_reset <= reg_F_D_reset_DU OR exc_F_E;

	reg_F_D: reg_FD PORT MAP(
		clk => clk,
		reset => reg_F_D_reset,
		we => reg_F_D_we,
		inst_v_in => inst_v_F,
		inst_in => inst_F,
		inst_v_out => inst_v_D,
		inst_out => inst_D
	);

	reg_status_F_D: reg_status PORT MAP(
		clk => clk,
		reset => reg_F_D_reset_DU,
		we => reg_F_D_we,
		pc_in => pc_F,
		priv_status_in => priv_status_F,
		exc_new => exc_F_E,
		exc_code_new => exc_code_F_E,
		exc_data_new => exc_data_F_E,
		exc_old => '0',
		exc_code_old => (OTHERS => 'X'),
		exc_data_old => (OTHERS => 'X'),
		rob_idx_in => rob_idx_F,
		inst_type_in => INST_TYPE_NOP,
		pc_out => pc_D,
		priv_status_out => priv_status_D,
		exc_out => exc_D,
		exc_code_out => exc_code_D,
		exc_data_out => exc_data_D,
		rob_idx_out => rob_idx_D,
		inst_type_out => open
	);

	----------------------------- Decode -------------------------------

	d: decode PORT MAP(
		inst => inst_D,
		inst_v => inst_v_D,
		pc => pc_D,
		priv_status => priv_status_D,
		inst_type => inst_type_D,
		op_code => op_code_D,
		reg_src1 => reg_src1_D,
		reg_src2 => reg_src2_D,
		reg_dest => reg_dest_D,
		inm_ext => inm_ext_D,
		ALU_ctrl => ALU_ctrl_D,
		branch => branch_D,
		branch_if_eq => branch_if_eq_D,
		jump => jump_D,
		reg_src1_v => reg_src1_v_D,
		reg_src2_v => reg_src2_v_D,
		inm_src2_v => inm_src2_v_D,
		mem_write => mem_we_D,
		byte => byte_D,
		mem_read => mem_read_D,
		reg_we => reg_we_D,
		iret => iret_D,
		invalid_inst => invalid_inst_D
	);

	rb: reg_bank PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump_ROB,
		src1 => reg_src1_D,
		src2 => reg_src2_D,
		data1 => reg_data1_D,
		data2 => reg_data2_D,
		we => reg_we_ROB,
		dest => reg_dest_ROB,
		data_in => reg_data_ROB,
		exception => exc_ROB,
		exc_code => exc_code_ROB,
		exc_data => exc_data_ROB
	);

	mux_src1_D_BP : mux8_32bits PORT MAP(
		Din0 => reg_data1_D,
		Din1 => ALU_out_A,
		Din2 => reg_data_C,
		Din3 => mul_out_M5,
		Din4 => reg_src1_D_data_ROB,
		Din5 => (OTHERS => '0'),
		Din6 => (OTHERS => '0'),
		Din7 => (OTHERS => '0'),
		ctrl => mux_src1_D_BP_ctrl,
		Dout => data1_BP_D
	);

	mux_src2_D_BP : mux8_32bits PORT MAP(
		Din0 => reg_data2_D,
		Din1 => ALU_out_A,
		Din2 => reg_data_C,
		Din3 => mul_out_M5,
		Din4 => reg_src2_D_data_ROB,
		Din5 => (OTHERS => '0'),
		Din6 => (OTHERS => '0'),
		Din7 => (OTHERS => '0'),
		ctrl => mux_src2_D_BP_ctrl,
		Dout => data2_BP_D
	);

	mux_mem_data_D_BP : mux8_32bits PORT MAP(
		Din0 => reg_data2_D,
		Din1 => ALU_out_A,
		Din2 => reg_data_C,
		Din3 => mul_out_M5,
		Din4 => reg_src2_D_data_ROB,
		Din5 => (OTHERS => '0'),
		Din6 => (OTHERS => '0'),
		Din7 => (OTHERS => '0'),
		ctrl => mux_mem_data_D_BP_ctrl,
		Dout => mem_data_D_BP
	);

	reg_D_A_reset <= reg_D_A_reset_DU OR exc_D_E;

	reg_D_A: reg_DA PORT MAP(
		clk => clk,
		reset => reg_D_A_reset,
		we => reg_D_A_we,
		mem_we_in => mem_we_D,
		byte_in => byte_D,
		mem_read_in => mem_read_D,
		reg_we_in => reg_we_D,
		branch_in => branch_D,
		branch_if_eq_in => branch_if_eq_D,
		jump_in => jump_D,
		inm_ext_in => inm_ext_D,
		ALU_ctrl_in => ALU_ctrl_D,
		reg_src1_v_in => reg_src1_v_D,
		reg_src2_v_in => reg_src2_v_D,
		inm_src2_v_in => inm_src2_v_D,
		reg_src1_in => reg_src1_D,
		reg_src2_in => reg_src2_D,
		reg_dest_in => reg_dest_D,
		reg_data1_in => data1_BP_D,
		reg_data2_in => data2_BP_D,
		mem_data_in => mem_data_D_BP,
		iret_in => iret_D,
		mem_we_out => mem_we_A,
		byte_out => byte_A,
		mem_read_out => mem_read_A,
		reg_we_out => reg_we_A,
		branch_out => branch_A,
		branch_if_eq_out => branch_if_eq_A,
		jump_out => jump_A,
		inm_ext_out => inm_ext_A,
		ALU_ctrl_out => ALU_ctrl_A,
		reg_src1_v_out => reg_src1_v_A,
		reg_src2_v_out => reg_src2_v_A,
		inm_src2_v_out => inm_src2_v_A,
		reg_src1_out => reg_src1_A,
		reg_src2_out => reg_src2_A,
		reg_dest_out => reg_dest_A,
		reg_data1_out => reg_data1_A,
		reg_data2_out => reg_data2_A,
		mem_data_out => mem_data_A,
		iret_out => iret_A
	);

	reg_status_D_A: reg_status PORT MAP(
		clk => clk,
		reset => reg_D_A_reset_DU,
		we => reg_D_A_we,
		pc_in => pc_D,
		priv_status_in => priv_status_D,
		exc_new => exc_D_E,
		exc_code_new => exc_code_D_E,
		exc_data_new => exc_data_D_E,
		exc_old => exc_D,
		exc_code_old => exc_code_D,
		exc_data_old => exc_data_D,
		rob_idx_in => rob_idx_D,
		inst_type_in => inst_type_D,
		pc_out => pc_A,
		priv_status_out => priv_status_A,
		exc_out => exc_A,
		exc_code_out => exc_code_A,
		exc_data_out => exc_data_A,
		rob_idx_out => rob_idx_A,
		inst_type_out => inst_type_A
	);

	--------------------------------- Execution ------------------------------------------

	jump_or_branch_A <= branch_A OR jump_A;

	mux_src1_A: mux2_32bits PORT MAP(
		DIn0 => reg_data1_A,
		Din1 => pc_A,
		ctrl => jump_or_branch_A,
		Dout => ALU_data1_A
	);

	mux_src2_A: mux2_32bits PORT MAP(
		DIn0 => reg_data2_A,
		Din1 => inm_ext_A,
		ctrl => inm_src2_v_A,
		Dout => ALU_data2_A
	);

	-- Z = '1' when operands equal
	Z <= to_std_logic(reg_data1_A = reg_data2_A);
	branch_taken_A <= (to_std_logic(Z = branch_if_eq_A) AND branch_A) OR jump_A OR iret_A;

	ALU_MIPs: ALU PORT MAP(
		DA => ALU_data1_A,
		DB => ALU_data2_A,
		ALUctrl => ALU_ctrl_A,
		Dout => ALU_out_A
	);

	jump_addr_A <= ALU_out_A;

	mux_mem_data_A_BP : mux4_32bits PORT MAP(
		Din0 => mem_data_A,
		Din1 => reg_data_C,
		Din2 => (OTHERS => '0'),
		DIn3 => mul_out_M5,
		ctrl => mux_mem_data_A_BP_ctrl,
		Dout => mem_data_A_BP
	);

	reg_A_C_reset <= reg_A_C_reset_DU OR exc_A_E;

	reg_A_C : reg_AC PORT MAP(
		clk => clk,
		reset => reg_A_C_reset,
		we => reg_A_C_we,
		mem_we_in => mem_we_A,
		byte_in => byte_A,
		mem_read_in => mem_read_A,
		reg_we_in => reg_we_A,
		reg_dest_in => reg_dest_A,
		ALU_out_in => ALU_out_A,
		mem_data_in => mem_data_A_BP,
		mem_we_out => cache_we_C,
		byte_out => byte_C,
		mem_read_out => cache_re_C,
		reg_we_out => reg_we_C,
		reg_dest_out => reg_dest_C,
		ALU_out_out => ALU_out_C,
		mem_data_out => cache_data_in_C
	);

	reg_status_A_C: reg_status PORT MAP(
		clk => clk,
		reset => reg_A_C_reset_DU,
		we => reg_A_C_we,
		pc_in => pc_A,
		priv_status_in => priv_status_A,
		exc_new => exc_A_E,
		exc_code_new => exc_code_A_E,
		exc_data_new => exc_data_A_E,
		exc_old => exc_A,
		exc_code_old => exc_code_A,
		exc_data_old => exc_data_A,
		rob_idx_in => rob_idx_A,
		inst_type_in => inst_type_A,
		pc_out => pc_C,
		priv_status_out => priv_status_C,
		exc_out => exc_C,
		exc_code_out => exc_code_C,
		exc_data_out => exc_data_C,
		rob_idx_out => rob_idx_C,
		inst_type_out => inst_type_C
	);

	-------------------------------- ALU Pipeline -----------------------------------------

	-- We might get an exception from F. Therefor, we still don't know the type of instruction
	reg_W_ALU_reset <= reset OR NOT (to_std_logic(inst_type_A = INST_TYPE_ALU) OR (to_std_logic(inst_type_A = INST_TYPE_NOP) AND exc_A));

	reg_W_ALU : reg_W PORT MAP (
		clk => clk,
		reset => reg_W_ALU_reset,
		we => '1',
		reg_we_in => reg_we_A,
		reg_dest_in => reg_dest_A,
		reg_data_in => ALU_out_A,
		mem_we_in => '0',
		v => v_W_ALU,
		reg_we_out => reg_we_W_ALU,
		reg_dest_out => reg_dest_W_ALU,
		reg_data_out => reg_data_W_ALU,
		mem_we_out => open
	);

	reg_status_W_ALU: reg_status PORT MAP(
		clk => clk,
		reset => reg_W_ALU_reset,
		we => '1',
		pc_in => pc_A,
		priv_status_in => priv_status_A,
		exc_new => exc_A_E,
		exc_code_new => exc_code_A_E,
		exc_data_new => exc_data_A_E,
		exc_old => exc_A,
		exc_code_old => exc_code_A,
		exc_data_old => exc_data_A,
		rob_idx_in => rob_idx_A,
		inst_type_in => inst_type_A,
		pc_out => pc_W_ALU,
		priv_status_out => open,
		exc_out => exc_W_ALU,
		exc_code_out => exc_code_W_ALU,
		exc_data_out => exc_data_W_ALU,
		rob_idx_out => rob_idx_W_ALU,
		inst_type_out => inst_type_W_ALU
	);

	-------------------------------- Mul Pipeline -----------------------------------------

	mul_M1 <= to_std_logic(inst_type_A = INST_TYPE_MUL);

	Mul_pipeline: ALU_MUL_seg PORT MAP(
		clk => clk,
		reset => reset,
		load => mul_M1,
		done_C => done_C,
		DA => reg_data1_A,
		DB => reg_data2_A,
		reg_dest_in => reg_dest_A,
		reg_we_in => reg_we_A,
		M2_mul => mul_M2,
		reg_dest_M2 => reg_dest_M2,
		M3_mul => mul_M3,
		reg_dest_M3 => reg_dest_M3,
		M4_mul => mul_M4,
		reg_dest_M4 => reg_dest_M4,
		M5_mul => mul_M5,
		reg_dest_out => reg_dest_M5,
		reg_we_out => reg_we_M5,
		Dout => mul_out_M5,
		-- Reg Status signals --
		pc_in => pc_A,
		priv_status_in => priv_status_A,
		exc_new => exc_A_E,
		exc_code_new => exc_code_A_E,
		exc_data_new => exc_data_A_E,
		exc_old => exc_A,
		exc_code_old => exc_code_A,
		exc_data_old => exc_data_A,
		rob_idx_in => rob_idx_A,
		inst_type_in => inst_type_A,
		pc_out => pc_M5,
		priv_status_out => priv_status_M5,
		exc_out => exc_M5,
		exc_code_out => exc_code_M5,
		exc_data_out => exc_data_M5,
		rob_idx_out => rob_idx_M5,
		inst_type_out => inst_type_M5
	);

	reg_W_MUL_reset <= reset OR to_std_logic(inst_type_M5 /= INST_TYPE_MUL) OR NOT mul_M5;

	reg_W_MUL : reg_W PORT MAP (
		clk => clk,
		reset => reg_W_MUL_reset,
		we => '1',
		reg_we_in => reg_we_M5,
		reg_dest_in => reg_dest_M5,
		reg_data_in => mul_out_M5,
		mem_we_in => '0',
		v => v_W_MUL,
		reg_we_out => reg_we_W_MUL,
		reg_dest_out => reg_dest_W_MUL,
		reg_data_out => reg_data_W_MUL,
		mem_we_out => open
	);

	reg_status_W_MUL: reg_status PORT MAP(
		clk => clk,
		reset => reg_W_MUL_reset,
		we => '1',
		pc_in => pc_M5,
		priv_status_in => priv_status_M5,
		exc_new => '0',
		exc_code_new => (OTHERS => '0'),
		exc_data_new => (OTHERS => '0'),
		exc_old => exc_M5,
		exc_code_old => exc_code_M5,
		exc_data_old => exc_data_M5,
		rob_idx_in => rob_idx_M5,
		inst_type_in => inst_type_M5,
		pc_out => pc_W_MUL,
		priv_status_out => open,
		exc_out => exc_W_MUL,
		exc_code_out => exc_code_W_MUL,
		exc_data_out => exc_data_W_MUL,
		rob_idx_out => rob_idx_W_MUL,
		inst_type_out => inst_type_W_MUL
	);

	-------------------------------- Cache  ----------------------------------------------

	cache : cache_stage PORT MAP(
		clk => clk,
		reset => reset,
		priv_status => priv_status_C,
		addr => ALU_out_C,
		data_in => cache_data_in_C,
		data_out => reg_data_C,
		re => cache_re_C,
		we => cache_we_C,
		is_byte => byte_C,
		id => rob_idx_C,
		done => done_C,
		invalid_access => invalid_access_C,
		mem_req => mem_req_C,
		mem_addr => mem_addr_C,
		mem_we => mem_we_C,
		mem_done => mem_done_C,
		mem_data_in => mem_data_in_C,
		mem_data_out => mem_data_out_C,
		sb_store_id => sb_store_id_C,
		sb_store_commit => sb_store_commit_C,
		sb_squash => sb_squash_C
	);

	reg_W_MEM_reset <= reset OR to_std_logic(inst_type_C /= INST_TYPE_MEM) OR NOT done_C;

	reg_W_MEM : reg_W PORT MAP (
		clk => clk,
		reset => reg_W_MEM_reset,
		we => '1',
		reg_we_in => reg_we_C,
		reg_dest_in => reg_dest_C,
		reg_data_in => reg_data_C,
		mem_we_in => cache_we_C,
		v => v_W_MEM,
		reg_we_out => reg_we_W_MEM,
		reg_dest_out => reg_dest_W_MEM,
		reg_data_out => reg_data_W_MEM,
		mem_we_out => mem_we_W_MEM
	);

	reg_status_W_MEM: reg_status PORT MAP(
		clk => clk,
		reset => reg_W_MEM_reset,
		we => '1',
		pc_in => pc_C,
		priv_status_in => priv_status_C,
		exc_new => exc_C_E,
		exc_code_new => exc_code_C_E,
		exc_data_new => exc_data_C_E,
		exc_old => exc_C,
		exc_code_old => exc_code_C,
		exc_data_old => exc_data_C,
		rob_idx_in => rob_idx_C,
		inst_type_in => inst_type_C,
		pc_out => pc_W_MEM,
		priv_status_out => open,
		exc_out => exc_W_MEM,
		exc_code_out => exc_code_W_MEM,
		exc_data_out => exc_data_W_MEM,
		rob_idx_out => rob_idx_W_MEM,
		inst_type_out => inst_type_W_MEM
	);

	---------------------------- Reorder Buffer --------------------------------

	rob : reorder_buffer PORT MAP(
		clk => clk,
		reset => reset,
		-- Memory
		rob_we_1 => v_W_MEM,
		rob_w_pos_1 => rob_idx_W_MEM,
		reg_v_in_1 => reg_we_W_MEM,
		reg_in_1 => reg_dest_W_MEM,
		reg_data_in_1 => reg_data_W_MEM,
		exc_in_1 => exc_W_MEM,
		exc_code_in_1 => exc_code_W_MEM,
		exc_data_in_1 => exc_data_W_MEM,
		pc_in_1 => pc_W_MEM,
		inst_type_1 => INST_TYPE_MEM,
		store_1 => mem_we_W_MEM,
		-- Multiplication
		rob_we_2 => v_W_MUL,
		rob_w_pos_2 => rob_idx_W_MUL,
		reg_v_in_2 => reg_we_W_MUL,
		reg_in_2 => reg_dest_W_MUL,
		reg_data_in_2 => reg_data_W_MUL,
		exc_in_2 => exc_W_MUL,
		exc_code_in_2 => exc_code_W_MUL,
		exc_data_in_2 => exc_data_W_MUL,
		pc_in_2 => pc_W_MUL,
		inst_type_2 => INST_TYPE_MUL,
		-- ALU
		rob_we_3 => v_W_ALU,
		rob_w_pos_3 => rob_idx_W_ALU,
		reg_v_in_3 => reg_we_W_ALU,
		reg_in_3 => reg_dest_W_ALU,
		reg_data_in_3 => reg_data_W_ALU,
		exc_in_3 => exc_W_ALU,
		exc_code_in_3 => exc_code_W_ALU,
		exc_data_in_3 => exc_data_W_ALU,
		pc_in_3 => pc_W_ALU,
		inst_type_3 => INST_TYPE_ALU,
		-- Output
		reg_v_out => reg_we_ROB,
		reg_out => reg_dest_ROB,
		reg_data_out => reg_data_ROB,
		exc_out => exc_ROB,
		exc_code_out => exc_code_ROB,
		exc_data_out => exc_data_ROB,
		pc_out => pc_ROB,
		-- Counter
		tail_we => rob_count_DU,
		rollback_tail => rob_rollback_DU,
		tail_out => rob_idx_F,
		-- Bypasses
		reg_src1_D_BP => reg_src1_D,
		reg_src1_D_v_BP => reg_src1_v_D,
		reg_src1_D_p_BP => reg_src1_D_p_ROB,
		reg_src1_D_inst_type_BP => reg_src1_D_inst_type_ROB,
		reg_src1_D_data_BP => reg_src1_D_data_ROB,
		reg_src2_D_BP => reg_src2_D,
		reg_src2_D_v_BP => reg_src2_v_D,
		reg_src2_D_p_BP => reg_src2_D_p_ROB,
		reg_src2_D_inst_type_BP => reg_src2_D_inst_type_ROB,
		reg_src2_D_data_BP => reg_src2_D_data_ROB,
		-- Store buffer
		sb_store_id => sb_store_id_C,
		sb_store_commit => sb_store_commit_C,
		sb_squash => sb_squash_C
	);

	debug_dump_ROB <= '0';
	pc_out <= pc_ROB;
END structure;

