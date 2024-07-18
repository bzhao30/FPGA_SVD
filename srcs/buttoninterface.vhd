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

type statetype is (idle, debounce, pulse1, pulse2, wai);
signal cs, ns : statetype := idle;
signal done, buttonMP, cntrst, cnten, cnttc, db : std_logic := '0';
signal count : integer := 0;

begin

----------------Counter------------
process(clk) begin
if rising_edge(clk) then
    if cntrst = '1' then
        count <= 0;
    elsif cnten = '1' and count < 210 then
        count <= count + 1;
    end if;
end if;
end process;

process(count, buttonPort) begin
if count = 200 and buttonPort = '1' then
    db <= '1';
    cnttc <= '1';
elsif count = 200 then
    cnttc <= '1';
    db <= '0';
else
    db <= '0';
    cnttc <= '0';
end if;
end process;
buttonMPPort <= buttonMP;
----------------FSM-------------------
process(clk) begin
if rising_edge(clk) then
    cs <= ns;
end if;
end process;

process(cs, buttonPort, count) begin
ns <= cs;
cntrst <= '0';
done <= '0';
cnten <= '1';
buttonMP <= '0';

case cs is 
    when idle =>
    cntrst <= '1';
    if buttonPort = '1' then
        ns <= debounce;
    end if;
    when debounce => 
    cnten <= '1';
    if cnttc = '1' then
        if db = '1' then
            ns <= pulse1;
        else
            ns <= idle;
        end if;
    end if;
    when pulse1 => 
    buttonMP <= '1';
    ns <= pulse2;
    when pulse2 =>
    buttonMP <= '1';
    ns <= wai;
    when wai =>
    if buttonPort = '0' then
        ns <= idle;
    end if;
    when others => ns <= idle;
end case;

end process;
    
    


end behavioral;
