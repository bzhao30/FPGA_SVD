-- Top Level for the mathematical component before transmitting over UART
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity math_top_level is
port(
    clk : in std_logic; 
    en : in std_logic;
    matrix_A : in matrix;
    matrix_U : out matrix;
    matrix_S : out matrix;
    matrix_Vt : out matrix;
    done : out std_logic);
end math_top_level;

architecture behavioral of math_top_level is

component l2norm is
port( 
    clk : in std_logic;
    en : in std_logic;
    matrix_A : in matrix;
    done: out std_logic;
    result : out sfixed(9 downto -6));
end component;

component findjacobi is
port(
    en : in std_logic;
    matrix_A : in matrix;
    clk : in std_logic;
    matrix_V : in matrix;
    V_prime : out matrix;
    A_prime : out matrix;
    done : out std_logic);
end component;

component sortcol is
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
end component;

signal u_en, rst, j_en, i_tc, s_en, k_tc, sort_en, sort_done,j_done, l2done, upd : std_logic := '0';
signal I, K : integer := 0;
signal A_sig, A_prime, V_prime : matrix := (others => (others => to_sfixed(0.0, 9, -6)));
signal S, U, V, S1, U1, Vt , V_in, A_in: matrix := (others => (others => to_sfixed(0.0, 9, -6)));
signal skk : sfixed(9 downto -6) := (others => '0');
type statetype is (idle, clear, jacobi, update, findS, findU, sort, finish);
signal cs, ns : statetype := idle;

begin
-----------------Declare Components----------------
uu1: findjacobi
port map(
    clk => clk,
    en => j_en,
    matrix_A => A_in,
    matrix_V => V_in,
    V_prime => V_prime,
    A_prime => A_prime,
    done => j_done);

uu2: L2norm
port map(
    clk => clk,
    en => s_en,
    matrix_A => A_sig,
    done => l2done,
    result => skk);

uu3: sortcol
port map(
    clk => clk,
    en => sort_en,
    S => S,
    U => U, 
    V => V_prime,
    S1 => S1,
    U1 => U1,
    Vt => Vt,
    done => sort_done);
    
--------------Jacobi Iterator-------------
jacobicount : process(clk)
begin
if rising_edge(clk) then
if rst = '1' then
    i <= 0;
    i_tc <= '0';
    V_in(0)(0) <= to_sfixed(1, 9, -6);
    V_in(0)(1) <= to_sfixed(0, 9, -6);
    V_in(1)(0) <= to_sfixed(0, 9, -6);
    V_in(1)(1) <= to_sfixed(1, 9, -6);
    A_in <= matrix_A;
end if;
   
if j_done = '1' then
    i <= i+1;
    if i = 100 then -- iterate until convergence approximately
        i <= 0;
    end if;
end if;
if i = 100 and j_done = '1' then
    i_tc <= '1';
end if;

if upd = '1' then
    V_in <= V_prime;
    A_in <= A_prime;
end if;
end if;

end process jacobicount;

-------------Build SVD matrices---------------
counter_K : process(clk)
begin



if rising_edge(clk) then
if rst = '1' then
    k <= 0;
    K_TC <= '0';
end if;
if u_en = '1' then
    k <= k+1; 
    if k = 1 then
        k <= 0;
    end if;       
end if;
if k = 1 and u_en = '1' then
    K_TC <= '1';
end if;      
end if;
end process counter_K;

-- Build the matrix Sigma of the singular values
build1 : process (clk)
begin

if rising_edge(clk) then
if rst = '1' then
    S <= (others => (others => to_sfixed(0.0, 9, -6)));
end if;
    if u_en = '1' then
        A_sig <= (others => (others => to_sfixed(0.0, 9, -6)));
    end if;
    if s_en = '1' then
    if L2done = '1' then
        s(k)(k) <= skk;
    else
        A_sig(0)(k) <= A_prime(0)(k);
        A_sig(1)(k) <= A_prime(1)(k);
        
    end if;
    end if;
end if;
end process build1;

-- Build the matrix U
build2: process(clk)
begin

if rising_edge(clk) then
if rst = '1' then
    U <= (others => (others => to_sfixed(0.0, 9, -6)));
end if;
if U_en = '1' then
    if skk = to_sfixed(0, 9, -6) then
        U(0)(k) <= to_sfixed(0, 9, -6);
        U(1)(k) <= to_sfixed(0, 9, -6);
    else
        U(0)(k) <= resize(A_sig(0)(k)/skk, 9, -6);
        U(1)(k) <= resize(A_sig(1)(k)/skk, 9, -6);
    end if;
end if;
end if;

end process build2;


-- sort

matrix_S <= S1;
matrix_U <= U1;
matrix_Vt <= Vt;


----------------FSM---------------
stateupdate : process(clk)
begin
if rising_edge(clk) then
    cs <= ns;
end if;
end process stateupdate;

nextstatelogic: process(cs, en, i_tc, j_done, l2done, k_tc, sort_done)
begin
ns <= cs;
rst <= '0';
j_en <= '0';
upd <= '0';
s_en <= '0';
sort_en <= '0';
u_en <= '0';
done <= '0';

case cs is
    when idle =>
        if en = '1' then
            ns <= clear;
        end if;
    when clear =>
        RST <= '1';
        ns <= jacobi;
    when jacobi =>
        j_en <= '1';
        if j_done = '1' then
            ns <= update;
        end if;
    when update =>
        upd <= '1';
        if i_tc = '1' then
            ns <= findS;
        else
            ns <= jacobi;
        end if;    
    when findS =>
        s_en <= '1';
        if l2done = '1' then
        ns <= findU;
        end if;
    when findU =>
        u_en <= '1';
        if k_tc = '1' then
            ns <= sort;
        else
            ns <= findS;
        end if;
    when sort =>
        sort_en <= '1';
        if sort_done = '1' then
            ns <= finish;
        end if;
    when finish =>
        done <= '1';
        ns <= idle;
    when others => ns <= idle;
end case;
end process nextstatelogic;

end behavioral;