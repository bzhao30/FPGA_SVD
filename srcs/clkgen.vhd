-- Clock generator
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library UNISIM;
use UNISIM.VComponents.all;

entity clkGen is
  port (clkExtPort: in std_logic;
        clkPort: out std_logic);
end clkgen;

architecture behavioral of clkgen is

  constant clkDividerTC: integer := 50;
  constant countLen: integer := integer(ceil(log2(real(clkDividerTC))));
  signal clkDividerCtr: unsigned(countLen-1 downto 0) := (others => '0');
  signal clkTog: std_logic := '0';
  
begin
  clockDivider: process(clkExtPort)
  begin
    if rising_edge(clkExtPort) then
      if clkDividerCtr = clkDividerTC - 1 then
        clkTog <= not(clkTog);
        clkDividerCtr <= (others => '0');
      else
        clkDividerCtr <= clkDividerCtr + 1;
      end if;
    end if;
  end process;

  clkBuffer: BUFG
    port map (I => clkTog,
              O => clkPort);
  
end behavioral;

    