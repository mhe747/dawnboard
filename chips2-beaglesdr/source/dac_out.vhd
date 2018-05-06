--------------------------------------------------------------------------------
---
---  DAC OUTPUT
---
---  DAC OUTPUT Component
---
--------------------------------------------------------------------------------
---
---DAC OUTPUT
---============
---
---out a stream of data to a DAC 9764
---
---Outputs
-----------
---
--- + DAC_DATA : DAC data stream
---
---Generics
-----------
---
--- + clock frequency

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DAC_OUTPUT is

  generic(
    CLOCK_FREQUENCY : integer;
  );
  port(
    CLK      : in std_logic;
    RST      : in std_logic;
    TX       : out std_logic_vector(13 downto 0);
   
    DAC_DATA     : in std_logic_vector(13 downto 0);
    DAC_DATA_STB : in std_logic;
    DAC_DATA_ACK : out  std_logic
  );

end entity DAC_OUTPUT;

architecture RTL of DAC_OUTPUT is

  type DAC_IN_STATE_TYPE is (RESET, RUN);
  signal STATE           : DAC_IN_STATE_TYPE;

begin

  process
  begin
    wait until rising_edge(CLK);

--- needs implementation of circular or FIFO buffer
    
    DAC_DATA_ACK <= '1';
    TX <= DAC_DATA; -- data from FPGA to DAC

    if RST = '1' then
      STATE <= RESET;
      DAC_DATA_STB <= '0';
    end if; 
  end process;
end architecture RTL;
