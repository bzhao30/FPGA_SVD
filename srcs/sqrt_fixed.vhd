library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity sqrt_fixed is
port(
    clk : in std_logic;
    en : in std_logic;
    in1: in sfixed(9 downto -6);
    out1 : out sfixed(9 downto -6);
    done : out std_logic);
end sqrt_fixed;

architecture behavioral of sqrt_fixed is

signal rst, calc, i_tc : std_logic := '0';
signal result: sfixed(9 downto -6) := (others => '0');
signal i : integer := 0;

type statetype is (idle, clear, calculate, finish);
signal cs, ns : statetype := idle;
begin

-----------------Counting------------------
counter_i : process(clk)
begin

if rst = '1' then
    i <= 0;
    i_TC <= '0';
end if;

if rising_edge(clk) then
if calc = '1' then
    i <= i+1; 
    if i = 16 then
        i <= 0;
    end if;       
end if;
end if;
if i = 16 or in1 = to_sfixed(0, 9, -6) then
    I_TC <= '1';
else
    I_TC <= '0';
end if; 

end process counter_i;

-------------------Arithmetic-------------------
arithmetic : process(clk)
begin
if rising_edge(clk) then
if in1 = to_sfixed(0, 9, -6) or rst = '1' then
    result <= resize(in1/2, 9, -6);
end if;
if calc = '1' then
    result <= resize((result + in1 / result) / 2, 9, -6);  
end if;
end if;
end process arithmetic;

out1 <= result;
--------------------FSM--------------------------
stateupdate: process(clk)
begin
if rising_edge(clk) then
    CS <= NS;
end if;
end process stateupdate;

nextstatelogic: process(CS, en, i_TC)
begin
NS <= CS;
rst <= '0';
calc <= '0';
done <= '0';

case CS is
    when idle =>
        if en = '1' then
            NS <= clear;
        end if;
    when clear =>
        rst <= '1';
        ns <= calculate;
    when calculate =>
        calc <= '1';
        if I_TC = '1' then
            NS <= finish;
        end if;
    when finish =>
        done <= '1';
        NS <= idle;
    when others => ns <= idle;
end case;
end process nextstatelogic;
end behavioral;
    