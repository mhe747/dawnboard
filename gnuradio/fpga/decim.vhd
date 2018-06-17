library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decim is
	port (
		clk: in std_logic;
		input: in std_logic_vector(11 downto 0);
		output: out std_logic_vector(11 downto 0);
		output_request: out std_logic;
		output_enable: in std_logic;
		rate: in std_logic_vector(15 downto 0);
		input_request: out std_logic;
		input_enable: in std_logic
	);
end decim;

architecture fsm of decim is
	type state is (wait_input, get_input, wait_output, send_output);
	signal registered_input: std_logic_vector(11 downto 0);
	signal pr_state, nx_state: state;
	signal count: integer range 0 to 2**16-1;
	signal reached: std_logic;
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			pr_state <= nx_state;
			if (pr_state = get_input) then
				count <= count + 1;
				registered_input <= input;
			elsif (pr_state = send_output) then
				count <= 0;
			end if;
		end if;
	end process;
	
	output <= registered_input;
	input_request <= '1' when pr_state = get_input else '0';
	output_request <= '1' when pr_state = send_output else '0';
	reached <= '1' when count >= to_integer(unsigned(rate)) else '0';
	
	nx_state <= get_input   when pr_state = wait_input  and input_enable = '1'
	       else send_output when pr_state = get_input   and reached = '1' and output_enable = '1'
	       else wait_output when pr_state = get_input   and reached = '1'
	       else wait_input  when pr_state = get_input   and input_enable = '0'
	       else send_output when pr_state = wait_output and output_enable = '1'
	       else get_input   when pr_state = send_output and input_enable = '1'
	       else wait_input  when pr_state = send_output
	       else pr_state;
end fsm;