-- Sorts columns of matrices according to largest singular values
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity sortcol is 
port(
    clk : in std_logic;
    en : in std_logic;
    S : in matrix;
    U : in matrix;
    V: in matrix;
    S1 : out matrix;
    U1 : out matrix;
    Vt : out matrix;
    done : out std_logic);
end sortcol;
    
architecture behavioral of sortcol is
signal j: integer := 0;
signal Stemp, Utemp, Vtemp : matrix := (others => (others => (to_sfixed(0.0, 9, -6))));
signal high, med, low : integer := 0;
signal rst, sort_en, sort_done : std_logic := '0';
type statetype is (idle, clear, sort, finish);
signal cs, ns : statetype := idle;


begin

-------------------Find Which Index is High, Low, Medium--------------
order : process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            -- Initialize indices
            high <= 0;
            low <= 1;

            -- Compare S(0)(0) and S(1)(1) to find the high and low indices
            if S(0)(0) >= S(1)(1) then
                high <= 0;
                low <= 1;
            else
                high <= 1;
                low <= 0;
            end if;
        end if;
    end if;
end process order;

------------------------Counters--------------------
counter_j : process(clk)
begin

if rst = '1' then
    j <= 0;
    sort_done <= '0';
end if;

if rising_edge(clk) then
if sort_en = '1' then
    j <= j+1;    
    if j = 1 then
        j <= 0;
    end if;       
end if;
end if;
if j = 1 then
    Sort_done <= '1';
else
    sort_done <= '0';
end if;   

end process counter_J;

--------------------REORDER MATRICES----------------------
reorder : process (clk)
begin
if rising_edge(clk) then 
if sort_en = '1' then

    Utemp(j)(0) <= U(j)(high);
    Utemp(j)(1) <= U(j)(low);
    
    Stemp(0)(0) <= S(high)(high);
    Stemp(1)(1) <= S(low)(low);
    
    Vtemp(j)(0) <= V(j)(high);
    Vtemp(j)(1) <= V(j)(low);

end if;
end if;
end process reorder;
    

S1 <= Stemp;
U1 <= Utemp;
Vt <= transpose(Vtemp);



--------------------FSM--------------------------
stateupdate: process(clk)
begin
if rising_edge(clk) then
    CS <= NS;
end if;
end process stateupdate;

nextstatelogic: process(CS, en, sort_done)
begin
NS <= CS;
rst <= '0';
sort_en <= '0';
done <= '0';

case CS is
    when idle =>
        if en = '1' then
            NS <= clear;
        end if;
    when clear =>
        rst <= '1';
        ns <= sort;
    when sort =>
        sort_en <= '1';
        if sort_done = '1' then
            NS <= finish;
        end if;
    when finish =>
        done <= '1';
        NS <= idle;
    when others => ns <= idle;
end case;
end process nextstatelogic;

end behavioral;