library ieee;
use ieee.std_logic_1164.all;

entity control_spi_slave is
	port (
		clk, simo, cs: in std_logic;
		somi, wren: out std_logic;
		address: out std_logic_vector(5 downto 0);
		rd_data: in  std_logic_vector(7 downto 0);
		wr_data: out std_logic_vector(7 downto 0)
	);
end control_spi_slave;

architecture structural of control_spi_slave is
	signal dataout_load, address_mux: std_logic;
	signal datain_q: std_logic_vector(13 downto 0);
	
	component shiftreg14
		PORT (
			clock		: IN STD_LOGIC ;
			shiftin		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (13 DOWNTO 0)
		);
	end component;
	
	component shiftreg8
		PORT (
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			load		: IN STD_LOGIC ;
			shiftout	: OUT STD_LOGIC 
		);
	end component;
	
	component control_slave_fsm
		port (
			clock, simo, async_reset: in std_logic;
			dataout_load, ram_wren, read_not_write: out std_logic
		);
	end component;
begin

	fsm: control_slave_fsm port map (
		clock => clk,
		simo => simo,
		async_reset => cs,
		dataout_load => dataout_load,
		ram_wren => wren,
		read_not_write => address_mux
	);
	
	dataout: shiftreg8 port map (
		clock => not clk,
		load => dataout_load,
		data => rd_data,
		shiftout => somi
	);
	
	datain: shiftreg14 port map (
		clock => clk,
		shiftin => simo,
		q => datain_q
	);
	
	address <= datain_q(13 downto 8) when address_mux = '0' else
	           datain_q(5 downto 0);
	wr_data <= datain_q(7 downto 0);
	
end structural;