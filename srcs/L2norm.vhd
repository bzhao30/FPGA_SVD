library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity l2norm is 
port( 
    clk : in std_logic;
    en : in std_logic;
    matrix_A : in matrix;
    done: out std_logic;
    result : out sfixed(9 downto -6));
end l2norm;

architecture behavioral of l2norm is 

component sqrt_fixed is 
port(
    clk : in std_logic;
    en : in std_logic;
    in1: in sfixed(9 downto -6);
    out1 : out sfixed(9 downto -6);
    done : out std_logic);
end component; 

signal calc, rst : std_logic := '0';
signal SumofSquares, result_sig : sfixed(9 downto -6) := (others => '0');
signal i, j : integer := 0;
signal I_TC, J_TC , sqrt_en, sqrt_done: std_logic := '0';

type statetype is (idle, clear, calculate, sqrt, finish);
signal cs, ns : statetype := idle;

begin

u1: sqrt_fixed
port map(
    clk => clk,
    en => sqrt_en,
    in1 => SumofSquares,
    out1 => result_sig,
    done => sqrt_done);
    
------------------TWO COUNTERS----------------
counter_j : process(clk)
begin

if rst = '1' then
    j <= 0;
    J_TC <= '0';
end if;

if rising_edge(clk) then
if calc = '1' then
    j <= j+1; 
    if j = 1 then
        j <= 0;
    end if;       
end if;
end if;
if j = 1 then
    J_TC <= '1';
else
    J_TC <= '0';
end if; 

end process counter_j;

counter_I : process(clk)
begin

if rst = '1' then
    i <= 0;
    I_TC <= '0';
end if;

if rising_edge(clk) then
if J_TC = '1' then
    i <= i+1;  
    if i = 1 then
        i <= 0;
    end if;  
end if;     
end if;
if i = 1 and j = 1 then
    I_TC <= '1';
else
    I_TC <= '0';
end if;   

end process counter_I;

-----------------CALCULATION-------------
SOS: process(clk)
begin
if rising_edge(clk) then
    if RST = '1' then
        SumofSquares <= (others => '0');
    elsif calc = '1' then
        SumofSquares <= resize(SumofSquares + fixedmultiply(matrix_A(i)(j), matrix_A(i)(j)), 9, -6);
    end if;
end if;

end process SOS;

result <= result_sig;

--------------------FSM--------------------------
stateupdate: process(clk)
begin
if rising_edge(clk) then
    CS <= NS;
end if;
end process stateupdate;

nextstatelogic: process(CS, en, sqrt_done, i_TC)
begin
NS <= CS;
rst <= '0';
calc <= '0';
sqrt_en <= '0';
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
            NS <= sqrt;
        end if;
    when sqrt =>
        sqrt_en <= '1';
        if sqrt_done = '1' then
            ns <= finish;
        end if;
    when finish =>
        done <= '1';
        NS <= idle;
    when others => ns <= idle;
end case;
end process nextstatelogic;


end behavioral;