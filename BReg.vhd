library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;
-- librería para usar la función conv_integer
use IEEE.std_logic_unsigned.all;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BReg is
    port(
        clk : in std_logic;
        reset : in std_logic;
        RA : in std_logic_vector (4 downto 0); --Dir para el puerto de lectura A
        RB : in std_logic_vector (4 downto 0); --Dir para el puerto de lectura B
        RW : in std_logic_vector (4 downto 0); --Dir para el puerto de escritura
        BusW : in std_logic_vector (31 downto 0);--entrada de datos para el puerto de escritura
        RegWrite : in std_logic;						
        BusA : out std_logic_vector (31 downto 0);
        BusB : out std_logic_vector (31 downto 0)
    );
end BReg;

architecture Behavioral of BReg is
-- el banco de registros es un array de 32 registros de 32 bits
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal reg_file : reg_array;
    
    begin 
	process(clk)
        begin 
		-- se escribe en flanco de bajada. clk'event vale uno cuando hay un flanco.
		-- Si ha habido un flaco y el resultado es que clk vale cero era un flanco de bajada
		if (clk'event and clk='0') then 
		--if RegWrite is 1, write BusW data in register RW
            		if reset='1' then 	
				for i in 0 to 31 loop
					reg_file(i) <= "00000000000000000000000000000000";
				end loop;
			else
				if RegWrite = '1' then
					reg_file(conv_integer(RW)) <= BusW; --forma super compacta de vhdl para hacer el decodificador y la escritura en el banco de registros
				end if;
			end if;
		end if;
    end process;
    
    --get data stored at register RA
    BusA <= reg_file(conv_integer(RA)); -- esto es una forma muy rápida de hacer un Mux en vhdl
    --get data stored at register RA
    BusB <= reg_file(conv_integer(RB));
    
end Behavioral;