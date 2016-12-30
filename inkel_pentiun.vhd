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
	COMPONENT mux2_1 IS
		PORT(
			DIn0 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			DIn1 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			ctrl : IN  STD_LOGIC;
			Dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

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
			debug_dump_in : IN STD_LOGIC;
			pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status_out : OUT STD_LOGIC;
			exc_out : OUT STD_LOGIC;
			exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			debug_dump_out : OUT STD_LOGIC
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
			invalid_inst_D : IN STD_LOGIC;
			inst_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			invalid_access_L : IN STD_LOGIC;
			mem_addr_L : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_F : OUT STD_LOGIC;
			exc_code_F : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_D : OUT STD_LOGIC;
			exc_code_D : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_D : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_A : OUT STD_LOGIC;
			exc_code_A : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_A : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_L : OUT STD_LOGIC;
			exc_code_L : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_L : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
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
			exception : IN STD_LOGIC;
			load_PC : IN STD_LOGIC;
			pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT fetch IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			debug_dump : IN STD_LOGIC;
			pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			branch_taken : IN STD_LOGIC;
			inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_v : OUT STD_LOGIC;
			mem_req : OUT STD_LOGIC;
			mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_done : IN STD_LOGIC;
			mem_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT lookup_stage IS
		PORT(
			clk            : IN  STD_LOGIC;
			reset          : IN  STD_LOGIC;
			debug_dump     : IN  STD_LOGIC;
			addr           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			re             : IN  STD_LOGIC;
			we             : IN  STD_LOGIC;
			is_byte        : IN  STD_LOGIC;
			state          : IN  data_cache_state_t;
			state_nx       : OUT data_cache_state_t;
			hit            : OUT STD_LOGIC;
			done           : OUT STD_LOGIC;
			line_num       : OUT INTEGER RANGE 0 TO 3;
			line_we        : OUT STD_LOGIC;
			lru_line_num   : OUT INTEGER RANGE 0 TO 3;
			invalid_access : OUT STD_LOGIC;
			mem_req        : OUT STD_LOGIC;
			mem_addr       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we         : OUT STD_LOGIC;
			mem_done       : IN  STD_LOGIC
		);
	END COMPONENT;

	COMPONENT cache_stage IS
		PORT(
			clk          : IN STD_LOGIC;
			reset        : IN STD_LOGIC;
			debug_dump   : IN STD_LOGIC;
			addr         : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_in      : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_out     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			we           : IN STD_LOGIC;
			is_byte      : IN STD_LOGIC;
			hit          : IN STD_LOGIC;
			line_num     : IN INTEGER RANGE 0 TO 3;
			line_we      : IN STD_LOGIC;
			line_data    : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			lru_line_num : IN INTEGER RANGE 0 TO 3;
			mem_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg_FD IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			inst_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
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
			srcctrl : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			datactrl : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
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
			pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
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
			mul : OUT STD_LOGIC;
			mem_write : OUT STD_LOGIC;
			byte : OUT STD_LOGIC;
			mem_read : OUT STD_LOGIC;
			mem_to_reg : OUT STD_LOGIC;
			reg_we : OUT STD_LOGIC;
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
			reg_dest_L        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_we_L          : IN STD_LOGIC;
			reg_dest_C        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_we_C          : IN STD_LOGIC;
			mux_src1_D_BP     : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			mux_src2_D_BP     : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			mux_mem_data_D_BP : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			mux_mem_data_A_BP : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			mux_mem_data_L_BP : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT detention_unit IS
		PORT(
			reset          : IN STD_LOGIC;
			reg_src1_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src2_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_dest_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src1_v_D   : IN STD_LOGIC;
			reg_src2_v_D   : IN STD_LOGIC;
			branch_taken_A : IN STD_LOGIC;
			reg_dest_A     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_we_A       : IN STD_LOGIC;
			mem_read_A     : IN STD_LOGIC;
			mul_det_A      : IN STD_LOGIC;
			reg_dest_L     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			mem_read_L     : IN STD_LOGIC;
			done_F         : IN STD_LOGIC;
			done_L         : IN STD_LOGIC;
			exc_D          : IN STD_LOGIC;
			exc_A          : IN STD_LOGIC;
			exc_L          : IN STD_LOGIC;
			exc_C          : IN STD_LOGIC;
			conflict       : OUT STD_LOGIC;
			switch_ctrl    : OUT STD_LOGIC;
			reg_PC_reset   : OUT STD_LOGIC;
			reg_F_D_reset  : OUT STD_LOGIC;
			reg_D_A_reset  : OUT STD_LOGIC;
			reg_A_L_reset  : OUT STD_LOGIC;
			reg_L_C_reset  : OUT STD_LOGIC;
			reg_C_W_reset  : OUT STD_LOGIC;
			reg_PC_we      : OUT STD_LOGIC;
			reg_F_D_we     : OUT STD_LOGIC;
			reg_D_A_we     : OUT STD_LOGIC;
			reg_A_L_we     : OUT STD_LOGIC;
			reg_L_C_we     : OUT STD_LOGIC;
			reg_C_W_we     : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT reg_DA IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			mul_in : IN STD_LOGIC;
			mem_we_in : IN STD_LOGIC;
			byte_in : IN STD_LOGIC;
			mem_read_in : IN STD_LOGIC;
			mem_to_reg_in : IN STD_LOGIC;
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
			mul_out : OUT STD_LOGIC;
			mem_we_out : OUT STD_LOGIC;
			byte_out : OUT STD_LOGIC;
			mem_read_out : OUT STD_LOGIC;
			mem_to_reg_out : OUT STD_LOGIC;
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
			mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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

	COMPONENT ALU IS
		PORT(
			DA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			DB : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU_MUL IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			load : IN STD_LOGIC;
			DA : IN STD_LOGIC_VECTOR (31 downto 0); --entrada 1
			DB : IN STD_LOGIC_VECTOR (31 downto 0); --entrada 2
			--Counter : OUT STD_LOGIC_VECTOR(2 downto 0); --contador de los ciclos restantes para la multiplicacion
			Mul_ready : OUT STD_LOGIC;
			Dout : OUT STD_LOGIC_VECTOR (31 downto 0)
		);
	END COMPONENT;

	COMPONENT Switch_UD IS
		PORT(
			Reg_Write : IN STD_LOGIC;
			Mem_Read : IN STD_LOGIC;
			Byte : IN STD_LOGIC;
			Mem_Write : IN STD_LOGIC;
			MemtoReg : IN STD_LOGIC;
			ALU_Src_A : IN STD_LOGIC;
			ALU_Src_B : IN STD_LOGIC;
			inm_src2_v_D : IN STD_LOGIC;
			Mul: IN STD_LOGIC;
			ctrl : IN STD_LOGIC;
			Reg_Write_out : OUT STD_LOGIC;
			Mem_Read_out : OUT STD_LOGIC;
			Byte_out : OUT STD_LOGIC;
			Mem_Write_out : OUT STD_LOGIC;
			MemtoReg_out : OUT STD_LOGIC;
			ALU_Src_A_out : OUT STD_LOGIC;
			ALU_Src_B_out : OUT STD_LOGIC;
			inm_src2_v_UD : OUT STD_LOGIC;
			Mul_out : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT reg_AL IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			mem_we_in : IN STD_LOGIC;
			byte_in : IN STD_LOGIC;
			mem_read_in : IN STD_LOGIC;
			mem_to_reg_in : IN STD_LOGIC;
			reg_we_in : IN STD_LOGIC;
			reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			ALU_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			cache_state_in : IN data_cache_state_t;
			mem_we_out : OUT STD_LOGIC;
			byte_out : OUT STD_LOGIC;
			mem_read_out : OUT STD_LOGIC;
			mem_to_reg_out : OUT STD_LOGIC;
			reg_we_out : OUT STD_LOGIC;
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			ALU_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			cache_state_out : OUT data_cache_state_t
		);
	END COMPONENT;

	COMPONENT reg_LC IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			mem_we_in : IN STD_LOGIC;
			byte_in : IN STD_LOGIC;
			mem_read_in : IN STD_LOGIC;
			mem_to_reg_in : IN STD_LOGIC;
			reg_we_in : IN STD_LOGIC;
			reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			ALU_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			hit_in : IN STD_LOGIC;
			line_num_in : IN INTEGER RANGE 0 TO 3;
			line_we_in : IN STD_LOGIC;
			line_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			mem_we_out : OUT STD_LOGIC;
			byte_out : OUT STD_LOGIC;
			mem_read_out : OUT STD_LOGIC;
			mem_to_reg_out : OUT STD_LOGIC;
			reg_we_out : OUT STD_LOGIC;
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			ALU_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			hit_out : OUT STD_LOGIC;
			line_num_out : OUT INTEGER RANGE 0 TO 3;
			line_we_out : OUT STD_LOGIC;
			line_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg_CW IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			reg_we_in : IN STD_LOGIC;
			reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			reg_we_out : OUT STD_LOGIC;
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;


	-- Fetch stage signals
	SIGNAL inst_v_F : STD_LOGIC;
	SIGNAL mem_req_F : STD_LOGIC;
	SIGNAL mem_done_F : STD_LOGIC;
	SIGNAL priv_status_F : STD_LOGIC;
	SIGNAL debug_dump_F : STD_LOGIC := '0';
	SIGNAL pc_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inst_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_addr_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_in_F : STD_LOGIC_VECTOR(127 DOWNTO 0);

	-- Decode stage signals
	SIGNAL branch_D : STD_LOGIC;
	SIGNAL jump_D : STD_LOGIC;
	SIGNAL branch_if_eq_D : STD_LOGIC;
	SIGNAL reg_we_D : STD_LOGIC;
	SIGNAL mem_read_D : STD_LOGIC;
	SIGNAL byte_D : STD_LOGIC;
	SIGNAL mem_we_D : STD_LOGIC;
	SIGNAL mem_to_reg_D : STD_LOGIC;
	SIGNAL reg_src1_v_D : STD_LOGIC;
	SIGNAL reg_src2_v_D : STD_LOGIC;
	SIGNAL inm_src2_v_D : STD_LOGIC;
	SIGNAL mul_D : STD_LOGIC;
	SIGNAL switch_ctrl : STD_LOGIC;
	SIGNAL priv_status_D : STD_LOGIC;
	SIGNAL invalid_inst_D : STD_LOGIC;
	SIGNAL debug_dump_D : STD_LOGIC;
	SIGNAL ALU_ctrl_D : STD_LOGIC_VECTOR(2 DOWNTO 0);
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
	SIGNAL mem_data_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
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
	SIGNAL mem_to_reg_A : STD_LOGIC;
	SIGNAL mul_det_A : STD_LOGIC;
	SIGNAL mul_ready_A : STD_LOGIC;
	SIGNAL mul_A : STD_LOGIC;
	SIGNAL reg_src1_v_A : STD_LOGIC;
	SIGNAL reg_src2_v_A : STD_LOGIC;
	SIGNAL inm_src2_v_A : STD_LOGIC;
	SIGNAL mem_we_A : STD_LOGIC;
	SIGNAL byte_A : STD_LOGIC;
	SIGNAL reg_we_A : STD_LOGIC;
	SIGNAL priv_status_A : STD_LOGIC;
	SIGNAL debug_dump_A : STD_LOGIC;
	SIGNAL ALU_ctrl_A : STD_LOGIC_VECTOR(2 DOWNTO 0);
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
	SIGNAL ALU_out_tmp : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mul_out_tmp : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_A_BP : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Lookup stage signals
	SIGNAL cache_re_L : STD_LOGIC;
	SIGNAL cache_we_L : STD_LOGIC;
	SIGNAL byte_L : STD_LOGIC;
	SIGNAL state_L : data_cache_state_t;
	SIGNAL state_nx_L : data_cache_state_t;
	SIGNAL mem_to_reg_L : STD_LOGIC;
	SIGNAL reg_we_L : STD_LOGIC;
	SIGNAL priv_status_L : STD_LOGIC;
	SIGNAL debug_dump_L : STD_LOGIC;
	SIGNAL invalid_access_L : STD_LOGIC;
	SIGNAL reg_dest_L : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL pc_L : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_L : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL cache_data_in_L : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL done_L : STD_LOGIC;
	SIGNAL hit_L : STD_LOGIC;
	SIGNAL line_num_L : INTEGER RANGE 0 TO 3;
	SIGNAL line_we_L : STD_LOGIC;
	SIGNAL lru_line_num_L : INTEGER RANGE 0 TO 3;
	SIGNAL mem_req_L : STD_LOGIC;
	SIGNAL mem_addr_L : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_we_L : STD_LOGIC;
	SIGNAL mem_done_L : STD_LOGIC;
	SIGNAL mem_data_in_L : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL mem_data_out_L : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL mem_data_L_BP : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Cache stage signals
	SIGNAL cache_we_C : STD_LOGIC;
	SIGNAL cache_re_C : STD_LOGIC;
	SIGNAL byte_C : STD_LOGIC;
	SIGNAL mem_to_reg_C : STD_LOGIC;
	SIGNAL reg_we_C : STD_LOGIC;
	SIGNAL priv_status_C : STD_LOGIC;
	SIGNAL debug_dump_C : STD_LOGIC;
	SIGNAL hit_C : STD_LOGIC;
	SIGNAL line_we_C : STD_LOGIC;
	SIGNAL line_num_C : INTEGER RANGE 0 TO 3;
	SIGNAL lru_line_num_C : INTEGER RANGE 0 TO 3;
	SIGNAL reg_dest_C : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL pc_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL cache_data_in_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL cache_data_out_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL line_data_C : STD_LOGIC_VECTOR(127 DOWNTO 0);

	-- Writeback stage signals
	SIGNAL reg_we_W : STD_LOGIC;
	SIGNAL priv_status_W : STD_LOGIC;
	SIGNAL debug_dump_W : STD_LOGIC;
	SIGNAL reg_dest_W : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL pc_W : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data_W : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Segmentation registers signals
	SIGNAL reg_F_D_reset : STD_LOGIC;
	SIGNAL reg_F_D_reset_DU : STD_LOGIC;
	SIGNAL reg_D_A_reset : STD_LOGIC;
	SIGNAL reg_D_A_reset_DU : STD_LOGIC;
	SIGNAL reg_A_L_reset : STD_LOGIC;
	SIGNAL reg_A_L_reset_DU : STD_LOGIC;
	SIGNAL reg_L_C_reset : STD_LOGIC;
	SIGNAL reg_L_C_reset_DU : STD_LOGIC;
	SIGNAL reg_C_W_reset : STD_LOGIC;
	SIGNAL reg_C_W_reset_DU : STD_LOGIC;
	SIGNAL reg_F_D_we : STD_LOGIC;
	SIGNAL reg_D_A_we : STD_LOGIC;
	SIGNAL reg_A_L_we : STD_LOGIC;
	SIGNAL reg_L_C_we : STD_LOGIC;
	SIGNAL reg_C_W_we : STD_LOGIC;

	-- Stall unit signals
	SIGNAL load_PC : STD_LOGIC;
	SIGNAL reset_PC : STD_LOGIC;
	SIGNAL mem_read_UD : STD_LOGIC;
	SIGNAL byte_UD : STD_LOGIC;
	SIGNAL mem_we_UD : STD_LOGIC;
	SIGNAL mem_to_reg_UD : STD_LOGIC;
	SIGNAL reg_src1_v_UD : STD_LOGIC;
	SIGNAL reg_src2_v_UD : STD_LOGIC;
	SIGNAL inm_src2_v_UD : STD_LOGIC;
	SIGNAL reg_we_UD : STD_LOGIC;
	SIGNAL mul_UD : STD_LOGIC;

	-- Bypass unit signals
	SIGNAL mux_src1_D_BP_ctrl : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL mux_src2_D_BP_ctrl : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL mux_mem_data_D_BP_ctrl : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL mux_mem_data_A_BP_ctrl : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL mux_mem_data_L_BP_ctrl : STD_LOGIC;

	-- Exception unit signals
	SIGNAL exc_F_E : STD_LOGIC;
	SIGNAL exc_D : STD_LOGIC;
	SIGNAL exc_D_E : STD_LOGIC;
	SIGNAL exc_A : STD_LOGIC;
	SIGNAL exc_A_E : STD_LOGIC;
	SIGNAL exc_L : STD_LOGIC;
	SIGNAL exc_L_E : STD_LOGIC;
	SIGNAL exc_C : STD_LOGIC;
	SIGNAL exc_C_E : STD_LOGIC;
	SIGNAL exc_W : STD_LOGIC;
	SIGNAL exc_code_F_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_D : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_D_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_A : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_A_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_L : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_L_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_C : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_C_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_W : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_F_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_D_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_A_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_L : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_L_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_C_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_W : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

	mem: memory PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump_C,
		f_req => mem_req_F,
		d_req => mem_req_L,
		d_we => mem_we_L,
		f_done => mem_done_F,
		d_done => mem_done_L,
		f_addr => mem_addr_F,
		d_addr => mem_addr_L,
		d_data_in => mem_data_out_L,
		f_data_out => mem_data_in_F,
		d_data_out => mem_data_in_L
	);

	----------------------------- Control -------------------------------

	exc : exception_unit PORT MAP(
		invalid_inst_D => invalid_inst_D,
		inst_D => inst_D,
		invalid_access_L => invalid_access_L,
		mem_addr_L => ALU_out_L,
		exc_F => exc_F_E,
		exc_code_F => exc_code_F_E,
		exc_data_F => exc_data_F_E,
		exc_D => exc_D_E,
		exc_code_D => exc_code_D_E,
		exc_data_D => exc_data_D_E,
		exc_A => exc_A_E,
		exc_code_A => exc_code_A_E,
		exc_data_A => exc_data_A_E,
		exc_L => exc_L_E,
		exc_code_L => exc_code_L_E,
		exc_data_L => exc_data_L_E,
		exc_C => exc_C_E,
		exc_code_C => exc_code_C_E,
		exc_data_C => exc_data_C_E
	);

	DU : detention_unit PORT MAP(
		reset => reset,
		reg_src1_D => reg_src1_D,
		reg_src2_D => reg_src2_D,
		reg_dest_D => reg_dest_D,
		reg_src1_v_D => reg_src1_v_D,
		reg_src2_v_D => reg_src2_v_D,
		branch_taken_A => branch_taken_A,
		reg_dest_A => reg_dest_A,
		reg_we_A => reg_we_A,
		mem_read_A => mem_read_A,
		mul_det_A => mul_det_A,
		reg_dest_L => reg_dest_L,
		mem_read_L => cache_re_L,
		done_F => inst_v_F,
		done_L => done_L,
		exc_D => exc_D_E,
		exc_A => exc_A_E,
		exc_L => exc_L_E,
		exc_C => exc_C_E,
		conflict => conflict_D,
		switch_ctrl => switch_ctrl,
		reg_PC_reset => reset_PC,
		reg_F_D_reset => reg_F_D_reset_DU,
		reg_D_A_reset => reg_D_A_reset_DU,
		reg_A_L_reset => reg_A_L_reset_DU,
		reg_L_C_reset => reg_L_C_reset_DU,
		reg_C_W_reset => reg_C_W_reset_DU,
		reg_PC_we => load_PC,
		reg_F_D_we => reg_F_D_we,
		reg_D_A_we => reg_D_A_we,
		reg_A_L_we => reg_A_L_we,
		reg_L_C_we => reg_L_C_we,
		reg_C_W_we => reg_C_W_we
	);

	BP : bypass_unit PORT MAP(
		reg_src1_D => reg_src1_D,
		reg_src2_D => reg_src2_D,
		reg_src1_v_D => reg_src1_v_D,
		reg_src2_v_D => reg_src2_v_D,
		inm_src2_v_D => inm_src2_v_D,
		reg_dest_A => reg_dest_A,
		reg_we_A => reg_we_A,
		reg_dest_L => reg_dest_L,
		reg_we_L => reg_we_L,
		reg_dest_C => reg_dest_C,
		reg_we_C => reg_we_C,
		mux_src1_D_BP => mux_src1_D_BP_ctrl,
		mux_src2_D_BP => mux_src2_D_BP_ctrl,
		mux_mem_data_D_BP => mux_mem_data_D_BP_ctrl,
		mux_mem_data_A_BP => mux_mem_data_A_BP_ctrl,
		mux_mem_data_L_BP => mux_mem_data_L_BP_ctrl
	);

	----------------------------- Fetch -------------------------------

	reg_pc: pc PORT MAP(
		clk => clk,
		reset => reset_PC,
		addr_jump => jump_addr_A,
		branch_taken => branch_taken_A,
		exception => exc_W,
		load_PC => load_PC,
		pc => pc_F
	);

	priv_status_F <= exc_W;

	f: fetch PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump_F,
		pc => pc_F,
		branch_taken => branch_taken_A,
		inst => inst_F,
		inst_v => inst_v_F,
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
		inst_in => inst_F,
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
		debug_dump_in => debug_dump_F,
		pc_out => pc_D,
		priv_status_out => priv_status_D,
		exc_out => exc_D,
		exc_code_out => exc_code_D,
		exc_data_out => exc_data_D,
		debug_dump_out => debug_dump_D
	);

	----------------------------- Decode -------------------------------

	d: decode PORT MAP(
		inst => inst_D,
		pc => pc_D,
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
		mul => mul_D,
		mem_write => mem_we_D,
		byte => byte_D,
		mem_read => mem_read_D,
		mem_to_reg => mem_to_reg_D,
		reg_we => reg_we_D,
		invalid_inst => invalid_inst_D
	);

	Switch_det: Switch_UD PORT MAP(
		Reg_Write => reg_we_D,
		Mem_Read => mem_read_D,
		Byte => byte_D,
		Mem_Write => mem_we_D,
		MemtoReg => mem_to_reg_D,
		ALU_Src_A => reg_src1_v_D,
		ALU_Src_B => reg_src2_v_D,
		inm_src2_v_D => inm_src2_v_D,
		Mul => mul_D,
		ctrl => switch_ctrl,
		Reg_Write_out => reg_we_UD,
		Mem_Read_out => mem_read_UD,
		Byte_out => byte_UD,
		Mem_Write_out => mem_we_UD,
		MemtoReg_out => mem_to_reg_UD,
		ALU_Src_A_out => reg_src1_v_UD,
		ALU_Src_B_out => reg_src2_v_UD,
		inm_src2_v_UD => inm_src2_v_UD,
		Mul_out => mul_UD
	);

	rb: reg_bank PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump_W,
		src1 => reg_src1_D,
		src2 => reg_src2_D,
		srcctrl => "00",
		data1 => reg_data1_D,
		data2 => reg_data2_D,
		datactrl => open,
		we => reg_we_W,
		dest => reg_dest_W,
		data_in => reg_data_W,
		exception => exc_W,
		exc_code => exc_code_W,
		exc_data => exc_data_W
	);

	mux_src1_D_BP : mux4_32bits PORT MAP(
		Din0 => reg_data1_D,
		Din1 => reg_data_C,
		Din2 => ALU_out_L,
		Din3 => ALU_out_A,
		ctrl => mux_src1_D_BP_ctrl,
		Dout => data1_BP_D
	);

	mux_src2_D_BP : mux4_32bits PORT MAP(
		Din0 => reg_data2_D,
		Din1 => reg_data_C,
		Din2 => ALU_out_L,
		Din3 => ALU_out_A,
		ctrl => mux_src2_D_BP_ctrl,
		Dout => data2_BP_D
	);

	mux_mem_data_D_BP : mux4_32bits PORT MAP(
		Din0 => reg_data2_D,
		Din1 => reg_data_C,
		Din2 => ALU_out_L,
		Din3 => ALU_out_A,
		ctrl => mux_mem_data_D_BP_ctrl,
		Dout => mem_data_D
	);

	reg_D_A_reset <= reg_D_A_reset_DU OR exc_D_E;

	reg_D_A: reg_DA PORT MAP(
		clk => clk,
		reset => reg_D_A_reset,
		we => reg_D_A_we,
		mul_in => mul_UD,
		mem_we_in => mem_we_UD,
		byte_in => byte_UD,
		mem_read_in => mem_read_UD,
		mem_to_reg_in => mem_to_reg_UD,
		reg_we_in => reg_we_UD,
		branch_in => branch_D,
		branch_if_eq_in => branch_if_eq_D,
		jump_in => jump_D,
		inm_ext_in => inm_ext_D,
		ALU_ctrl_in => ALU_ctrl_D,
		reg_src1_v_in => reg_src1_v_UD,
		reg_src2_v_in => reg_src2_v_UD,
		inm_src2_v_in => inm_src2_v_UD,
		reg_src1_in => reg_src1_D,
		reg_src2_in => reg_src2_D,
		reg_dest_in => reg_dest_D,
		reg_data1_in => data1_BP_D,
		reg_data2_in => data2_BP_D,
		mem_data_in => mem_data_D,
		mul_out => mul_A,
		mem_we_out => mem_we_A,
		byte_out => byte_A,
		mem_read_out => mem_read_A,
		mem_to_reg_out => mem_to_reg_A,
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
		mem_data_out => mem_data_A
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
		debug_dump_in => debug_dump_D,
		pc_out => pc_A,
		priv_status_out => priv_status_A,
		exc_out => exc_A,
		exc_code_out => exc_code_A,
		exc_data_out => exc_data_A,
		debug_dump_out => debug_dump_A
	);

	--------------------------------- Execution ------------------------------------------

	jump_or_branch_A <= branch_A OR jump_A;

	mux_src1_A: mux2_1 PORT MAP(
		DIn0 => reg_data1_A,
		Din1 => pc_A,
		ctrl => jump_or_branch_A,
		Dout => ALU_data1_A
	);

	mux_src2_A: mux2_1 PORT MAP(
		DIn0 => reg_data2_A,
		Din1 => inm_ext_A,
		ctrl => inm_src2_v_A,
		Dout => ALU_data2_A
	);

	-- Z = '1' when operands equal
	Z <= to_std_logic(reg_data1_A = reg_data2_A);
	branch_taken_A <= (to_std_logic(Z = branch_if_eq_A) AND branch_A) OR jump_A;

	ALU_MIPs: ALU PORT MAP(
		DA => ALU_data1_A,
		DB => ALU_data2_A,
		ALUctrl => ALU_ctrl_A,
		Dout => ALU_out_tmp
	);

	jump_addr_A <= ALU_out_tmp;

	Mul_unit: ALU_MUL PORT MAP(
		clk => clk,
		reset => reset,
		load => mul_A,
		DA => reg_data1_A,
		DB => ALU_data2_A,
		--Counter => Mul_counter,
		Mul_ready => mul_ready_A,
		Dout => mul_out_tmp
	);

	mux_alu: mux2_32bits PORT MAP(
		Din0 => ALU_out_tmp,
		Din1 => mul_out_tmp,
		ctrl => mul_A,
		Dout => ALU_out_A
	);

	mul_det_A <= mul_A AND NOT(mul_ready_A);

	mux_mem_data_A_BP : mux4_32bits PORT MAP(
		Din0 => mem_data_A,
		Din1 => reg_data_C,
		Din2 => ALU_out_L,
		DIn3 => x"00000000",
		ctrl => mux_mem_data_A_BP_ctrl,
		Dout => mem_data_A_BP
	);

	reg_A_L_reset <= reg_A_L_reset_DU OR exc_A_E;

	reg_A_L : reg_AL PORT MAP(
		clk => clk,
		reset => reg_A_L_reset,
		we => reg_A_L_we,
		mem_we_in => mem_we_A,
		byte_in => byte_A,
		mem_read_in => mem_read_A,
		mem_to_reg_in => mem_to_reg_A,
		reg_we_in => reg_we_A,
		reg_dest_in => reg_dest_A,
		ALU_out_in => ALU_out_A,
		mem_data_in => mem_data_A_BP,
		cache_state_in => state_nx_L,
		mem_we_out => cache_we_L,
		byte_out => byte_L,
		mem_read_out => cache_re_L,
		mem_to_reg_out => mem_to_reg_L,
		reg_we_out => reg_we_L,
		reg_dest_out => reg_dest_L,
		ALU_out_out => ALU_out_L,
		mem_data_out => cache_data_in_L,
		cache_state_out => state_L
	);

	reg_status_A_L: reg_status PORT MAP(
		clk => clk,
		reset => reg_A_L_reset_DU,
		we => reg_A_L_we,
		pc_in => pc_A,
		priv_status_in => priv_status_A,
		exc_new => exc_A_E,
		exc_code_new => exc_code_A_E,
		exc_data_new => exc_data_A_E,
		exc_old => exc_A,
		exc_code_old => exc_code_A,
		exc_data_old => exc_data_A,
		debug_dump_in => debug_dump_A,
		pc_out => pc_L,
		priv_status_out => priv_status_L,
		exc_out => exc_L,
		exc_code_out => exc_code_L,
		exc_data_out => exc_data_L,
		debug_dump_out => debug_dump_L
	);

	-------------------------------- Lookup  ----------------------------------------------

	lookup : lookup_stage PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump_L,
		addr => ALU_out_L,
		re => cache_re_L,
		we => cache_we_L,
		is_byte => byte_L,
		state => state_L,
		state_nx => state_nx_L,
		hit => hit_L,
		done => done_L,
		line_num => line_num_L,
		line_we => line_we_L,
		lru_line_num => lru_line_num_L,
		invalid_access => invalid_access_L,
		mem_req => mem_req_L,
		mem_addr => mem_addr_L,
		mem_we => mem_we_L,
		mem_done => mem_done_L
	);

	mux_mem_data_L_BP : mux2_32bits PORT MAP(
		Din0 => cache_data_in_L,
		Din1 => reg_data_C,
		ctrl => mux_mem_data_L_BP_ctrl,
		Dout => mem_data_L_BP
	);

	reg_L_C_reset <= reg_L_C_reset_DU OR exc_L_E;

	reg_L_C : reg_LC PORT MAP(
		clk => clk,
		reset => reg_L_C_reset,
		we => reg_L_C_we,
		mem_we_in => cache_we_L,
		byte_in => byte_L,
		mem_read_in => cache_re_L,
		mem_to_reg_in => mem_to_reg_L,
		reg_we_in => reg_we_L,
		reg_dest_in => reg_dest_L,
		ALU_out_in => ALU_out_L,
		mem_data_in => mem_data_L_BP,
		hit_in => hit_L,
		line_num_in => line_num_L,
		line_we_in => line_we_L,
		line_data_in => mem_data_in_L,
		mem_we_out => cache_we_C,
		byte_out => byte_C,
		mem_read_out => cache_re_C,
		mem_to_reg_out => mem_to_reg_C,
		reg_we_out => reg_we_C,
		reg_dest_out => reg_dest_C,
		ALU_out_out => ALU_out_C,
		mem_data_out => cache_data_in_C,
		hit_out => hit_C,
		line_num_out => line_num_C,
		line_we_out => line_we_C,
		line_data_out => line_data_C
	);

	reg_status_L_C : reg_status PORT MAP(
		clk => clk,
		reset => reg_L_C_reset_DU,
		we => reg_L_C_we,
		pc_in => pc_L,
		priv_status_in => priv_status_L,
		exc_new => exc_L_E,
		exc_code_new => exc_code_L_E,
		exc_data_new => exc_data_L_E,
		exc_old => exc_L,
		exc_code_old => exc_code_L,
		exc_data_old => exc_data_L,
		debug_dump_in => debug_dump_L,
		pc_out => pc_C,
		priv_status_out => priv_status_C,
		exc_out => exc_C,
		exc_code_out => exc_code_C,
		exc_data_out => exc_data_C,
		debug_dump_out => debug_dump_C
	);

	-------------------------------- Cache  ----------------------------------------------

	cache : cache_stage PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump_C,
		addr => ALU_out_C,
		data_in => cache_data_in_C,
		data_out => cache_data_out_C,
		we => cache_we_C,
		is_byte => byte_C,
		hit => hit_C,
		line_num => line_num_C,
		line_we => line_we_C,
		line_data => line_data_C,
		lru_line_num => lru_line_num_L,
		mem_data_out => mem_data_out_L
	);

	mux_reg_data_C: mux2_1 PORT MAP(
		Din0 => ALU_out_C,
		DIn1 => cache_data_out_C,
		ctrl => mem_to_reg_C,
		Dout => reg_data_C
	);

	reg_C_W_reset <= reg_C_W_reset_DU OR exc_C_E;

	reg_C_W: reg_CW PORT MAP(
		clk => clk,
		reset => reg_C_W_reset,
		we => reg_C_W_we,
		reg_we_in => reg_we_C,
		reg_dest_in => reg_dest_C,
		reg_data_in => reg_data_C,
		reg_we_out => reg_we_W,
		reg_dest_out => reg_dest_W,
		reg_data_out => reg_data_W
	);

	reg_status_C_W: reg_status PORT MAP(
		clk => clk,
		reset => reg_C_W_reset_DU,
		we => reg_C_W_we,
		pc_in => pc_C,
		priv_status_in => priv_status_C,
		exc_new => exc_C_E,
		exc_code_new => exc_code_C_E,
		exc_data_new => exc_data_C_E,
		exc_old => exc_C,
		exc_code_old => exc_code_C,
		exc_data_old => exc_data_C,
		debug_dump_in => debug_dump_C,
		pc_out => pc_W,
		priv_status_out => priv_status_W,
		exc_out => exc_W,
		exc_code_out => exc_code_W,
		exc_data_out => exc_data_W,
		debug_dump_out => debug_dump_W
	);

	pc_out <= pc_W;

END structure;

