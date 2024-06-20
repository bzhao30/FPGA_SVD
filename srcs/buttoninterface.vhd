-- Button monopulser
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity buttonInterface is
  port(
    clk: in std_logic;
    buttonPort: in std_logic;
    buttonMpPort: out std_logic
  );
end buttonInterface;

architecture behavioral of buttonInterface is
  -- Internal and control signals.
  signal mpDelayReg: std_logic := '0';
  signal pulseReg: std_logic := '0';

begin
  -- Monopulse the button press.
  monopulser: process(clk)
  begin
    if rising_edge(clk) then
      mpDelayReg <= buttonPort;
      pulseReg <= buttonPort and not(mpDelayReg);
    end if;
  end process monopulser;

  buttonMpPort <= pulseReg;

end behavioral;
