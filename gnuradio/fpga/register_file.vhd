library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	port (
		master_clk, spi_clk, wren: in std_logic;
		address: in  std_logic_vector(5 downto 0);
		rd_data: out std_logic_vector(7 downto 0);
		wr_data: in  std_logic_vector(7 downto 0);
		
		leds: out std_logic_vector(1 downto 0);
		interpolation_rate: out std_logic_vector(15 downto 0);
		decimation_rate: out std_logic_vector(15 downto 0);
		dac_underflow, adc_overflow, rx_overflow, tx_underflow: in std_logic
	);
end register_file;

architecture dataflow of register_file is
	type mem is array(0 to 7) of std_logic_vector(7 downto 0);
	signal wren_sync: std_logic_vector(1 downto 0);
	signal spi_clk_sync: std_logic_vector(2 downto 0);
	signal ram: mem;
begin
	rd_data <= ram(to_integer(unsigned(address(2 downto 0))));
	interpolation_rate <= ram(4) & ram(5);
	decimation_rate <= ram(6) & ram(7);
	
	--leds <= dac_underflow & tx_underflow & "0000" & rx_overflow & adc_overflow;
	leds <= rx_overflow & adc_overflow;
	
	process (master_clk)
	begin
		if (rising_edge(master_clk)) then
			wren_sync <= wren_sync(0) & wren;
			spi_clk_sync <= spi_clk_sync(1 downto 0) & spi_clk;
			if (wren_sync(1) = '1' and spi_clk_sync(2 downto 1) = "10") then
				ram(to_integer(unsigned(address(2 downto 0)))) <= wr_data;
			end if;
		end if;
	end process;

end dataflow;