--------------------------------------------------------------------------------
---
---  ADC INPUT
---
---  ADC Input Component
---
--------------------------------------------------------------------------------
---
---ADC Input
---============
---
---Read a stream of data from a ADC 552x
---
---Outputs
-----------
---
--- + ADC_DATA : ADC data stream
---
---Generics
-----------
---
--- + clock frequency

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADC_INPUT is

  generic(
    CLOCK_FREQUENCY : integer;
  );
  port(
    CLK      : in std_logic;
    RST      : in std_logic;
    RX       : in std_logic_vector(11 downto 0);
   
    ADC_DATA     : out std_logic_vector(11 downto 0);
    ADC_DATA_STB : out std_logic;
    ADC_DATA_ACK : in  std_logic
  );

end entity ADC_INPUT;

architecture RTL of ADC_INPUT is

  type ADC_IN_STATE_TYPE is (RESET, RUN);
  signal STATE           : ADC_IN_STATE_TYPE;

begin

  process
  begin
    wait until rising_edge(CLK);

--- needs implementation of circular or FIFO buffer
    
    ADC_DATA_STB <= '1';
    ADC_DATA <= RX; -- data from ADC to FPGA

    if RST = '1' then
      STATE <= RESET;
      ADC_DATA_STB <= '0';
    end if; 
  end process;
end architecture RTL;
