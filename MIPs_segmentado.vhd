----------------------------------------------------------------------------------
-- Description: Mips segmentado tal y como lo hemos estudiado en clase. Sus características son:
-- Saltos 1-retardados
-- instrucciones aritméticas, LW, SW y BEQ
-- MI y MD de 128 palabras de 32 bits
-- Registro de salida de 32 bits mapeado en la dirección FFFFFFFF. Si haces un SW en esa dirección se escribe en este registro y no en la memoria
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MIPs_segmentado is
    Port(
        clk : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        output : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end MIPs_segmentado;

architecture Behavioral of MIPs_segmentado is
component reg32 is
    Port(   
        Din : in  STD_LOGIC_VECTOR (31 downto 0);
        clk : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        load : in  STD_LOGIC;
        Dout : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end component;

component adder32 is
    Port(
        Din0 : in  STD_LOGIC_VECTOR (31 downto 0);
        Din1 : in  STD_LOGIC_VECTOR (31 downto 0);
        Dout : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end component;

component mux2_1 is
    Port(
        DIn0 : in  STD_LOGIC_VECTOR (31 downto 0);
        DIn1 : in  STD_LOGIC_VECTOR (31 downto 0);
        ctrl : in  STD_LOGIC;
        Dout : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end component;

component memoriaRAM_D is port(
	CLK : in std_logic;
	ADDR : in std_logic_vector (31 downto 0); --Dir 
    	Din : in std_logic_vector (31 downto 0);--entrada de datos para el puerto de escritura
    	WE : in std_logic;		-- write enable	
	RE : in std_logic;		-- read enable		  
	Dout : out std_logic_vector (31 downto 0)
);
end component;

component memoriaRAM_I is port(
	CLK : in std_logic;
	ADDR : in std_logic_vector (31 downto 0); --Dir 
    	Din : in std_logic_vector (31 downto 0);--entrada de datos para el puerto de escritura
    	WE : in std_logic;		-- write enable	
	RE : in std_logic;		-- read enable		  
	Dout : out std_logic_vector (31 downto 0));
end component;

component Banco_ID is
    Port(
        IR_in : in  STD_LOGIC_VECTOR (31 downto 0); -- instruccion leida en IF
        PC4_in:  in  STD_LOGIC_VECTOR (31 downto 0); -- PC+4 sumado en IF
	clk : in  STD_LOGIC;
	reset : in  STD_LOGIC;
        load : in  STD_LOGIC;
        IR_ID : out  STD_LOGIC_VECTOR (31 downto 0); -- instruccion en la etapa ID
        PC4_ID:  out  STD_LOGIC_VECTOR (31 downto 0) -- PC+4 en la etapa ID
    ); 
end component;

COMPONENT BReg
    PORT(
        clk : IN  std_logic;
	reset : in  STD_LOGIC;
        RA : IN  std_logic_vector(4 downto 0);
        RB : IN  std_logic_vector(4 downto 0);
        RW : IN  std_logic_vector(4 downto 0);
        BusW : IN  std_logic_vector(31 downto 0);
        RegWrite : IN  std_logic;
        BusA : OUT  std_logic_vector(31 downto 0);
        BusB : OUT  std_logic_vector(31 downto 0)
    );
END COMPONENT;

component Ext_signo is
    Port(
        inm : in  STD_LOGIC_VECTOR (15 downto 0);
        inm_ext : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end component;

component two_bits_shifter is
    Port(
        Din : in  STD_LOGIC_VECTOR (31 downto 0);
        Dout : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end component;

component UC is
    Port(
        IR_op_code : in  STD_LOGIC_VECTOR (5 downto 0);
        Branch : out  STD_LOGIC;
        RegDst : out  STD_LOGIC;
        ALU_Src_A : out  STD_LOGIC;
        ALU_Src_B : out  STD_LOGIC;
        MemWrite : out  STD_LOGIC;
        MemRead : out  STD_LOGIC;
        MemtoReg : out  STD_LOGIC;
        RegWrite : out  STD_LOGIC
    );
end component;

component UA is
    Port(  
        Rt : in  STD_LOGIC_VECTOR (4 downto 0);
        ExMem_Rd : in  STD_LOGIC_VECTOR (4 downto 0);
        MemWB_Rd : in STD_LOGIC_VECTOR (4 downto 0);
        Rs : in  STD_LOGIC_VECTOR (4 downto 0);
        ALU_Src_A : in STD_LOGIC;
        ALU_Src_B : in STD_LOGIC;
        MemWrite_EX : in STD_LOGIC;
        RegWrite_Mem : in STD_LOGIC;
        RegWrite_WB : in STD_LOGIC;
        Mux_ant_A : out  STD_LOGIC_VECTOR (1 downto 0);
        Mux_ant_B : out  STD_LOGIC_VECTOR (1 downto 0);
        Mux_ant_C : out  STD_LOGIC_VECTOR (1 downto 0)
    );
end component;

component UD is
	Port(
		Codigo_OP : in STD_LOGIC_VECTOR(5 downto 0);
		ReadMem_EX : in STD_LOGIC;
		Rs_ID : in STD_LOGIC_VECTOR (4 downto 0);
		Rt_ID	: in STD_LOGIC_VECTOR (4 downto 0);
		Rt_EX	: in STD_LOGIC_VECTOR (4 downto 0);
		Sout : out STD_LOGIC;
		PC_Write : out STD_LOGIC;
		ID_Write : out STD_LOGIC
    	);
end component; 

COMPONENT Banco_EX
    PORT(
        clk : IN  std_logic;
        reset : IN  std_logic;
        load : IN  std_logic;
        busA : IN  std_logic_vector(31 downto 0);
        busB : IN  std_logic_vector(31 downto 0);
        busA_EX : OUT  std_logic_vector(31 downto 0);
        busB_EX : OUT  std_logic_vector(31 downto 0);
	inm_ext: IN  std_logic_vector(31 downto 0);
	inm_ext_EX: OUT  std_logic_vector(31 downto 0);
        RegDst_ID : IN  std_logic;
	ALU_Src_A_ID : IN  std_logic;
        ALU_Src_B_ID : IN  std_logic;
        MemWrite_ID : IN  std_logic;
        MemRead_ID : IN  std_logic;
        MemtoReg_ID : IN  std_logic;
        RegWrite_ID : IN  std_logic;
        RegDst_EX : OUT  std_logic;
        ALU_Src_A_EX : OUT  std_logic;
	ALU_Src_B_EX : OUT  std_logic;
        MemWrite_EX : OUT  std_logic;
        MemRead_EX : OUT  std_logic;
        MemtoReg_EX : OUT  std_logic;
        RegWrite_EX : OUT  std_logic;
	ALUctrl_ID: in STD_LOGIC_VECTOR (2 downto 0);
	ALUctrl_EX: out STD_LOGIC_VECTOR (2 downto 0);
        Reg_Rt_ID : IN  std_logic_vector(4 downto 0);
        Reg_Rd_ID : IN  std_logic_vector(4 downto 0);
	Reg_Rs_ID : in  STD_LOGIC_VECTOR (4 downto 0);
        Reg_Rt_EX : OUT  std_logic_vector(4 downto 0);
        Reg_Rd_EX : OUT  std_logic_vector(4 downto 0);
	Reg_Rs_EX : OUT  STD_LOGIC_VECTOR (4 downto 0)
    );
END COMPONENT;

component mux4_32bits is
	Port(
    	    DIn0 : in  STD_LOGIC_VECTOR (31 downto 0);
    	    DIn1 : in  STD_LOGIC_VECTOR (31 downto 0);
    	    DIn2 : in  STD_LOGIC_VECTOR (31 downto 0);
    	    DIn3 : in  STD_LOGIC_VECTOR (31 downto 0);
    	    ctrl : in  STD_LOGIC_VECTOR (1 downto 0);
    	    Dout : out  STD_LOGIC_VECTOR (31 downto 0)
	);
end component;

COMPONENT ALU
	PORT(
    	    DA : IN  std_logic_vector(31 downto 0);
    	    DB : IN  std_logic_vector(31 downto 0);
    	    ALUctrl : IN  std_logic_vector(2 downto 0);
    	    Dout : OUT  std_logic_vector(31 downto 0)
    	);
END COMPONENT;
	 
component mux2_5bits is
	Port(
		DIn0 : in  STD_LOGIC_VECTOR (4 downto 0);
		DIn1 : in  STD_LOGIC_VECTOR (4 downto 0);
		ctrl : in  STD_LOGIC;
		Dout : out  STD_LOGIC_VECTOR (4 downto 0)
	);
end component;

component Switch_UD is
	Port(
        	Reg_Dst : in STD_LOGIC;
		Reg_Write : in STD_LOGIC;
		Mem_Read : in STD_LOGIC;
		Mem_Write : in STD_LOGIC;
		MemtoReg : in STD_LOGIC;
		ALU_Src_A : in STD_LOGIC;
		ALU_Src_B : in STD_LOGIC;
		ctrl : in STD_LOGIC;
		Reg_Dst_out : out STD_LOGIC;
		Reg_Write_out : out STD_LOGIC;
		Mem_Read_out : out STD_LOGIC;
		Mem_Write_out : out STD_LOGIC;
		MemtoReg_out : out STD_LOGIC;
		ALU_Src_A_out : out STD_LOGIC;
		ALU_Src_B_out : out STD_LOGIC
    	);
end component;
	
COMPONENT Banco_MEM
    PORT(
        ALU_out_EX : IN  std_logic_vector(31 downto 0);
        ALU_out_MEM : OUT  std_logic_vector(31 downto 0);
        clk : IN  std_logic;
        reset : IN  std_logic;
        load : IN  std_logic;
        MemWrite_EX : IN  std_logic;
        MemRead_EX : IN  std_logic;
        MemtoReg_EX : IN  std_logic;
        RegWrite_EX : IN  std_logic;
        MemWrite_MEM : OUT  std_logic;
        MemRead_MEM : OUT  std_logic;
        MemtoReg_MEM : OUT  std_logic;
        RegWrite_MEM : OUT  std_logic;
        BusB_EX : IN  std_logic_vector(31 downto 0);
        BusB_MEM : OUT  std_logic_vector(31 downto 0);
        RW_EX : IN  std_logic_vector(4 downto 0);
        RW_MEM : OUT  std_logic_vector(4 downto 0)
    );
END COMPONENT;
 
COMPONENT Banco_WB
PORT(
    ALU_out_MEM : IN  std_logic_vector(31 downto 0);
    ALU_out_WB : OUT  std_logic_vector(31 downto 0);
    MEM_out : IN  std_logic_vector(31 downto 0);
    MDR : OUT  std_logic_vector(31 downto 0);
    clk : IN  std_logic;
    reset : IN  std_logic;
    load : IN  std_logic;
    MemtoReg_MEM : IN  std_logic;
    RegWrite_MEM : IN  std_logic;
    MemtoReg_WB : OUT  std_logic;
    RegWrite_WB : OUT  std_logic;
    RW_MEM : IN  std_logic_vector(4 downto 0);
    RW_WB : OUT  std_logic_vector(4 downto 0)
);
END COMPONENT; 

-- 1 bit signals
signal load_PC: std_logic;
signal PCSrc: std_logic;
signal RegWrite_ID: std_logic;
signal RegWrite_EX: std_logic;
signal RegWrite_MEM: std_logic;
signal RegWrite_WB: std_logic;
signal Z: std_logic;
signal Branch: std_logic;
signal RegDst_ID: std_logic;
signal RegDst_EX: std_logic;
signal ALU_Src_A_ID: std_logic;
signal ALU_Src_B_ID: std_logic;
signal ALU_Src_A_EX: std_logic;
signal ALU_Src_B_EX: std_logic;
signal MemtoReg_ID: std_logic;
signal MemtoReg_EX: std_logic;
signal MemtoReg_MEM: std_logic;
signal MemtoReg_WB: std_logic;
signal MemWrite_ID: std_logic;
signal MemWrite_EX: std_logic;
signal MemWrite_MEM: std_logic;
signal MemRead_ID: std_logic;
signal MemRead_EX: std_logic;
signal MemRead_MEM: std_logic;
signal Reg_Dst_UD: std_logic;
signal Reg_Write_UD: std_logic;
signal Mem_Read_UD: std_logic;
signal Mem_Write_UD: std_logic;
signal MemtoReg_UD: std_logic;
signal ALU_Src_A_UD: std_logic;
signal ALU_Src_B_UD: std_logic;
signal switch_ctrl: std_logic;
signal ID_Write: std_logic;
-- 32 bits signals
signal PC_in: std_logic_vector(31 downto 0);
signal PC_out: std_logic_vector(31 downto 0);
signal four: std_logic_vector(31 downto 0);
signal PC4: std_logic_vector(31 downto 0);
signal DirSalto: std_logic_vector(31 downto 0);
signal IR_in: std_logic_vector(31 downto 0);
signal IR_ID: std_logic_vector(31 downto 0);
signal PC4_ID: std_logic_vector(31 downto 0);
signal inm_ext_EX: std_logic_vector(31 downto 0);
signal Mux_out: std_logic_vector(31 downto 0);
signal inm_ext: std_logic_vector(31 downto 0);
signal inm_ext_x4: std_logic_vector(31 downto 0);
signal BusW: std_logic_vector(31 downto 0);
signal BusA: std_logic_vector(31 downto 0);
signal BusB: std_logic_vector(31 downto 0);
signal BusA_EX: std_logic_vector(31 downto 0);
signal BusB_EX: std_logic_vector(31 downto 0);
signal BusB_MEM: std_logic_vector(31 downto 0);
signal ALU_out_EX: std_logic_vector(31 downto 0);
signal ALU_out_MEM: std_logic_vector(31 downto 0);
signal ALU_out_WB: std_logic_vector(31 downto 0);
signal Mem_out: std_logic_vector(31 downto 0);
signal MDR: std_logic_vector(31 downto 0);
signal Mux_ant_A_out: std_logic_vector(31 downto 0);
signal Mux_ant_B_out: std_logic_vector(31 downto 0);
signal Mux_ant_C_out: std_logic_vector(31 downto 0);
-- 5 bits signals
signal RW_EX: std_logic_vector(4 downto 0);
signal RW_MEM: std_logic_vector(4 downto 0);
signal RW_WB: std_logic_vector(4 downto 0);
signal Reg_Rd_EX: std_logic_vector(4 downto 0);
signal Reg_Rt_EX: std_logic_vector(4 downto 0);
signal Reg_Rs_EX: std_logic_vector(4 downto 0);
-- 3 bits signals
signal ALUctrl_ID: std_logic_vector(2 downto 0);
signal ALUctrl_EX: std_logic_vector(2 downto 0);
-- 2 bits signals
signal Mux_ant_A: std_logic_vector(1 downto 0);
signal Mux_ant_B: std_logic_vector(1 downto 0);
signal Mux_ant_C: std_logic_vector(1 downto 0);

begin

----------------------------- Fetch -------------------------------

pc: reg32 port map(
    Din => PC_in,
    clk => clk,
    reset => reset,
    load => load_PC,
    Dout => PC_out
);

four <= "00000000000000000000000000000100";

adder_4: adder32 port map (
    Din0 => PC_out,
    Din1 => four,
    Dout => PC4
);

muxPC: mux2_1 port map(
    Din0 => PC4,
    DIn1 => DirSalto,
    ctrl => PCSrc,
    Dout => PC_in
);

Mem_I: memoriaRAM_I PORT MAP(
    CLK => CLK,
    ADDR => PC_out,
    Din => "00000000000000000000000000000000",
    WE => '0',
    RE => '1',
    Dout => IR_in
);

Banco_IF_ID: Banco_ID port map(
    IR_in => IR_in,
    PC4_in => PC4,
    clk => clk,
    reset => reset,
    load => ID_Write,
    IR_ID => IR_ID,
    PC4_ID => PC4_ID);

----------------------------- Decode -------------------------------

UD_seg: UD PORT MAP(
	Codigo_OP => IR_ID(31 downto 26),
    	ReadMem_EX => MemRead_EX,
    	Rs_ID => IR_ID(25 downto 21),
    	Rt_ID => IR_ID(20 downto 16),
    	Rt_EX => Reg_Rt_EX,
    	Sout => switch_ctrl,
    	PC_Write => load_PC,
    	ID_Write => ID_Write
);
							
Switch_det: Switch_UD PORT MAP(
   	Reg_Dst => RegDst_ID, 
    	Reg_Write => RegWrite_ID,
    	Mem_Read => MemRead_ID
    	Mem_Write => MemWrite_ID,
    	MemtoReg => MemtoReg_ID,
    	ALU_Src_A => ALU_Src_A_ID,
	ALU_Src_B => ALU_Src_B_ID,
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
    	RA => IR_ID(25 downto 21),
    	RB => IR_ID(20 downto 16),
    	RW => RW_WB,
    	BusW => BusW, 
	RegWrite => RegWrite_WB,
    	BusA => BusA,
    	BusB => BusB
);

sign_ext: Ext_signo port map(
    	inm => IR_ID(15 downto 0),
    	inm_ext => inm_ext
);

two_bits_shift: two_bits_shifter port map(
    	Din => inm_ext,
    	Dout => inm_ext_x4
);

adder_dir: adder32 port map(
    	Din0 => inm_ext_x4,
    	Din1 => PC4_ID,
    	Dout => DirSalto
);

Z <= '1' when (busA=busB) else '0';

UC_seg: UC port map(
    	IR_op_code => IR_ID(31 downto 26),
    	Branch => Branch,
    	RegDst => RegDst_ID, 
    	ALU_Src_A => ALU_Src_A_ID,
    	ALU_Src_B => ALU_Src_B_ID,
    	MemWrite => MemWrite_ID,
	MemRead => MemRead_ID,
    	MemtoReg => MemtoReg_ID,
    	RegWrite => RegWrite_ID
);
							
-- si la operacion es aritmetica (es decir: IR_ID(31 downto 26)= "000001") se mira el campo funct
-- como solo hay 4 operaciones en la alu, basta con los bits menos significativos del campo func 
-- de la instruccion
-- si no es aritmetica le damos el valor de la suma (000)
ALUctrl_ID <= IR_ID(2 downto 0) when IR_ID(31 downto 26)= "000001" else "000"; 

Banco_ID_EX: Banco_EX PORT MAP(
	clk => clk,
	reset => reset,
	load => '1',
	busA => busA,
	busB => busB,
	busA_EX => busA_EX,
	busB_EX => busB_EX,
	RegDst_ID => Reg_Dst_UD,
	ALU_Src_A_ID => ALU_Src_A_UD,
	ALU_Src_B_ID => ALU_Src_B_UD,
	MemWrite_ID => Mem_Write_UD,
	MemRead_ID => Mem_Read_UD,
	MemtoReg_ID => MemtoReg_UD,
	RegWrite_ID => Reg_Write_UD,
	RegDst_EX => RegDst_EX,
	ALU_Src_A_EX => ALU_Src_A_EX,
	ALU_Src_B_EX => ALU_Src_B_EX,
	MemWrite_EX => MemWrite_EX,
	MemRead_EX => MemRead_EX,
	MemtoReg_EX => MemtoReg_EX,
	RegWrite_EX => RegWrite_EX,
	ALUctrl_ID => ALUctrl_ID,
	ALUctrl_EX => ALUctrl_EX,
	inm_ext => inm_ext,
	inm_ext_EX=> inm_ext_EX, 
	Reg_Rt_ID => IR_ID(20 downto 16),
	Reg_Rd_ID => IR_ID(15 downto 11),
	Reg_Rs_ID => IR_ID(25 downto 21),
	Reg_Rt_EX => Reg_Rt_EX, 
	Reg_Rd_EX => Reg_Rd_EX, 
	Reg_Rs_EX => Reg_Rs_EX
);

PCSrc <= Branch AND Z; -- Ahora mismo solo esta implementada la instruccion de salto BEQ.
 											
--------------------------------- Execution ------------------------------------------

UA_seg: UA port map(
	Rt => Reg_Rt_EX,
	ExMem_Rd => RW_MEM,
	MemWB_Rd => RW_WB,
	Rs => Reg_Rs_EX,
	ALU_Src_A => ALU_Src_A_EX,
	ALU_Src_B => ALU_Src_B_EX,
	MemWrite_EX => MemWrite_EX,
	RegWrite_Mem => RegWrite_MEM,
	RegWrite_WB => RegWrite_WB,
	Mux_ant_A => Mux_ant_A,
	Mux_ant_B => Mux_ant_B,
	Mux_ant_C => Mux_ant_C
);

mux_a: mux4_32bits port map(
	Din0 => busA_EX,
	Din1 => busW,
	Din2 => ALU_out_MEM,
	DIn3 => "00000000000000000000000000000000",
	ctrl => Mux_ant_A,
	Dout => Mux_ant_A_out
);

mux_b: mux4_32bits port map(
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

mux_c : mux4_32bits port map(
	Din0 => busB_EX, 
	Din1 => busW, 
	Din2 => ALU_out_MEM, 
	DIn3 => "00000000000000000000000000000000", 
	ctrl => Mux_ant_C, 
	Dout => Mux_ant_C_out
);

mux_dst: mux2_5bits port map(
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
											
mux_busW: mux2_1 port map(
	Din0 => ALU_out_WB, 
	DIn1 => MDR, 
	ctrl => MemtoReg_WB, 
	Dout => busW
);

output <= IR_ID;

end Behavioral;

