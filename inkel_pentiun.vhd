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

    --COMPONENT memoriaRAM_I IS
    --    PORT(
	--        CLK : IN STD_LOGIC;
	--        ADDR : IN STD_LOGIC_VECTOR (31 DOWNTO 0); --Dir 
    --        Din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);--entrada de datos para el puerto de escritura
    --        WE : IN STD_LOGIC;		-- write enable	
	--        RE : IN STD_LOGIC;		-- read enable		  
	--        Dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	--    );
    --END COMPONENT;

    COMPONENT ram IS
        PORT (clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            req : IN STD_LOGIC;
            we : IN STD_LOGIC;
            done : OUT STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT Banco_ID is
        PORT(
            IR_in : in  STD_LOGIC_VECTOR (31 DOWNTO 0); -- INstrucción leida en IF
            PC4_in:  IN  STD_LOGIC_VECTOR (31 DOWNTO 0); -- PC+4 sumado en IF
	    clk : IN  STD_LOGIC;
	    reset : IN  STD_LOGIC;
            load : IN  STD_LOGIC;
            IR_ID : OUT  STD_LOGIC_VECTOR (31 DOWNTO 0); -- instrucción en la etapa ID
            PC4_ID:  OUT  STD_LOGIC_VECTOR (31 DOWNTO 0) -- PC+4 en la etapa ID
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
            inm : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
            inm_ext : OUT  STD_LOGIC_VECTOR (31 DOWNTO 0)
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
            IR_op_code : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
            Branch : OUT  STD_LOGIC;
            RegDst : OUT  STD_LOGIC;
            ALUSrc_A : OUT  STD_LOGIC;
            ALUSrc_B : OUT  STD_LOGIC;
            MemWrite : OUT  STD_LOGIC;
            MemRead : OUT  STD_LOGIC;
            MemtoReg : OUT  STD_LOGIC;
            RegWrite : OUT  STD_LOGIC
        );
    END COMPONENT;

    COMPONENT UA is
        PORT(  
            Rt : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
            ExMem_Rd : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
            MemWB_Rd : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            Rs : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
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
		    Codigo_OP : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		    ReadMem_EX : IN STD_LOGIC;
		    Rs_ID : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		    Rt_ID	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		    Rt_EX	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
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
            RegDst_ID : IN  STD_LOGIC;
	    ALUSrc_A_ID : IN  STD_LOGIC;
            ALUSrc_B_ID : IN  STD_LOGIC;
            MemWrite_ID : IN  STD_LOGIC;
            MemRead_ID : IN  STD_LOGIC;
            MemtoReg_ID : IN  STD_LOGIC;
            RegWrite_ID : IN  STD_LOGIC;
            RegDst_EX : OUT  STD_LOGIC;
            ALUSrc_A_EX : OUT  STD_LOGIC;
	    ALUSrc_B_EX : OUT  STD_LOGIC;
            MemWrite_EX : OUT  STD_LOGIC;
            MemRead_EX : OUT  STD_LOGIC;
            MemtoReg_EX : OUT  STD_LOGIC;
            RegWrite_EX : OUT  STD_LOGIC;
	    ALUctrl_ID: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
	    ALUctrl_EX: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            Reg_Rt_ID : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            Reg_Rd_ID : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
	    Reg_Rs_ID : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
            Reg_Rt_EX : OUT  STD_LOGIC_VECTOR(4 DOWNTO 0);
            Reg_Rd_EX : OUT  STD_LOGIC_VECTOR(4 DOWNTO 0);
	    Reg_Rs_EX : OUT  STD_LOGIC_VECTOR (4 DOWNTO 0)
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
	     
    COMPONENT mux2_5bits is
	    PORT(
		    DIn0 : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
		    DIn1 : IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
		    ctrl : IN  STD_LOGIC;
		    Dout : OUT  STD_LOGIC_VECTOR (4 DOWNTO 0)
	    );
    END COMPONENT;

    COMPONENT Switch_UD is
	    PORT(
            	Reg_Dst : IN STD_LOGIC;
		    Reg_Write : IN STD_LOGIC;
		    Mem_Read : IN STD_LOGIC;
		    Mem_Write : IN STD_LOGIC;
		    MemtoReg : IN STD_LOGIC;
		    ALU_Src_A : IN STD_LOGIC;
		    ALU_Src_B : IN STD_LOGIC;
		    ctrl : IN STD_LOGIC;
		    Reg_Dst_out : OUT STD_LOGIC;
		    Reg_Write_out : OUT STD_LOGIC;
		    Mem_Read_out : OUT STD_LOGIC;
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
            MemRead_EX : IN  STD_LOGIC;
            MemtoReg_EX : IN  STD_LOGIC;
            RegWrite_EX : IN  STD_LOGIC;
            MemWrite_MEM : OUT  STD_LOGIC;
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
    signal load_PC: STD_LOGIC;
    signal PCSrc: STD_LOGIC;
    signal RegWrite_ID: STD_LOGIC;
    signal RegWrite_EX: STD_LOGIC;
    signal RegWrite_MEM: STD_LOGIC;
    signal RegWrite_WB: STD_LOGIC;
    signal Z: STD_LOGIC;
    signal Branch: STD_LOGIC;
    signal RegDst_ID: STD_LOGIC;
    signal RegDst_EX: STD_LOGIC;
    signal ALUSrc_A_ID: STD_LOGIC;
    signal ALUSrc_B_ID: STD_LOGIC;
    signal ALUSrc_A_EX: STD_LOGIC;
    signal ALUSrc_B_EX: STD_LOGIC;
    signal MemtoReg_ID: STD_LOGIC;
    signal MemtoReg_EX: STD_LOGIC;
    signal MemtoReg_MEM: STD_LOGIC;
    signal MemtoReg_WB: STD_LOGIC;
    signal MemWrite_ID: STD_LOGIC;
    signal MemWrite_EX: STD_LOGIC;
    signal MemWrite_MEM: STD_LOGIC;
    signal MemRead_ID: STD_LOGIC;
    signal MemRead_EX: STD_LOGIC;
    signal MemRead_MEM: STD_LOGIC;
    signal Reg_Dst_UD: STD_LOGIC;
    signal Reg_Write_UD: STD_LOGIC;
    signal Mem_Read_UD: STD_LOGIC;
    signal Mem_Write_UD: STD_LOGIC;
    signal MemtoReg_UD: STD_LOGIC;
    signal ALU_Src_A_UD: STD_LOGIC;
    signal ALU_Src_B_UD: STD_LOGIC;
    signal switch_ctrl: STD_LOGIC;
    signal ID_Write: STD_LOGIC;
    -- 32 bits signals
    signal PC_in: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal PC_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal four: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal PC4: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal DirSalto: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal IR_in: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal IR_ID: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal PC4_ID: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal inm_ext_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal Mux_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal inm_ext: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal inm_ext_x4: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal BusW: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal BusA: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal BusB: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal BusA_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal BusB_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal BusB_MEM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ALU_out_EX: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ALU_out_MEM: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ALU_out_WB: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal Mem_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal MDR: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal Mux_ant_A_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal Mux_ant_B_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal Mux_ant_C_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- 5 bits signals
    signal RW_EX: STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal RW_MEM: STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal RW_WB: STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal Reg_Rd_EX: STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal Reg_Rt_EX: STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal Reg_Rs_EX: STD_LOGIC_VECTOR(4 DOWNTO 0);
    -- 3 bits signals
    signal ALUctrl_ID: STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal ALUctrl_EX: STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- 2 bits signals
    signal Mux_ant_A: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal Mux_ant_B: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal Mux_ant_C: STD_LOGIC_VECTOR(1 DOWNTO 0);

    signal done_i : STD_LOGIC;
BEGIN

    ----------------------------- Fetch -------------------------------

    pc: reg32 PORT map(
        Din => PC_in,
        clk => clk,
        reset => reset,
        load => load_PC,
        Dout => PC_out
    );

    four <= "00000000000000000000000000000100";

    adder_4: adder32 PORT map (
        Din0 => PC_out,
        Din1 => four,
        Dout => PC4
    );

    muxPC: mux2_1 PORT map(
        Din0 => PC4,
        DIn1 => DirSalto,
        ctrl => PCSrc,
        Dout => PC_in
    );

    
    --Mem_I: memoriaRAM_I PORT MAP(
    --    CLK => CLK,
    --    ADDR => PC_out,
    --    Din => "00000000000000000000000000000000",
    --    WE => '0',
    --    RE => '1',
    --    Dout => IR_in
    --);

    Mem_I: ram PORT MAP(
        clk => clk,
        reset => reset,
        req => '1',
        we => '0',
        data_in => (others => 'Z'),
        done => done_i,
        addr => pc_out,
        data_out => IR_in
    );
        
        

    Banco_IF_ID: Banco_ID PORT map(
        IR_in => IR_in,
        PC4_in => PC4,
        clk => clk,
        reset => reset,
        load => ID_Write,
        IR_ID => IR_ID,
        PC4_ID => PC4_ID);

    ----------------------------- Decode -------------------------------

    UD_seg: UD PORT MAP(
	    Codigo_OP => IR_ID(31 DOWNTO 26),
        	ReadMem_EX => MemRead_EX,
        	Rs_ID => IR_ID(25 DOWNTO 21),
        	Rt_ID => IR_ID(20 DOWNTO 16),
        	Rt_EX => Reg_Rt_EX,
        	Sout => switch_ctrl,
        	PC_Write => load_PC,
        	ID_Write => ID_Write
    );
							
    Switch_det: Switch_UD PORT MAP(
       	Reg_Dst => RegDst_ID, 
        	Reg_Write => RegWrite_ID,
        	Mem_Read => MemRead_ID,
        	Mem_Write => MemWrite_ID,
        	MemtoReg => MemtoReg_ID,
        	ALU_Src_A => ALUSrc_A_ID,
	    ALU_Src_B => ALUSrc_B_ID,
        	ctrl => switch_ctrl,
        	Reg_Dst_out => Reg_Dst_UD,
        	Reg_Write_out => Reg_Write_UD,
        	Mem_Read_out => Mem_Read_UD,
	    Mem_Write_out => Mem_Write_UD,
        	MemtoReg_out => MemtoReg_UD,
        	ALU_Src_A_out => ALU_Src_A_UD,
        	ALU_Src_B_out => ALU_Src_B_UD
    );

    Register_bank: BReg PORT MAP(
        	clk => clk,
        	reset => reset,
        	RA => IR_ID(25 DOWNTO 21),
        	RB => IR_ID(20 DOWNTO 16),
        	RW => RW_WB,
        	BusW => BusW, 
	    RegWrite => RegWrite_WB,
        	BusA => BusA,
        	BusB => BusB
    );

    sign_ext: Ext_signo PORT map(
        	inm => IR_ID(15 DOWNTO 0),
        	inm_ext => inm_ext
    );

    two_bits_shift: two_bits_shifter PORT map(
        	Din => inm_ext,
        	Dout => inm_ext_x4
    );

    adder_dir: adder32 PORT map(
        	Din0 => inm_ext_x4,
        	Din1 => PC4_ID,
        	Dout => DirSalto
    );

    Z <= '1' when (busA=busB) else '0';

    UC_seg: UC PORT map(
        	IR_op_code => IR_ID(31 DOWNTO 26),
        	Branch => Branch,
        	RegDst => RegDst_ID, 
        	ALUSrc_A => ALUSrc_A_ID,
        	ALUSrc_B => ALUSrc_B_ID,
        	MemWrite => MemWrite_ID,
	    MemRead => MemRead_ID,
        	MemtoReg => MemtoReg_ID,
        	RegWrite => RegWrite_ID
    );
							
    -- si la operacio?n es aritmetica (es decir: IR_ID(31 DOWNTO 26)= "000001") se mira el campo funct
    -- como solo hay 4 operaciones en la alu, basta con los bits menos significativos del campo func 
    -- de la instruccion
    -- si no es aritmetica le damos el valor de la suma (000)
    ALUctrl_ID <= IR_ID(2 DOWNTO 0) when IR_ID(31 DOWNTO 26)= "000001" else "000"; 

    Banco_ID_EX: Banco_EX PORT MAP(
	    clk => clk,
	    reset => reset,
	    load => '1',
	    busA => busA,
	    busB => busB,
	    busA_EX => busA_EX,
	    busB_EX => busB_EX,
	    RegDst_ID => Reg_Dst_UD,
	    ALUSrc_A_ID => ALU_Src_A_UD,
	    ALUSrc_B_ID => ALU_Src_B_UD,
	    MemWrite_ID => Mem_Write_UD,
	    MemRead_ID => Mem_Read_UD,
	    MemtoReg_ID => MemtoReg_UD,
	    RegWrite_ID => Reg_Write_UD,
	    RegDst_EX => RegDst_EX,
	    ALUSrc_A_EX => ALUSrc_A_EX,
	    ALUSrc_B_EX => ALUSrc_B_EX,
	    MemWrite_EX => MemWrite_EX,
	    MemRead_EX => MemRead_EX,
	    MemtoReg_EX => MemtoReg_EX,
	    RegWrite_EX => RegWrite_EX,
	    ALUctrl_ID => ALUctrl_ID,
	    ALUctrl_EX => ALUctrl_EX,
	    inm_ext => inm_ext,
	    inm_ext_EX=> inm_ext_EX, 
	    Reg_Rt_ID => IR_ID(20 DOWNTO 16),
	    Reg_Rd_ID => IR_ID(15 DOWNTO 11),
	    Reg_Rs_ID => IR_ID(25 DOWNTO 21),
	    Reg_Rt_EX => Reg_Rt_EX, 
	    Reg_Rd_EX => Reg_Rd_EX, 
	    Reg_Rs_EX => Reg_Rs_EX
    );

    PCSrc <= Branch AND Z; -- Ahora mismo solo esta implementada la instruccion de salto BEQ.
     											
    --------------------------------- Execution ------------------------------------------

    UA_seg: UA PORT map(
	    Rt => Reg_Rt_EX,
	    ExMem_Rd => RW_MEM,
	    MemWB_Rd => RW_WB,
	    Rs => Reg_Rs_EX,
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

    mux_dst: mux2_5bits PORT map(
	    Din0 => Reg_Rt_EX, 
	    DIn1 => Reg_Rd_EX, 
	    ctrl => RegDst_EX, 
	    Dout => RW_EX
    );

    Banco_EX_MEM: Banco_MEM PORT MAP(
	    ALU_out_EX => ALU_out_EX, 
	    ALU_out_MEM => ALU_out_MEM, 
	    clk => clk, 
	    reset => reset, 
	    load => '1', 
	    MemWrite_EX => MemWrite_EX,
	    MemRead_EX => MemRead_EX, 
	    MemtoReg_EX => MemtoReg_EX, 
	    RegWrite_EX => RegWrite_EX, 
	    MemWrite_MEM => MemWrite_MEM, 
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

