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
    COMPONENT reg32 IS
        PORT(
            Din : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            clk : IN  STD_LOGIC;
            reset : IN  STD_LOGIC;
            load : IN  STD_LOGIC;
            Dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT adder32 is
        PORT(
            Din0 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            Din1 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            Dout : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT mux2_1 is
        PORT(
            DIn0 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            DIn1 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            ctrl : IN  STD_LOGIC;
            Dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT memory IS
        PORT (clk : IN STD_LOGIC;
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

    COMPONENT fetch IS
        PORT (clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            branch_D : IN STD_LOGIC;
            inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
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

    COMPONENT Banco_ID is
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

    COMPONENT mux2_5bits is
        PORT(
            DIn0 : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
            DIn1 : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
            ctrl : IN  STD_LOGIC;
            Dout : OUT  STD_LOGIC_VECTOR (4 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT BReg
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

    COMPONENT Ext_signo is
        PORT(
            opcode : in STD_LOGIC_VECTOR (6 downto 0);
        	offsethi : in  STD_LOGIC_VECTOR (4 downto 0);
        	offsetm : in  STD_LOGIC_VECTOR (4 downto 0);
        	offsetlo : in  STD_LOGIC_VECTOR (9 downto 0);
            inm_ext : out  STD_LOGIC_VECTOR (31 downto 0)
        );
    END COMPONENT;

    COMPONENT two_bits_shifter is
        PORT(
            Din : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
            Dout : OUT  STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT UC is
        PORT(
            reset : IN STD_LOGIC;
            IR_op_code : IN  STD_LOGIC_VECTOR (6 DOWNTO 0);
            Branch : OUT  STD_LOGIC;
            Jump : OUT STD_LOGIC;
            ALUSrc_A : OUT  STD_LOGIC;
            ALUSrc_B : OUT  STD_LOGIC;
            MemWrite : OUT  STD_LOGIC;
            Byte : OUT STD_LOGIC;
            MemRead : OUT  STD_LOGIC;
            MemtoReg : OUT  STD_LOGIC;
            RegWrite : OUT  STD_LOGIC
        );
    END COMPONENT;

    COMPONENT UA is

        PORT(  
            Rs2 : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
            RW_MEM : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
            RW_WB : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            Rs1 : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
            ALUSrc_A : IN STD_LOGIC;
            ALUSrc_B : IN STD_LOGIC;
            MemWrite_EX : IN STD_LOGIC;
            RegWrite_Mem : IN STD_LOGIC;
            RegWrite_WB : IN STD_LOGIC;
            Mux_ant_A : OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
            Mux_ant_B : OUT  STD_LOGIC_VECTOR (1 DOWNTO 0);
            Mux_ant_C : OUT  STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT UD is
	    PORT(
		    Codigo_OP : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		    ReadMem_EX : IN STD_LOGIC;
		    Rs1_ID : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		    Rs2_ID	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		    Rd_EX	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		    Sout : OUT STD_LOGIC;
		    PC_Write : OUT STD_LOGIC;
		    ID_Write : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT Banco_EX
        PORT(
            clk : IN  STD_LOGIC;
            reset : IN  STD_LOGIC;
            load : IN  STD_LOGIC;
            busA : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            busB : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            busA_EX : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
            busB_EX : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
            inm_ext: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            inm_ext_EX: OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALUSrc_A_ID : IN  STD_LOGIC;
            ALUSrc_B_ID : IN  STD_LOGIC;
            MemWrite_ID : IN  STD_LOGIC;
            Byte_ID : IN STD_LOGIC;
            MemRead_ID : IN  STD_LOGIC;
            MemtoReg_ID : IN  STD_LOGIC;
            RegWrite_ID : IN  STD_LOGIC;
            ALUSrc_A_EX : OUT  STD_LOGIC;
            ALUSrc_B_EX : OUT  STD_LOGIC;
            MemWrite_EX : OUT  STD_LOGIC;
            Byte_EX : OUT STD_LOGIC;
            MemRead_EX : OUT  STD_LOGIC;
            MemtoReg_EX : OUT  STD_LOGIC;
            RegWrite_EX : OUT  STD_LOGIC;
            ALUctrl_ID: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            ALUctrl_EX: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            Reg_Rs2_ID : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            Reg_Rd_ID : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            Reg_Rs1_ID : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
            Reg_Rs2_EX : OUT  STD_LOGIC_VECTOR(4 DOWNTO 0);
            Reg_Rd_EX : OUT  STD_LOGIC_VECTOR(4 DOWNTO 0);
            Reg_Rs1_EX : OUT  STD_LOGIC_VECTOR (4 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT mux4_32bits is
	    PORT(
    	    DIn0 : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
    	    DIn1 : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
    	    DIn2 : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
    	    DIn3 : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
    	    ctrl : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
    	    Dout : OUT  STD_LOGIC_VECTOR (31 DOWNTO 0)
	    );
    END COMPONENT;

    COMPONENT ALU
	    PORT(
    	    DA : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    	    DB : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    	    ALUctrl : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    	    Dout : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT Switch_UD is
	    PORT(
		    Reg_Write : IN STD_LOGIC;
		    Mem_Read : IN STD_LOGIC;
            Byte : IN STD_LOGIC;
		    Mem_Write : IN STD_LOGIC;
		    MemtoReg : IN STD_LOGIC;
		    ALU_Src_A : IN STD_LOGIC;
		    ALU_Src_B : IN STD_LOGIC;
		    ctrl : IN STD_LOGIC;
		    Reg_Write_out : OUT STD_LOGIC;
		    Mem_Read_out : OUT STD_LOGIC;
            Byte_out : OUT STD_LOGIC;
		    Mem_Write_out : OUT STD_LOGIC;
		    MemtoReg_out : OUT STD_LOGIC;
		    ALU_Src_A_out : OUT STD_LOGIC;
		    ALU_Src_B_out : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT Banco_MEM
        PORT(
            ALU_out_EX : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_out_MEM : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
            clk : IN  STD_LOGIC;
            reset : IN  STD_LOGIC;
            load : IN  STD_LOGIC;
            MemWrite_EX : IN  STD_LOGIC;
            Byte_EX : IN STD_LOGIC;
            MemRead_EX : IN  STD_LOGIC;
            MemtoReg_EX : IN  STD_LOGIC;
            RegWrite_EX : IN  STD_LOGIC;
            MemWrite_MEM : OUT  STD_LOGIC;
            Byte_MEM : OUT STD_LOGIC;
            MemRead_MEM : OUT  STD_LOGIC;
            MemtoReg_MEM : OUT  STD_LOGIC;
            RegWrite_MEM : OUT  STD_LOGIC;
            BusB_EX : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            BusB_MEM : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
            RW_EX : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            RW_MEM : OUT  STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT Banco_WB
        PORT(
            ALU_out_MEM : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_out_WB : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
            MEM_out : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            MDR : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
            clk : IN  STD_LOGIC;
            reset : IN  STD_LOGIC;
            load : IN  STD_LOGIC;
            MemtoReg_MEM : IN  STD_LOGIC;
            RegWrite_MEM : IN  STD_LOGIC;
            MemtoReg_WB : OUT  STD_LOGIC;
            RegWrite_WB : OUT  STD_LOGIC;
            RW_MEM : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            RW_WB : OUT  STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;

    -- 1 bit signals
    SIGNAL load_PC_F : STD_LOGIC;
    SIGNAL load_PC_UD: STD_LOGIC;
    SIGNAL RegWrite_ID: STD_LOGIC;
    SIGNAL RegWrite_EX: STD_LOGIC;
    SIGNAL RegWrite_MEM: STD_LOGIC;
    SIGNAL RegWrite_WB: STD_LOGIC;
    SIGNAL Z: STD_LOGIC;
    SIGNAL Branch: STD_LOGIC;
    SIGNAL Jump: STD_LOGIC;
    SIGNAL ALUSrc_A_ID: STD_LOGIC;
    SIGNAL ALUSrc_B_ID: STD_LOGIC;
    SIGNAL ALUSrc_A_EX: STD_LOGIC;
    SIGNAL ALUSrc_B_EX: STD_LOGIC;
    SIGNAL MemtoReg_ID: STD_LOGIC;
    SIGNAL MemtoReg_EX: STD_LOGIC;
    SIGNAL MemtoReg_MEM: STD_LOGIC;
    SIGNAL MemtoReg_WB: STD_LOGIC;
    SIGNAL Byte_ID: STD_LOGIC;
    SIGNAL Byte_EX: STD_LOGIC;
    SIGNAL Byte_MEM: STD_LOGIC;
    SIGNAL MemWrite_ID: STD_LOGIC;
    SIGNAL MemWrite_EX: STD_LOGIC;
    SIGNAL MemWrite_MEM: STD_LOGIC;
    SIGNAL MemRead_ID: STD_LOGIC;
    SIGNAL MemRead_EX: STD_LOGIC;
    SIGNAL MemRead_MEM: STD_LOGIC;
    SIGNAL Reg_Write_UD: STD_LOGIC;
    SIGNAL Mem_Read_UD: STD_LOGIC;
    SIGNAL Byte_UD: STD_LOGIC;
    SIGNAL Mem_Write_UD: STD_LOGIC;
    SIGNAL MemtoReg_UD: STD_LOGIC;
    SIGNAL ALU_Src_A_UD: STD_LOGIC;
    SIGNAL ALU_Src_B_UD: STD_LOGIC;
    SIGNAL switch_ctrl: STD_LOGIC;
    SIGNAL ID_Write: STD_LOGIC;
    SIGNAL done_i : STD_LOGIC;
    SIGNAL Banco_ID_reset : STD_LOGIC;
    SIGNAL mem_req_F : STD_LOGIC;
    SIGNAL mem_done_F : STD_LOGIC;
    -- 32 bits signals
    SIGNAL PC_in: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PC_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL four: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PC4: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DirSalto: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL IR_in: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL IR_ID: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PC_ID: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL inm_ext_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL inm_ext: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL inm_ext_x4: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL BusW: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL BusA: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL BusB: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL BusA_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL BusB_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL BusB_MEM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_out_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_out_MEM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_out_WB: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Mem_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MDR: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Mux_ant_A_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Mux_ant_B_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Mux_ant_C_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PC_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_addr_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- 5 bits signals
    SIGNAL Reg_Rs2_ID: STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL Reg_Rs2_EX: STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL Reg_Rs1_EX: STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL RW_EX: STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL RW_MEM: STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL RW_WB: STD_LOGIC_VECTOR(4 DOWNTO 0);
    -- 3 bits signals
    SIGNAL ALUctrl_ID: STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ALUctrl_EX: STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- 2 bits signals
    SIGNAL Mux_ant_A: STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL Mux_ant_B: STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL Mux_ant_C: STD_LOGIC_VECTOR(1 DOWNTO 0);
    -- 128 bits signals
    SIGNAL mem_data_in_F : STD_LOGIC_VECTOR(127 DOWNTO 0);
BEGIN

    ----------------------------- Fetch -------------------------------

    pc: reg32 PORT MAP(
        Din => PC_next,
        clk => clk,
        reset => reset,
        load => '1',
        Dout => PC_out
    );

    four <= "00000000000000000000000000000100";

    adder_4: adder32 PORT MAP(
        Din0 => PC_out,
        Din1 => four,
        Dout => PC4
    );

    mem: memory PORT MAP (
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

    f: fetch PORT MAP (
        clk => clk,
        reset => reset,
        pc => PC_out,
        branch_D => Branch,
        inst => IR_in,
        load_PC => load_PC_F,
        mem_req => mem_req_F,
        mem_addr => mem_addr_F,
        mem_done => mem_done_F,
        mem_data_in => mem_data_in_F
    );

    Banco_IF_ID: Banco_ID PORT MAP (
        IR_in => IR_in,
        PC_in => PC_out,
        clk => clk,
        reset => Banco_ID_reset,
        load => ID_Write,
        IR_ID => IR_ID,
        PC_ID => PC_ID
    );

    ----------------------------- Decode -------------------------------

    UD_seg: UD PORT MAP(
	    Codigo_OP => IR_ID(31 DOWNTO 25),
    	ReadMem_EX => MemRead_EX,
    	Rs1_ID => IR_ID(19 DOWNTO 15),
    	Rs2_ID => IR_ID(14 DOWNTO 10),
    	Rd_EX => RW_EX,
    	Sout => switch_ctrl,
    	PC_Write => load_PC_UD,
    	ID_Write => ID_Write
    );

    Switch_det: Switch_UD PORT MAP(
    	Reg_Write => RegWrite_ID,
    	Mem_Read => MemRead_ID,
        Byte => Byte_ID,
    	Mem_Write => MemWrite_ID,
    	MemtoReg => MemtoReg_ID,
    	ALU_Src_A => ALUSrc_A_ID,
        ALU_Src_B => ALUSrc_B_ID,
    	ctrl => switch_ctrl,
    	Reg_Write_out => Reg_Write_UD,
    	Mem_Read_out => Mem_Read_UD,
        Byte_out => Byte_UD,
        Mem_Write_out => Mem_Write_UD,
    	MemtoReg_out => MemtoReg_UD,
    	ALU_Src_A_out => ALU_Src_A_UD,
    	ALU_Src_B_out => ALU_Src_B_UD
    );

    Mux_RSrc2: mux2_5bits PORT MAP(
        Din0 => IR_ID(14 DOWNTO 10),
        Din1 => IR_ID(24 DOWNTO 20),
        ctrl => Mem_Write_UD,
        Dout => Reg_Rs2_ID
    );

    Register_bank: BReg PORT MAP(
    	clk => clk,
    	reset => reset,
    	RA => IR_ID(19 DOWNTO 15),
    	RB => Reg_Rs2_ID,
    	RW => RW_WB,
    	BusW => BusW,
        RegWrite => RegWrite_WB,
    	BusA => BusA,
    	BusB => BusB
    );

    sign_ext: Ext_signo PORT MAP(
        opcode => IR_ID(31 downto 25),
        offsethi => IR_ID(24 downto 20),
        offsetm => IR_ID(14 downto 10),
        offsetlo => IR_ID(9 downto 0),
        inm_ext => inm_ext
    );

    two_bits_shift: two_bits_shifter PORT MAP(
    	Din => inm_ext,
    	Dout => inm_ext_x4
    );

    adder_dir: adder32 PORT MAP(
    	Din0 => inm_ext_x4,
    	Din1 => PC_ID,
    	Dout => DirSalto
    );

    Z <= '1' when (busA=busB) else '0';

    UC_seg: UC PORT map(
        reset => reset,
    	IR_op_code => IR_ID(31 DOWNTO 25),
    	Branch => Branch,
        Jump => Jump,
    	ALUSrc_A => ALUSrc_A_ID,
    	ALUSrc_B => ALUSrc_B_ID,
    	MemWrite => MemWrite_ID,
        Byte => Byte_ID,
        MemRead => MemRead_ID,
    	MemtoReg => MemtoReg_ID,
    	RegWrite => RegWrite_ID
    );

    ALUctrl_ID <= IR_ID(27 DOWNTO 25) when IR_ID(31 DOWNTO 28)= "0000" else "000"; 

    Banco_ID_EX: Banco_EX PORT MAP(
	    clk => clk,
	    reset => reset,
	    load => '1',
	    busA => busA,
	    busB => busB,
	    busA_EX => busA_EX,
	    busB_EX => busB_EX,
	    ALUSrc_A_ID => ALU_Src_A_UD,
	    ALUSrc_B_ID => ALU_Src_B_UD,
	    MemWrite_ID => Mem_Write_UD,
        Byte_ID => Byte_UD,
	    MemRead_ID => Mem_Read_UD,
	    MemtoReg_ID => MemtoReg_UD,
	    RegWrite_ID => Reg_Write_UD,
	    ALUSrc_A_EX => ALUSrc_A_EX,
	    ALUSrc_B_EX => ALUSrc_B_EX,
	    MemWrite_EX => MemWrite_EX,
        Byte_EX => Byte_EX,
	    MemRead_EX => MemRead_EX,
	    MemtoReg_EX => MemtoReg_EX,
	    RegWrite_EX => RegWrite_EX,
	    ALUctrl_ID => ALUctrl_ID,
	    ALUctrl_EX => ALUctrl_EX,
	    inm_ext => inm_ext,
	    inm_ext_EX => inm_ext_EX, 
	    Reg_Rs2_ID => Reg_Rs2_ID,
	    Reg_Rd_ID => IR_ID(24 DOWNTO 20),
	    Reg_Rs1_ID => IR_ID(19 DOWNTO 15),
	    Reg_Rs2_EX => Reg_Rs2_EX, 
	    Reg_Rd_EX => RW_EX, 
	    Reg_Rs1_EX => Reg_Rs1_EX
    );

    Banco_ID_reset <= reset OR Branch;
    PC_next <= DirSalto WHEN (Z AND Branch) = '1' OR Jump = '1'
                ELSE PC4 WHEN load_PC_F = '1' AND load_PC_UD = '1'
                ELSE PC_out;

    --------------------------------- Execution ------------------------------------------

    UA_seg: UA PORT map(
	    Rs2 => Reg_Rs2_EX,
	    RW_MEM => RW_MEM,
	    RW_WB => RW_WB,
	    Rs1 => Reg_Rs1_EX,
	    ALUSrc_A => ALUSrc_A_EX,
	    ALUSrc_B => ALUSrc_B_EX,
	    MemWrite_EX => MemWrite_EX,
	    RegWrite_Mem => RegWrite_MEM,
	    RegWrite_WB => RegWrite_WB,
	    Mux_ant_A => Mux_ant_A,
	    Mux_ant_B => Mux_ant_B,
	    Mux_ant_C => Mux_ant_C
    );

    mux_a: mux4_32bits PORT map(
	    Din0 => busA_EX,
	    Din1 => busW,
	    Din2 => ALU_out_MEM,
	    DIn3 => "00000000000000000000000000000000",
	    ctrl => Mux_ant_A,
	    Dout => Mux_ant_A_out
    );

    mux_b: mux4_32bits PORT map(
	    Din0 => busB_EX,
	    Din1 => busW,
	    Din2 => ALU_out_MEM,
	    DIn3 => inm_ext_EX,
	    ctrl => Mux_ant_B,
	    Dout => Mux_ant_B_out
    );

    ALU_MIPs: ALU PORT MAP(
	    DA => Mux_ant_A_out,
	    DB => Mux_ant_B_out,
	    ALUctrl => ALUctrl_EX,
	    Dout => ALU_out_EX
    );

    mux_c : mux4_32bits PORT map(
	    Din0 => busB_EX,
	    Din1 => busW,
	    Din2 => ALU_out_MEM,
	    DIn3 => "00000000000000000000000000000000",
	    ctrl => Mux_ant_C,
	    Dout => Mux_ant_C_out
    );

    Banco_EX_MEM: Banco_MEM PORT MAP(
        ALU_out_EX => ALU_out_EX,
        ALU_out_MEM => ALU_out_MEM,
        clk => clk,
        reset => reset,
        load => '1',
        MemWrite_EX => MemWrite_EX,
        Byte_EX => Byte_EX,
        MemRead_EX => MemRead_EX,
        MemtoReg_EX => MemtoReg_EX,
        RegWrite_EX => RegWrite_EX,
        MemWrite_MEM => MemWrite_MEM,
        Byte_MEM => Byte_MEM,
        MemRead_MEM => MemRead_MEM,
        MemtoReg_MEM => MemtoReg_MEM,
        RegWrite_MEM => RegWrite_MEM,
        BusB_EX => Mux_ant_C_out,
        BusB_MEM => BusB_MEM,
        RW_EX => RW_EX,
        RW_MEM => RW_MEM
    );

    -------------------------------- Memory  ----------------------------------------------

    Mem_D: memoriaRAM_D PORT MAP(
	    CLK => CLK,
	    ADDR => ALU_out_MEM,
	    Din => BusB_MEM,
	    WE => MemWrite_MEM,
	    RE => MemRead_MEM,
	    Dout => Mem_out
    );

    Banco_MEM_WB: Banco_WB PORT MAP(
        ALU_out_MEM => ALU_out_MEM,
        ALU_out_WB => ALU_out_WB,
        Mem_out => Mem_out,
        MDR => MDR,
        clk => clk,
        reset => reset,
        load => '1',
        MemtoReg_MEM => MemtoReg_MEM,
        RegWrite_MEM => RegWrite_MEM,
        MemtoReg_WB => MemtoReg_WB,
        RegWrite_WB => RegWrite_WB,
        RW_MEM => RW_MEM,
        RW_WB => RW_WB
    );

    mux_busW: mux2_1 PORT map(
	    Din0 => ALU_out_WB,
	    DIn1 => MDR,
	    ctrl => MemtoReg_WB,
	    Dout => busW
    );

    output <= IR_ID;

END structure;

