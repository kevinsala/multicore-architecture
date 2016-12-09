LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

ENTITY ALU_MUL IS
	PORT(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		load : IN STD_LOGIC;
		DA : IN  STD_LOGIC_VECTOR (31 downto 0); --entrada 1
		DB : IN  STD_LOGIC_VECTOR (31 downto 0); --entrada 2
		--Counter : OUT STD_LOGIC_VECTOR(2 downto 0); --contador de los ciclos restantes para la multiplicacion
		Mul_ready : OUT STD_LOGIC;
		Dout : OUT  STD_LOGIC_VECTOR (31 downto 0)
	); 
END ALU_MUL;

ARCHITECTURE Behavioral OF ALU_MUL IS

SIGNAL Contador: STD_LOGIC_VECTOR(2 downto 0);

BEGIN

	SYNC_PROC: PROCESS (clk, load)
	BEGIN
		if (load'event and load = '1') then
			Contador <= "100";
		elsif (load'event and load = '0') then
			Mul_ready <= '0';
		end if;

		if (clk'event and clk = '1') then
			if (reset = '1') then
				Mul_ready <= '0';
				Dout <= "00000000000000000000000000000000";
				Contador <= "000";
			else
				if (Contador /= "001") then
					if (load = '1') then
						Contador <= Contador-'1';
						Mul_ready <= '0';
						Dout <= "00000000000000000000000000000000";
					end if;
				else
					if (load = '1') then
						Mul_ready <= '1';
						Dout <= DA(15 downto 0) * DB(15 downto 0);
					end if;
				end if;
			end if;
		end if;
	END PROCESS;

	--Counter <= Contador;

END Behavioral;