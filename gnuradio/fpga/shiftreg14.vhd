
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY shiftreg14 IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		shiftin		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (13 DOWNTO 0)
	);
END shiftreg14;

architecture archi of shiftreg14 is 
  signal tmp: std_logic_vector(13 downto 0); 
  begin 
    process (clock) 
      begin 
        if (clock'event and clock='1') then 
          tmp <= tmp(12 downto 0) & shiftin; 
        end if; 
    end process; 
    q <= tmp; 
end archi; 