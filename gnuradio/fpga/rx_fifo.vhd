LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY rx_fifo IS
	Generic (
		constant DATA_WIDTH  : positive := 12;
		constant FIFO_DEPTH	: positive := 256
	);
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
END rx_fifo;


architecture Behavioral of rx_fifo is
 
	type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
	signal Memory : FIFO_Memory;
	
	signal Head : natural range 0 to FIFO_DEPTH - 1 := 0;
	signal Tail : natural range 0 to FIFO_DEPTH - 1 := 0;
	
	signal Looped : boolean := false;

begin
RD_Proc: process(rdclk)
begin
				if (rdreq = '1') and rising_edge(rdclk) then
						-- Update data output
						q <= Memory(Tail);
						
						-- Update Tail pointer as needed
						if (Tail = FIFO_DEPTH - 1) then
							Tail <= 0;
						else
							Tail <= Tail + 1;
						end if;
						
						if (Head = Tail) then
							rdempty <= '1';
						else
							rdempty <= '0';
						end if;
				end if;
end process;

WR_Proc: process(wrclk)
begin			
				if (wrreq = '1') and rising_edge(wrclk) then
					if (Head /= Tail) then
						-- Write Data to Memory
						Memory(Head) <= data;
						
						-- Increment Head pointer as needed
						if (Head = FIFO_DEPTH - 1) then
							Head <= 0;
						else
							Head <= Head + 1;
						end if;
						wrfull <= '0';
					else
						wrfull <= '1';
					end if;
				end if;
				
end process;
		
end Behavioral;

