LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


PACKAGE utils IS
	FUNCTION to_std_logic(value : BOOLEAN) RETURN std_logic;
END utils;

PACKAGE BODY utils IS
	FUNCTION to_std_logic(value : BOOLEAN) RETURN std_logic IS
	BEGIN
		IF value THEN
			RETURN('1');
		ELSE
			RETURN('0');
		END IF;
	END FUNCTION to_std_logic;
END utils;
