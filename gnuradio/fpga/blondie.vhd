--
-- These are FPGA VHDL files previously based on H. Villeneuve and Ph. Balister design of FPGA software radio logic using GNU Radio software. 
-- Ported to BeagleSDR board by Mich. HE - Jun. 2018
--
-- First attempt and steps in making of gnuradio plugin for BeagleSDR / Beagleboard-x15 project
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library unisim;
use unisim.vcomponents.all;

entity blondie is
	port (
		-- CLOCK AND RESET PINS
		clockIn: in std_logic; --P80 = 50 Mhz
		osc125_clk: in std_logic; --P184 = 125 Mhz
		
		-- BEAGLEBOARD X15 EXPANSION HEADER P17
		pinMcSPI4_CS0	: in  std_logic;	-- McSPI4_CS0	            -- BeagleX15 P17 pin6
		pinMcSPI3_CS0  : in  std_logic;	-- McSPI3_CS0					-- BeagleX15 P17 pin8
		pinMcSPI3_CLK  : in  std_logic;	-- McSPI3_CLK					-- BeagleX15 P17 pin4
		pinMcSPI4_CLK  : in  std_logic;					-- McSPI4_CLK	-- BeagleX15 P17 pin37
		pinMcSPI3_SIMO	: in  std_logic;	-- McSPI3_SIMO					-- BeagleX15 P17 pin7
		pinMcSPI4_SIMO : in  std_logic;					-- McSPI4_SIMO	-- BeagleX15 P17 pin38
		pinMcSPI4_SOMI	: out std_logic;					-- McSPI4_SOMI	-- BeagleX15 P17 pin35
		pinMcSPI3_SOMI	: out std_logic;	            -- McSPI3_SOMI	-- BeagleX15 P17 pin36
				
		
		-- PARALLEL DATA TO/FROM ADC/DAC
		tx_a: out std_logic_vector(13 downto 0); -- 14 bits DAC AD9764
		rx_a_a: in std_logic_vector(11 downto 0); -- 12 bits ADC ADS5522
			
		-- DAUGHTERBOARD I/O CONNECTIONS
		rs232_rxd_1: in std_logic;     -- UART RX FPGA pin 100
		rs232_txd_1: out std_logic;    -- UART TX FPGA pin 99
		
		-- DEBUG BLINKENLIGHTS
		led : out std_logic_vector(1 downto 0);
		
		resetSwitch : in std_logic;	 -- FPGA pin 42

		-- DAC / ADC control signals
		DAC_CLK : out std_logic; 
		DAC_SLEEP : out std_logic;
		ADC_SEN : out std_logic;
		ADC_CLKP : out std_logic;
		ADC_RESET : out std_logic;
		ADC_SDATA : out std_logic;
		ADC_SCLK : out std_logic
	);
end blondie;

architecture structural of blondie is
	subtype rxword is std_logic_vector (11 downto 0);
	subtype txword is std_logic_vector (13 downto 0);
	signal reset: std_logic;
	signal rst : std_logic_vector (3 downto 0); -- init. ADC
	signal clk: std_logic;	
	signal adc_clkout: std_logic; --adc at 80 Mhz max * set to 50 Mhz here
	signal dac_clkout: std_logic; --dac at 125 Mhz max * set to 125 Mhz here	
	signal mcspi3_clk, mcspi3_simo, mcspi3_somi, mcspi3_cs0, mcspi3_cs1: std_logic;
	signal mcspi4_clk, mcspi4_simo, mcspi4_somi, mcspi4_cs0: std_logic;
	signal ctrl_somi: std_logic;
	
	signal regfile_wren: std_logic;
	signal regfile_addr: std_logic_vector(5 downto 0);
	signal regfile_rd_data: std_logic_vector(7 downto 0);
	signal regfile_wr_data: std_logic_vector(7 downto 0);
	
	-- zz prefix indicates control signals to/from register file
	signal zz_interpolation_rate: std_logic_vector(15 downto 0);
	signal zz_decimation_rate: std_logic_vector(15 downto 0);
	signal zz_dac_underflow: std_logic;
	signal zz_adc_overflow: std_logic;

	signal spislave_txdata: txword;
	signal spislave_rxdata: rxword;
	
	signal tx_fifo_wr_req, tx_fifo_wr_full, tx_fifo_rd_empty: std_logic;
	signal rx_fifo_rd_req, rx_fifo_rd_empty, rx_fifo_wr_full: std_logic;

	signal interp_input_request: std_logic;
	signal interp_input: txword;
	signal interp_output_request: std_logic;
	
	signal decim_output_request: std_logic;
	signal decim_output: rxword;
	signal decim_input_request: std_logic;
	
	signal sync_rx_from_adc: rxword;
	signal adc_fifo_rd_empty: std_logic;
	
	signal sync_tx_to_dac: txword;
	signal dac_fifo_wr_full: std_logic;
	
	component control_spi_slave
		port (
			clk, simo, cs: in std_logic;
			somi, wren: out std_logic;
			address: out std_logic_vector(5 downto 0);
			rd_data: in  std_logic_vector(7 downto 0);
			wr_data: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component register_file
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
	end component;
	
	component data_spi_slave
		port (
			clk, simo, cs: in std_logic;
			somi, rd_req, wr_req: out std_logic;
			tx_full, rx_empty: in std_logic;
			txdata: out txword;
			rxdata: in  rxword
		);
	end component;
		
	component interp
		port (
			clk: in std_logic;
			input: in txword;
			output: out txword;
			input_request: out std_logic;
			input_enable: in std_logic;
			rate: in std_logic_vector(15 downto 0);
			output_request: out std_logic;
			output_enable: in std_logic
		);
	end component;
	
	component decim
		port (
			clk: in std_logic;
			input: in rxword;
			output: out rxword;
			output_request: out std_logic;
			output_enable: in std_logic;
			rate: in std_logic_vector(15 downto 0);
			input_request: out std_logic;
			input_enable: in std_logic
		);
	end component;
	
	component tx_fifo
		PORT (
			data		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	end component;
	
	component rx_fifo
		PORT (
			data		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	end component;
	
	component dac_fifo
		PORT (
			data		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
			wrempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	end component;
	
	component adc_fifo
		PORT (
			data		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			rdfull		: OUT STD_LOGIC 
		);
	end component;
	
	
	---- ADC 552x
	component adcapi is
	port (
		reset	: in	std_logic;
		clk		: in	std_logic;
		sclk	: out	std_logic;
		sen		: out	std_logic;
		sdata	: out	std_logic
	);
   end component;
	----
	
begin
	reset <= not resetSwitch;
	clk <= clockIn; -- FIXME add a PLL here to boost clock rate for filters

	mcspi3_clk <= pinMcSPI3_CLK; 
	mcspi3_simo <= pinMcSPI3_SIMO	;
	pinMcSPI3_SOMI	 <= mcspi3_somi;
	mcspi3_cs0 <= pinMcSPI3_CS0;
	
	mcspi4_clk <= pinMcSPI4_CLK;
	mcspi4_simo <= pinMcSPI4_SIMO;
	pinMcSPI4_SOMI	 <= mcspi4_somi;
	mcspi4_cs0 <= pinMcSPI4_CS0	;

	-- Debug outputs maybe for chipscope
	rs232_txd_1 <= rs232_rxd_1;

-- CONTROL PATH
	
	control_spi_slave_0: control_spi_slave port map (
		clk => mcspi3_clk,
		simo => mcspi3_simo,
		somi => ctrl_somi,
		cs => mcspi3_cs1,
		wren => regfile_wren,
		address => regfile_addr,
		rd_data => regfile_rd_data,
		wr_data => regfile_wr_data
	);
	
	register_file_0: register_file port map (
		master_clk => clk,
		spi_clk => mcspi3_clk,
		wren => regfile_wren,
		address => regfile_addr,
		rd_data => regfile_rd_data,
		wr_data => regfile_wr_data,
		interpolation_rate => zz_interpolation_rate,
		decimation_rate => zz_decimation_rate,
		dac_underflow => zz_dac_underflow,
		adc_overflow => zz_adc_overflow,
		rx_overflow => rx_fifo_wr_full,
		tx_underflow => tx_fifo_rd_empty,
		leds => led
	);

	data_spi_slave_0: data_spi_slave port map (
		clk => mcspi4_clk,
		simo => mcspi4_simo,
		somi => mcspi4_somi,
		cs => mcspi4_cs0,
		wr_req => tx_fifo_wr_req,
		rd_req => rx_fifo_rd_req,
		txdata => spislave_txdata,
		rxdata => spislave_rxdata,
		tx_full => tx_fifo_wr_full,
		rx_empty => rx_fifo_rd_empty
	);
	
-- TRANSMIT PATH
	
	tx_fifo_0: tx_fifo port map (
		wrclk => mcspi4_clk,
		wrreq => tx_fifo_wr_req,
		data => spislave_txdata,
		wrfull => tx_fifo_wr_full,
		rdclk => clk,
		rdreq => interp_input_request,
		q => interp_input,
		rdempty => tx_fifo_rd_empty
	);

	interp_0: interp port map (
		clk => clk,
		input => interp_input,
		input_request => interp_input_request,
		input_enable => not tx_fifo_rd_empty,
		rate => zz_interpolation_rate,
		output => sync_tx_to_dac,
		output_request => interp_output_request,
		output_enable => not dac_fifo_wr_full
	);

	dac_fifo_0: dac_fifo port map (
		wrclk => clk,
		wrreq => interp_output_request,
		data => sync_tx_to_dac,
		wrfull => dac_fifo_wr_full,
		rdclk => dac_clkout,
		rdreq => '1',
		q => tx_a,
		wrempty => zz_dac_underflow
	);
		
-- RECEIVE PATH

	adc_fifo_0: adc_fifo port map (
		rdclk => clk,
		rdreq => decim_input_request,
		q => sync_rx_from_adc,
		rdempty => adc_fifo_rd_empty,
		wrclk => adc_clkout,
		wrreq => '1',
		data => rx_a_a,
		rdfull => zz_adc_overflow
	);
	
	decim_0: decim port map (
		clk => clk,
		input => sync_rx_from_adc,
		input_request => decim_input_request,
		input_enable => not adc_fifo_rd_empty,
		output => decim_output,
		output_request => decim_output_request,
		output_enable => not rx_fifo_wr_full,
		rate => zz_decimation_rate
	);
	
	rx_fifo_0: rx_fifo port map (
		rdclk => mcspi4_clk,
		rdreq => rx_fifo_rd_req,
		q => spislave_rxdata,
		rdempty => rx_fifo_rd_empty,
		wrclk => clk,
		wrreq => decim_output_request,
		data => decim_output,
		wrfull => rx_fifo_wr_full
	);

------------------------------------------------------------------
-- This part is for data emission from FPGA to outside world / DAC
------------------------------------------------------------------
	dac_clkout <= osc125_clk ;		-- set to xxx Mhz direct osc input
	DAC_CLK <= dac_clkout ; -- this clock commands the DAC
	DAC_SLEEP <= '0';
	
----- DAC END

-------------------------------------------------------------------
-- This part is for data reception from outside world to FPGA / ADC
-------------------------------------------------------------------
	adc_clkout <= clockIn; -- set to xx Mhz DCM = clkin_90 / 5 * 8  -- need some delay for transition stabilization
	ADC_CLKP <= adc_clkout; -- this clock command ADC used to sample data
	
	adcapi_0: adcapi
	port map(
      reset => reset,
      clk => adc_clkout,
      sclk => ADC_SCLK,  -- gives output serial programming interface clock
      sen => ADC_SEN,
      sdata => ADC_SDATA  -- gives output serial programming interface data
	);	
	
	-- delayed / stretched Reset generator used to initialise the ADC ADS552x
	FCDE_latch0 : FDCE
	generic map(
	  INIT => '0'
	)
	port map(
	  Q=>rst(0),
	  C=>adc_clkout,
	  CE=>'1',
	  CLR=>'0',
	  D=>'1'
	 );
	 
	FCDE_latch1 : FDCE
	generic map(
	  INIT => '0'
	)
	port map(
	  Q=>rst(1),
	  C=>adc_clkout,
	  CE=>'1',
	  CLR=>'0',
	  D=>rst(0)
	 );

	FCDE_latch2 : FDCE
	generic map(
	  INIT => '0'
	)
	port map(
	  Q=>rst(2),
	  C=>adc_clkout,
	  CE=>'1',
	  CLR=>'0',
	  D=>rst(1)
	 );
	 
	FCDE_latch3 : FDCE
	generic map(
	  INIT => '1'
	)
	port map(
	  Q=>rst(3),
	  C=>adc_clkout,
	  CE=>'1',
	  CLR=>'0',
	  D=>not rst(2)
	 );
	 
-- reset only one time set to 1, used to reset the ADC ADS552x
	ADC_RESET <= rst(3);
		
----- ADC END	
end structural;