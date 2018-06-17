library ieee;
use ieee.std_logic_1164.all;

entity control_slave_fsm is
	port (
		clock, simo, async_reset: in std_logic;
		dataout_load, ram_wren, read_not_write: out std_logic
	);
end control_slave_fsm;

architecture fsm of control_slave_fsm is
	type state is (get_rnw, get_data_to_write, write_data, get_addr_to_read, read_data, put_read_data);
	signal pr_state, nx_state: state;
	signal cycle: integer range 0 to 15;
begin
	process (clock, async_reset)
	begin
		if (async_reset = '1') then
			pr_state <= get_rnw;
			cycle <= 0;
		elsif (rising_edge(clock)) then
			pr_state <= nx_state;
			cycle <= cycle + 1;
		end if;
	end process;
	
	dataout_load <= '1'   when pr_state = read_data         else '0';
	ram_wren <= '1'       when pr_state = write_data        else '0';
	read_not_write <= '0' when pr_state = get_data_to_write 
	                        or pr_state = write_data        else '1';
	
	nx_state <= get_data_to_write when pr_state = get_rnw           and simo = '0'
	       else get_addr_to_read  when pr_state = get_rnw
	       else write_data        when pr_state = get_data_to_write and cycle = 15
	       else get_rnw           when pr_state = write_data
	       else get_data_to_write when pr_state = get_data_to_write
	       else read_data         when pr_state = get_addr_to_read  and cycle = 7
	       else get_addr_to_read  when pr_state = get_addr_to_read
	       else put_read_data     when pr_state = read_data
	       else get_rnw           when pr_state = put_read_data     and cycle = 15
	       else pr_state;
end fsm;