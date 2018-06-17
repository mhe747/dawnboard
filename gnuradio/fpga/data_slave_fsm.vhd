library ieee;
use ieee.std_logic_1164.all;

entity data_slave_fsm is
	port (
		clock, async_reset: in std_logic;
		write_to_fifo, read_from_fifo: out std_logic
	);
end data_slave_fsm;

architecture counter of data_slave_fsm is
	type state is (idle, start_reading, finish_writing);
	signal pr_state, nx_state: state;
	signal cycle: integer range 0 to 15;
begin
	process (clock, async_reset)
	begin
		if (async_reset = '1') then
			pr_state <= idle;
			cycle <= 0;
		elsif (rising_edge(clock)) then
			pr_state <= nx_state;
			cycle <= cycle + 1;
		end if;
	end process;
	
	nx_state <= start_reading  when pr_state = idle and cycle =  3
	       else finish_writing when pr_state = idle and cycle = 15
	       else idle;
	
	read_from_fifo <= '1' when pr_state = start_reading  else '0';
	write_to_fifo  <= '1' when pr_state = finish_writing else '0';
	
end counter;