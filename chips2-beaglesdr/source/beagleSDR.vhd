--------------------------------------------------------------------------------
---
---  CHIPS - 2.0 Simple Demo
---
---  :Author: Jonathan P Dawson
---  :Date: 17/10/2013
---  :email: chips@jondawson.org.uk
---  :license: MIT
---  :Copyright: Copyright (C) Jonathan P Dawson 2013
---
--------------------------------------------------------------------------------
---
---
---                                  +--------------+               
---                                  | USER DESIGN  |
---              +-------------+     +--------------+
---              |    ADC      |     |              |
---              |             >----->     CPU      |
---              |-------------|     |   CONTROL    |
---              |             <-----<              >-------> LED(0)
---              |    DAC      |     |              >-------> LED(1)               
---              +-------------+     |              |
---                                  |              |
---                                  +----^----v----+
---                                       |    |
---                                  +----^----v----+
---                                  | UART         |
---                                  +--------------+
---       BEAGLEBOARD-X15 RS232-TX ->|              |
---                                  |              |
---       BEAGLEBOARD-X15 RS232-RX -<|              |                               <
---                                  +--------------+
---
---

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity beagleSDR is
	port(
		CLK_IN    : in  std_logic; -- 125 Mhz
		CLKIN_50M : in  std_logic; -- 50 Mhz
		--LEDS
		GPIO_LEDS : out   std_logic_vector(1 downto 0);

		--RS232 INTERFACE
		RS232_RX  : in    std_logic;
		RS232_TX  : out   std_logic;

		--ADC
		ADC_RX : in   std_logic_vector(11 downto 0);

		--DAC
		DAC_TX : out   std_logic_vector(13 downto 0)

	);
end entity beagleSDR;

architecture RTL of beagleSDR is

	component user_design is
		port(
			CLK                 : in  std_logic;

			RST                 : in  std_logic;
			
			OUTPUT_LEDS         : out std_logic_vector(15 downto 0);
			OUTPUT_LEDS_STB     : out std_logic;
			OUTPUT_LEDS_ACK     : in  std_logic;

			--RS232 RX STREAM
			INPUT_RS232_RX      : in  std_logic_vector(15 downto 0);
			INPUT_RS232_RX_STB  : in  std_logic;
			INPUT_RS232_RX_ACK  : out std_logic;

			--RS232 TX STREAM
			OUTPUT_RS232_TX     : out std_logic_vector(15 downto 0);
			OUTPUT_RS232_TX_STB : out std_logic;
			OUTPUT_RS232_TX_ACK : in  std_logic
			
			--ADC RX STREAM
--			INPUT_ADC_RX      : in  std_logic_vector(11 downto 0);
--			INPUT_ADC_RX_STB  : in  std_logic;
--			INPUT_ADC_RX_ACK  : out std_logic;
--
--			--DAC TX STREAM
--			OUTPUT_DAC_TX     : out std_logic_vector(13 downto 0);
--			OUTPUT_DAC_TX_STB : out std_logic;
--			OUTPUT_DAC_TX_ACK : in  std_logic			
		);
	end component;

	--clock tree signals
	signal clkin1       : std_logic;
	-- Output clock buffering
	signal clkfb        : std_logic;
	signal clk0         : std_logic;
	signal clkfx        : std_logic;
	signal RST       : std_logic;
	signal CLK_50       : std_logic; --125/5*2
	signal CLK_80       : std_logic; --125/25*16
	signal CLK_125      : std_logic;
	signal INTERNAL_RST : std_logic;
	signal LOCKED       : std_logic;

	signal OUTPUT_LEDS     : std_logic_vector(15 downto 0);
	signal OUTPUT_LEDS_STB : std_logic;
	signal OUTPUT_LEDS_ACK : std_logic;

	--RS232 RX STREAM
	signal INPUT_RS232_RX     : std_logic_vector(15 downto 0);
	signal INPUT_RS232_RX_STB : std_logic;
	signal INPUT_RS232_RX_ACK : std_logic;

	--RS232 TX STREAM
	signal OUTPUT_RS232_TX     : std_logic_vector(15 downto 0);
	signal OUTPUT_RS232_TX_STB : std_logic;
	signal OUTPUT_RS232_TX_ACK : std_logic;

--	--ADC RX STREAM	
--	signal ADC_DATA      : std_logic_vector(11 downto 0);
--	signal ADC_DATA_STB  : std_logic;
--	signal ADC_DATA_ACK  : std_logic;
--
--	--DAC TX STREAM
--	signal DAC_DATA     : std_logic_vector(13 downto 0);
--	signal DAC_DATA_STB : std_logic;
--	signal DAC_DATA_ACK : std_logic;

begin

	USER_DESIGN_INST_1 : USER_DESIGN port map(
			CLK                 => CLK_50,
			RST					  => RST,
			OUTPUT_LEDS         => OUTPUT_LEDS,
			OUTPUT_LEDS_STB     => OUTPUT_LEDS_STB,
			OUTPUT_LEDS_ACK     => OUTPUT_LEDS_ACK,

			--RS232 RX STREAM
			INPUT_RS232_RX      => INPUT_RS232_RX,
			INPUT_RS232_RX_STB  => INPUT_RS232_RX_STB,
			INPUT_RS232_RX_ACK  => INPUT_RS232_RX_ACK,

			--RS232 TX STREAM
			OUTPUT_RS232_TX     => OUTPUT_RS232_TX,
			OUTPUT_RS232_TX_STB => OUTPUT_RS232_TX_STB,
			OUTPUT_RS232_TX_ACK => OUTPUT_RS232_TX_ACK

--			--ADC RX STREAM
--			INPUT_ADC_RX => ADC_DATA,
--			INPUT_ADC_RX_STB  => ADC_DATA_STB,
--			INPUT_ADC_RX_ACK  => ADC_DATA_ACK,
--
--			--DAC TX STREAM
--			OUTPUT_DAC_TX   => DAC_DATA,
--			OUTPUT_DAC_TX_STB => DAC_DATA_STB,
--			OUTPUT_DAC_TX_ACK => DAC_DATA_ACK
		);


	SERIAL_OUTPUT_INST_1 : entity work.serial_output generic map(
			CLOCK_FREQUENCY => 50000000,
			BAUD_RATE       => 115200
		) port map(
			CLK => CLK_50,
			RST => INTERNAL_RST,
			TX => RS232_TX,
			IN1 => OUTPUT_RS232_TX(7 downto 0),
			IN1_STB => OUTPUT_RS232_TX_STB,
			IN1_ACK => OUTPUT_RS232_TX_ACK
		);

	SERIAL_INPUT_INST_1 : entity work.SERIAL_INPUT generic map(
			CLOCK_FREQUENCY => 50000000,
			BAUD_RATE       => 115200
		) port map(
			CLK => CLK_50,
			RST => INTERNAL_RST,
			RX => RS232_RX,
			OUT1 => INPUT_RS232_RX(7 downto 0),
			OUT1_STB => INPUT_RS232_RX_STB,
			OUT1_ACK => INPUT_RS232_RX_ACK
		);

	INPUT_RS232_RX(15 downto 8) <= (others => '0');

	-- need to instantiate ADC/DAC components


	-- ADC/DAC components


	process
	begin
		wait until rising_edge(CLK_50);

		if OUTPUT_LEDS_STB = '1' then
			GPIO_LEDS <= OUTPUT_LEDS(1 downto 0);
		end if;
		OUTPUT_LEDS_ACK <= '1';

	end process;
	--GPIO_LEDS <= (not link_up) & (not std_logic_vector(speed)) & (not RX_RESET);

	reset_generator_inst : entity work.reset_generator
		-- pragma translate_off
		generic map(
			RESET_DELAY => 10
		)
		-- pragma translate_on
		port map(
			clock_i  => CLK_125,
			locked_i => LOCKED,
			reset_o  => INTERNAL_RST
		);

	----------------------------------
	-- Input Clock   Input Freq (MHz) 
	----------------------------------
	-- primary         125.000        
	-------------------------
	-- Output     Output     
	-- Clock     Freq (MHz)  
	-------------------------
	-- BUFG_INST3    50.000      
	-- BUFG_INST2   125.000    

	-- Input buffering
	--------------------------------------
	clkin1_buf : IBUFG
		port map(O => clkin1,
			     I => CLK_IN);

	-- Clocking primitive
	--------------------------------------
	-- Instantiation of the DCM primitive
	--    * Unused inputs are tied off
	--    * Unused outputs are labeled unused
	dcm_sp_inst : DCM_SP
		generic map(CLKDV_DIVIDE       => 2.000,
			        CLKFX_DIVIDE       => 5,
			        CLKFX_MULTIPLY     => 2,
			        CLKIN_DIVIDE_BY_2  => FALSE,
			        CLKIN_PERIOD       => 8.0,
			        CLKOUT_PHASE_SHIFT => "NONE",
			        CLK_FEEDBACK       => "1X",
			        DESKEW_ADJUST      => "SYSTEM_SYNCHRONOUS",
			        PHASE_SHIFT        => 0,
			        STARTUP_WAIT       => FALSE)
		port map(
			-- Input clock
			CLKIN    => clkin1,
			CLKFB    => clkfb,
			-- Output clocks
			CLK0     => clk0,
			CLK90    => open,
			CLK180   => open,
			CLK270   => open,
			CLK2X    => open,
			CLK2X180 => open,
			CLKFX    => clkfx,
			CLKFX180 => open,
			CLKDV    => open,
			-- Ports for dynamic phase shift
			PSCLK    => '0',
			PSEN     => '0',
			PSINCDEC => '0',
			PSDONE   => open,
			-- Other control and status signals
			LOCKED   => LOCKED,
			STATUS   => open,
			RST      => '0',
			-- Unused pin, tie low
			DSSEN    => '0');

	-- Output buffering
	-------------------------------------
	clkfb <= CLK_125;

	BUFG_INST2 : BUFG
		port map(O => CLK_125,
			     I => clk0);

--	BUFG_INST3 : BUFG
--		port map(O => CLK_50,
--			     I => clkfx);

	BUFG_INST4 : BUFG
		port map(O => CLK_50,
			     I => CLKIN_50M);
				  
end architecture RTL;
