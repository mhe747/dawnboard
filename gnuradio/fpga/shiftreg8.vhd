
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY shiftreg8 IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		load		: IN STD_LOGIC ;
		shiftout		: OUT STD_LOGIC 
	);
END shiftreg8;

architecture archi of shiftreg8 is 
  signal tmp: std_logic_vector(7 downto 0); 
  begin 
    process (clock) 
      begin 
        if (clock'event and clock='1') then 
          if (load='1') then 
            tmp <= data; 
          end if; 
        end if; 
    end process; 
    shiftout <= tmp(7); 
end archi; 