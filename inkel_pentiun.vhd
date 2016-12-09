LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY inkel_pentiun IS
	PORT(
		clk     : IN  STD_LOGIC;
		reset   : IN  STD_LOGIC;
		output  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
end inkel_pentiun;

ARCHITECTURE structure OF inkel_pentiun IS
	COMPONENT adder32 IS
		PORT(
			Din0 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			Din1 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			Dout : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT mux2_1 IS
		PORT(
			DIn0 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			DIn1 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			ctrl : IN  STD_LOGIC;
			Dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT memory IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
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

	COMPONENT pc IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			addr_jump : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			branch_taken_D : IN STD_LOGIC;
			load_PC_F : IN STD_LOGIC;
			load_PC_UD : IN STD_LOGIC;
			pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT fetch IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			branch_taken_D : IN STD_LOGIC;
			inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_v : OUT STD_LOGIC;
			load_PC : OUT STD_LOGIC;
			mem_req : OUT STD_LOGIC;
			mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_done : IN STD_LOGIC;
			mem_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT memoriaRAM_D IS
		PORT(
			CLK : IN STD_LOGIC;
			ADDR : IN STD_LOGIC_VECTOR (31 DOWNTO 0); --Dir
			Din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);--entrada de datos para el puerto de escritura
			WE : IN STD_LOGIC;		-- write enable
			RE : IN STD_LOGIC;		-- read enable
			Dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT Banco_ID IS
		PORT(
			IR_in : in  STD_LOGIC_VECTOR (31 DOWNTO 0); -- INstrucción leida en IF
			PC_in:  IN  STD_LOGIC_VECTOR (31 DOWNTO 0); -- PC sumado en IF
			clk : IN  STD_LOGIC;
			reset : IN  STD_LOGIC;
			load : IN  STD_LOGIC;
			IR_ID : OUT  STD_LOGIC_VECTOR (31 DOWNTO 0); -- instrucción en la etapa ID
			PC_ID:  OUT  STD_LOGIC_VECTOR (31 DOWNTO 0) -- PC en la etapa ID
		);
	END COMPONENT;

	COMPONENT mux2_5bits IS
		PORT(
			DIn0 : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			DIn1 : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			ctrl : IN STD_LOGIC;
			Dout : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
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

	COMPONENT BReg IS
		PORT(
			clk : IN  STD_LOGIC;
			reset : IN  STD_LOGIC;
			RA : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
			RB : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
			RW : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
			BusW : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			RegWrite : IN  STD_LOGIC;
			BusA : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
			BusB : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT Ext_signo IS
		PORT(
			opcode : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
			offsethi : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			offsetm : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			offsetlo : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			inm_ext : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT two_bits_shifter IS
		PORT(
			Din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT UC IS
		PORT(
			reset : IN STD_LOGIC;
			IR_op_code : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
			Branch : OUT STD_LOGIC;
			Jump : OUT STD_LOGIC;
			ALUSrc_A : OUT STD_LOGIC;
			ALUSrc_B : OUT STD_LOGIC;
			Mul : OUT STD_LOGIC;
			MemWrite : OUT STD_LOGIC;
			Byte : OUT STD_LOGIC;
			MemRead : OUT STD_LOGIC;
			MemtoReg : OUT STD_LOGIC;
			RegWrite : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT UA IS
		PORT(
			Rs2 : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			RW_MEM : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			RW_WB : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			Rs1 : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			ALUSrc_A : IN STD_LOGIC;
			ALUSrc_B : IN STD_LOGIC;
			MemWrite_EX : IN STD_LOGIC;
			RegWrite_Mem : IN STD_LOGIC;
			RegWrite_WB : IN STD_LOGIC;
			Mux_ant_A : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			Mux_ant_B : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			Mux_ant_C : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT UD IS
		PORT(
			Codigo_OP : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
			ReadMem_EX : IN STD_LOGIC;
			Rs1_ID : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			Rs2_ID : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			Rd_EX : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			Mul_det : IN STD_LOGIC;
			Sout : OUT STD_LOGIC;
			PC_Write : OUT STD_LOGIC;
			ID_Write : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT Banco_EX IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			load : IN STD_LOGIC;
			busA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			busB : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			busA_EX : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			busB_EX : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			inm_ext: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			inm_ext_EX: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUSrc_A_ID : IN STD_LOGIC;
			ALUSrc_B_ID : IN STD_LOGIC;
			Mul_ID : IN STD_LOGIC;
			MemWrite_ID : IN STD_LOGIC;
			Byte_ID : IN STD_LOGIC;
			MemRead_ID : IN STD_LOGIC;
			MemtoReg_ID : IN STD_LOGIC;
			RegWrite_ID : IN STD_LOGIC;
			ALUSrc_A_EX : OUT STD_LOGIC;
			ALUSrc_B_EX : OUT STD_LOGIC;
			Mul_EX : OUT STD_LOGIC;
			MemWrite_EX : OUT STD_LOGIC;
			Byte_EX : OUT STD_LOGIC;
			MemRead_EX : OUT STD_LOGIC;
			MemtoReg_EX : OUT STD_LOGIC;
			RegWrite_EX : OUT STD_LOGIC;
			ALUctrl_ID: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			ALUctrl_EX: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			Reg_Rs2_ID : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			Reg_Rd_ID : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			Reg_Rs1_ID : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			Reg_Rs2_EX : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			Reg_Rd_EX : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			Reg_Rs1_EX : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
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
			Mul: IN STD_LOGIC;
			ctrl : IN STD_LOGIC;
			Reg_Write_out : OUT STD_LOGIC;
			Mem_Read_out : OUT STD_LOGIC;
			Byte_out : OUT STD_LOGIC;
			Mem_Write_out : OUT STD_LOGIC;
			MemtoReg_out : OUT STD_LOGIC;
			ALU_Src_A_out : OUT STD_LOGIC;
			ALU_Src_B_out : OUT STD_LOGIC;
			Mul_out : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT Banco_MEM IS
		PORT(
			ALU_out_EX : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU_out_MEM : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			load : IN STD_LOGIC;
			Mul_det : IN STD_LOGIC;
			MemWrite_EX : IN STD_LOGIC;
			Byte_EX : IN STD_LOGIC;
			MemRead_EX : IN STD_LOGIC;
			MemtoReg_EX : IN STD_LOGIC;
			RegWrite_EX : IN STD_LOGIC;
			MemWrite_MEM : OUT STD_LOGIC;
			Byte_MEM : OUT STD_LOGIC;
			MemRead_MEM : OUT STD_LOGIC;
			MemtoReg_MEM : OUT STD_LOGIC;
			RegWrite_MEM : OUT STD_LOGIC;
			BusB_EX : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			BusB_MEM : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			RW_EX : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			RW_MEM : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT Banco_WB IS
		PORT(
			ALU_out_MEM : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU_out_WB : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			MEM_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			MDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			load : IN STD_LOGIC;
			MemtoReg_MEM : IN STD_LOGIC;
			RegWrite_MEM : IN STD_LOGIC;
			MemtoReg_WB : OUT STD_LOGIC;
			RegWrite_WB : OUT STD_LOGIC;
			RW_MEM : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			RW_WB : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
		);
	END COMPONENT;

	-- Fetch stage signals
	SIGNAL load_PC_F : STD_LOGIC;
	SIGNAL inst_v_F : STD_LOGIC;
	SIGNAL mem_req_F : STD_LOGIC;
	SIGNAL mem_done_F : STD_LOGIC;
	SIGNAL pc_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inst_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_addr_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_in_F : STD_LOGIC_VECTOR(127 DOWNTO 0);

	-- Decode stage signals
	SIGNAL branch_D: STD_LOGIC;
	SIGNAL jump_D: STD_LOGIC;
	SIGNAL branch_taken_D : STD_LOGIC;
	SIGNAL reg_we_D : STD_LOGIC;
	SIGNAL mem_read_D : STD_LOGIC;
	SIGNAL byte_D : STD_LOGIC;
	SIGNAL mem_write_D : STD_LOGIC;
	SIGNAL mem_to_reg_D : STD_LOGIC;
	SIGNAL reg_src1_v_D : STD_LOGIC;
	SIGNAL reg_src2_v_D : STD_LOGIC;
	SIGNAL mul_D : STD_LOGIC;
	SIGNAL ALU_ctrl_D: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL reg_src2_D : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL inst_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL calc_addr_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data1_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data2_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inm_ext_D : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- ALU stage signals
	SIGNAL mem_read_A : STD_LOGIC;
	SIGNAL mem_to_reg_A : STD_LOGIC;
	SIGNAL mul_det_A : STD_LOGIC;
	SIGNAL not_mul_det_A : STD_LOGIC;
	SIGNAL mul_ready_A : STD_LOGIC;
	SIGNAL mul_A : STD_LOGIC;
	SIGNAL reg_src1_v_A : STD_LOGIC;
	SIGNAL reg_src2_v_A : STD_LOGIC;
	SIGNAL mem_write_A : STD_LOGIC;
	SIGNAL byte_A : STD_LOGIC;
	SIGNAL reg_we_A : STD_LOGIC;
	SIGNAL ALU_ctrl_A : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL reg_dest_A : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src1_A : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL Reg_src2_A : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data1_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data2_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inm_ext_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_A : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Cache stage signals
	SIGNAL mem_we_C : STD_LOGIC;
	SIGNAL byte_C : STD_LOGIC;
	SIGNAL mem_read_C : STD_LOGIC;
	SIGNAL mem_to_reg_C : STD_LOGIC;
	SIGNAL reg_we_C : STD_LOGIC;
	SIGNAL reg_dest_C: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL ALU_out_C: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL data_in_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL data_out_C: STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Writeback stage signals
	SIGNAL reg_we_WB : STD_LOGIC;
	SIGNAL mem_to_reg_WB: STD_LOGIC;
	SIGNAL reg_dest_WB : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_WB : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_out_WB: STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Segmentation registers signals
	SIGNAL reg_F_D_reset : STD_LOGIC;
	SIGNAL reg_F_D_we : STD_LOGIC;

	-- Stall unit signals
	SIGNAL load_PC_UD : STD_LOGIC;
	SIGNAL mem_read_UD : STD_LOGIC;
	SIGNAL byte_UD : STD_LOGIC;
	SIGNAL mem_write_UD : STD_LOGIC;
	SIGNAL mem_to_reg_UD : STD_LOGIC;
	SIGNAL reg_src1_v_UD : STD_LOGIC;
	SIGNAL reg_src2_v_UD : STD_LOGIC;
	SIGNAL reg_we_UD : STD_LOGIC;
	SIGNAL mul_UD : STD_LOGIC;

	-- 1 bit signals
	SIGNAL Z: STD_LOGIC;
	SIGNAL switch_ctrl: STD_LOGIC;
	SIGNAL done_i : STD_LOGIC;
	-- 32 bits signals
	SIGNAL inm_ext_x4: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Mul_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_WB: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Mux_ant_A_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Mux_ant_B_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- 2 bits signals
	SIGNAL Mux_ant_A: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL Mux_ant_B: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL Mux_ant_C: STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN

	----------------------------- Fetch -------------------------------

	-- TODO: load_PC_UD has to be the signal from the global stall unit,
	-- and load_PC_F should be removed
	reg_pc: pc PORT MAP(
		clk => clk,
		reset => reset,
		addr_jump => calc_addr_D,
		branch_taken_D => branch_taken_D,
		load_PC_F => load_PC_F,
		load_PC_UD => load_PC_UD,
		pc => pc_F
	);

	mem: memory PORT MAP(
		clk => clk,
		reset => reset,
		f_req => mem_req_F,
		d_req => '0',
		d_we => '0',
		f_done => mem_done_F,
		d_done => open, -- Unused output
		f_addr => mem_addr_F,
		d_addr => (OTHERS => 'Z'),
		d_data_in => (OTHERS => 'Z'),
		f_data_out => mem_data_in_F,
		d_data_out => open -- Unusued output
	);

	f: fetch PORT MAP(
		clk => clk,
		reset => reset,
		pc => pc_F,
		branch_taken_D => branch_taken_D,
		inst => inst_F,
		inst_v => inst_v_F,
		load_PC => load_PC_F,
		mem_req => mem_req_F,
		mem_addr => mem_addr_F,
		mem_done => mem_done_F,
		mem_data_in => mem_data_in_F
	);

	reg_F_D: Banco_ID PORT MAP(
		IR_in => inst_F,
		PC_in => pc_F,
		clk => clk,
		reset => reg_F_D_reset,
		load => reg_F_D_we,
		IR_ID => inst_D,
		PC_ID => pc_D
	);

	reg_F_D_reset <= reset OR branch_taken_D OR NOT inst_v_F;

	----------------------------- Decode -------------------------------

	UD_seg: UD PORT MAP(
		Codigo_OP => inst_D(31 DOWNTO 25),
		ReadMem_EX => mem_read_A,
		Rs1_ID => inst_D(19 DOWNTO 15),
		Rs2_ID => inst_D(14 DOWNTO 10),
		Rd_EX => reg_dest_A,
		Mul_det => mul_det_A,
		Sout => switch_ctrl,
		PC_Write => load_PC_UD,
		ID_Write => reg_F_D_we
	);

	Switch_det: Switch_UD PORT MAP(
		Reg_Write => reg_we_D,
		Mem_Read => mem_read_D,
		Byte => byte_D,
		Mem_Write => mem_write_D,
		MemtoReg => mem_to_reg_D,
		ALU_Src_A => reg_src1_v_D,
		ALU_Src_B => reg_src2_v_D,
		Mul => mul_D,
		ctrl => switch_ctrl,
		Reg_Write_out => reg_we_UD,
		Mem_Read_out => mem_read_UD,
		Byte_out => byte_UD,
		Mem_Write_out => mem_write_UD,
		MemtoReg_out => mem_to_reg_UD,
		ALU_Src_A_out => reg_src1_v_UD,
		ALU_Src_B_out => reg_src2_v_UD,
		Mul_out => mul_UD
	);

	Mux_RSrc2: mux2_5bits PORT MAP(
		Din0 => inst_D(14 DOWNTO 10),
		Din1 => inst_D(24 DOWNTO 20),
		ctrl => mem_write_UD,
		Dout => reg_src2_D
	);

	Register_bank: BReg PORT MAP(
		clk => clk,
		reset => reset,
		RA => inst_D(19 DOWNTO 15),
		RB => reg_src2_D,
		RW => reg_dest_WB,
		BusW => reg_data_WB,
		RegWrite => reg_we_WB,
		BusA => reg_data1_D,
		BusB => reg_data2_D
	);

	sign_ext: Ext_signo PORT MAP(
		opcode => inst_D(31 downto 25),
		offsethi => inst_D(24 downto 20),
		offsetm => inst_D(14 downto 10),
		offsetlo => inst_D(9 downto 0),
		inm_ext => inm_ext_D
	);

	two_bits_shift: two_bits_shifter PORT MAP(
		Din => inm_ext_D,
		Dout => inm_ext_x4
	);

	adder_dir: adder32 PORT MAP(
		Din0 => inm_ext_x4,
		Din1 => pc_D,
		Dout => calc_addr_D
	);

	Z <= '1' WHEN (reg_data1_D = reg_data2_D) ELSE '0';

	UC_seg: UC PORT map(
		reset => reset,
		IR_op_code => inst_D(31 DOWNTO 25),
		Branch => branch_D,
		Jump => jump_D,
		ALUSrc_A => reg_src1_v_D,
		ALUSrc_B => reg_src2_v_D,
		Mul => mul_D,
		MemWrite => mem_write_D,
		Byte => byte_D,
		MemRead => mem_read_D,
		MemtoReg => mem_to_reg_D,
		RegWrite => reg_we_D
	);

	ALU_ctrl_D <= inst_D(27 DOWNTO 25) when inst_D(31 DOWNTO 28)= "0000" else "000";
	branch_taken_D <= (Z AND branch_D) OR jump_D;

	reg_D_A: Banco_EX PORT MAP(
		clk => clk,
		reset => reset,
		load => not_mul_det_A,
		busA => reg_data1_D,
		busB => reg_data2_D,
		busA_EX => reg_data1_A,
		busB_EX => reg_data2_A,
		ALUSrc_A_ID => reg_src1_v_UD,
		ALUSrc_B_ID => reg_src2_v_UD,
		Mul_ID => mul_UD,
		MemWrite_ID => mem_write_UD,
		byte_ID => byte_UD,
		MemRead_ID => mem_read_UD,
		MemtoReg_ID => mem_to_reg_UD,
		RegWrite_ID => reg_we_UD,
		ALUSrc_A_EX => reg_src1_v_A,
		ALUSrc_B_EX => reg_src2_v_A,
		Mul_EX => mul_A,
		MemWrite_EX => mem_write_A,
		Byte_EX => byte_A,
		MemRead_EX => mem_read_A,
		MemtoReg_EX => mem_to_reg_A,
		RegWrite_EX => reg_we_A,
		ALUctrl_ID => ALU_ctrl_D,
		ALUctrl_EX => ALU_ctrl_A,
		inm_ext => inm_ext_D,
		inm_ext_EX => inm_ext_A,
		Reg_Rs2_ID => reg_src2_D,
		Reg_Rd_ID => inst_D(24 DOWNTO 20),
		Reg_Rs1_ID => inst_D(19 DOWNTO 15),
		Reg_Rs2_EX => reg_src2_A,
		Reg_Rd_EX => reg_dest_A,
		Reg_Rs1_EX => reg_src1_A
	);

	branch_taken_D <= (Z AND branch_D) OR jump_D;

	--------------------------------- Execution ------------------------------------------

	UA_seg: UA PORT MAP(
		Rs2 => reg_src2_A,
		RW_MEM => reg_dest_C,
		RW_WB => reg_dest_WB,
		Rs1 => reg_src1_A,
		ALUSrc_A => reg_src1_v_A,
		ALUSrc_B => reg_src2_v_A,
		MemWrite_EX => mem_write_A,
		RegWrite_Mem => reg_we_C,
		RegWrite_WB => reg_we_WB,
		Mux_ant_A => Mux_ant_A,
		Mux_ant_B => Mux_ant_B,
		Mux_ant_C => Mux_ant_C
	);

	mux_a: mux4_32bits PORT MAP(
		Din0 => reg_data1_A,
		Din1 => reg_data_WB,
		Din2 => ALU_out_C,
		DIn3 => "00000000000000000000000000000000",
		ctrl => Mux_ant_A,
		Dout => Mux_ant_A_out
	);

	mux_b: mux4_32bits PORT MAP(
		Din0 => reg_data2_A,
		Din1 => reg_data_WB,
		Din2 => ALU_out_C,
		DIn3 => inm_ext_A,
		ctrl => Mux_ant_B,
		Dout => Mux_ant_B_out
	);

	ALU_MIPs: ALU PORT MAP(
		DA => Mux_ant_A_out,
		DB => Mux_ant_B_out,
		ALUctrl => ALU_ctrl_A,
		Dout => ALU_out_A
	);

	Mul_unit: ALU_MUL PORT MAP(
		clk => clk,
		reset => reset,
		load => mul_A,
		DA => Mux_ant_A_out,
		DB => Mux_ant_B_out,
		--Counter => Mul_counter,
		Mul_ready => mul_ready_A,
		Dout => Mul_out
	);

	mux_alu: mux2_32bits PORT MAP(
		Din0 => ALU_out,
		Din1 => Mul_out,
		ctrl => mul_A,
		Dout => ALU_out_A
	);

	mux_c : mux4_32bits PORT MAP(
		Din0 => reg_data2_A,
		Din1 => reg_data_WB,
		Din2 => ALU_out_C,
		DIn3 => "00000000000000000000000000000000",
		ctrl => Mux_ant_C,
		Dout => mem_data_A
	);

	mul_det_A <= mul_A AND NOT(mul_ready_A);
	not_mul_det_A <= NOT (mul_det_A);

	Banco_EX_MEM: Banco_MEM PORT MAP(
		ALU_out_EX => ALU_out_A,
		ALU_out_MEM => ALU_out_C,
		clk => clk,
		reset => reset,
		load => '1',
		Mul_det => mul_det_A,
		MemWrite_EX => mem_write_A,
		Byte_EX => byte_A,
		MemRead_EX => mem_read_A,
		MemtoReg_EX => mem_to_reg_A,
		RegWrite_EX => reg_we_A,
		MemWrite_MEM => mem_we_C,
		Byte_MEM => byte_C,
		MemRead_MEM => mem_read_C,
		MemtoReg_MEM => mem_to_reg_C,
		RegWrite_MEM => reg_we_C,
		BusB_EX => mem_data_A,
		BusB_MEM => data_in_C,
		RW_EX => reg_dest_A,
		RW_MEM => reg_dest_C
	);

	-------------------------------- Memory  ----------------------------------------------

	Mem_D: memoriaRAM_D PORT MAP(
		CLK => CLK,
		ADDR => ALU_out_C,
		Din => data_in_C,
		WE => mem_we_C,
		RE => mem_read_C,
		Dout => data_out_C
	);

	Banco_MEM_WB: Banco_WB PORT MAP(
		ALU_out_MEM => ALU_out_C,
		ALU_out_WB => ALU_out_WB,
		Mem_out => data_out_C,
		MDR => mem_data_out_WB,
		clk => clk,
		reset => reset,
		load => '1',
		MemtoReg_MEM => mem_to_reg_C,
		RegWrite_MEM => reg_we_C,
		MemtoReg_WB => mem_to_reg_WB,
		RegWrite_WB => reg_we_WB,
		RW_MEM => reg_dest_C,
		RW_WB => reg_dest_WB
	);

	mux_busW: mux2_1 PORT map(
		Din0 => ALU_out_WB,
		DIn1 => mem_data_out_WB,
		ctrl => mem_to_reg_WB,
		Dout => reg_data_WB
	);

	output <= inst_D;

END structure;

