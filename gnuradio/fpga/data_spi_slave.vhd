library ieee;
use ieee.std_logic_1164.all;

entity data_spi_slave is
	port (
		clk, simo, cs: in std_logic;
		somi, rd_req, wr_req: out std_logic;
		tx_full, rx_empty: in std_logic;
		txdata: out std_logic_vector(13 downto 0);
		rxdata: in  std_logic_vector(11 downto 0)
	);
end data_spi_slave;

architecture structural of data_spi_slave is
	signal write_to_fifo, read_from_fifo: std_logic;
	signal dataout_data: std_logic_vector(11 downto 0);

	component shiftreg14
		PORT (
			clock		: IN STD_LOGIC ;
			shiftin		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (13 DOWNTO 0)
		);
	end component;
	
	component shiftreg12
		PORT (
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			load		: IN STD_LOGIC ;
			shiftout	: OUT STD_LOGIC 
		);
	end component;

	component data_slave_fsm
		port (
			clock, async_reset: in std_logic;
			write_to_fifo, read_from_fifo: out std_logic
		);
	end component;
begin

	fsm: data_slave_fsm port map (
		clock => clk,
		async_reset => cs,
		write_to_fifo => write_to_fifo,
		read_from_fifo => read_from_fifo
	);
	
	dataout: shiftreg12 port map (
		clock => not clk,
		data => dataout_data,
		load => read_from_fifo,
		shiftout => somi
	);
	
	datain: shiftreg14 port map (
		clock => clk,
		shiftin => simo,
		q => txdata
	);
	
	wr_req <= write_to_fifo and not tx_full;
	rd_req <= read_from_fifo and not rx_empty;
	dataout_data <= rxdata when rx_empty = '0'
	           else (others => '0');
	
end structural;