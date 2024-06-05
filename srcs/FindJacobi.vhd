library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity FindJacobi is 
port(
    en : in std_logic;
    matrix_A : in matrix;
    clk : in std_logic;
    matrix_V : in matrix;
    V_prime : out matrix;
    A_prime : out matrix;
    done : out std_logic);
end Findjacobi;

architecture behavioral of FindJacobi is

component matrixmultiply is
port(
    clk: in std_logic;
    en : in std_logic;
    matrix_A: in matrix;
    matrix_B: in matrix;
    matrix_C : out matrix;
    done : out std_logic);
end component;

component sqrt_fixed is 
port(
    clk : in std_logic;
    en : in std_logic;
    in1: in sfixed(9 downto -6);
    out1 : out sfixed(9 downto -6);
    done : out std_logic);
end component; 

signal RST, ce, m_en, m_done, j_en, p_tc, mav_en , mav_done, update, tau_en, tau_done, tan_en, tan_done: std_logic := '0';
signal p: integer := 0;
signal q: integer := 1;
signal sin, cos, sign, tan, tau, tau_in, tan_in, tau_out, tan_out, abstau: sfixed(9 downto -6) := (others => '0');
signal matrix_J, AtA, Apt, A_prime_sig, V_sig, A_in, V_in: matrix := (others => (others => (to_sfixed(0.0, 9, -6))));
type statetype is (idle, clear, count, swait, multiplyAtA, sqtau, sqtan, getJacobi, multiplyA_V, updateAV, finish);
signal cs, ns : statetype := idle;


begin
-----------------Declare Components----------------
u1: matrixmultiply
port map(
    clk => clk,
    en => m_en,
    matrix_A => Apt,
    matrix_B => A_in,
    matrix_C => AtA,
    done => m_done);

u2: matrixmultiply
port map(
    clk => clk,
    en => mav_en,
    matrix_A => V_in,
    matrix_B => matrix_J,
    matrix_C => V_sig,
    done => mav_done);

u3: matrixmultiply
port map(
    clk => clk,
    en => mav_en,
    matrix_A => A_in,
    matrix_B => matrix_J,
    matrix_C => A_prime_sig);
    
u4: sqrt_fixed -- TAU
port map(
    clk => clk,
    en => tau_en,
    in1 => tau_in,
    out1 => tau_out,
    done => tau_done);
    
u5: sqrt_fixed -- TAN
port map(
    clk => clk,
    en => tan_en,
    in1 => tan_in,
    out1 => tan_out,
    done => tan_done);
    
    

----------------get sin, cos----------------
Apt <= transpose(A_in);

MATA: process(clk)
variable alpha, beta, gamma, tau_var, abstau_var: sfixed(9 downto -6) := to_sfixed(0.0, 9, -6);
begin
if rising_edge(clk) then
if m_en = '1' then
-- u1 matrixmultiply
    if m_done = '1' then
        alpha := AtA(p)(p);
        beta := AtA(q)(q);
        gamma := AtA(p)(q);

        -- Determine the sign of gamma
        if gamma(9) = '1' then  -- Check if the sign bit is set (negative number)
            sign <= to_sfixed(-1, 9, -6);  -- Convert -1 to sfixed format
        else
            sign <= to_sfixed(1, 9, -6);  -- Convert +1 to sfixed format
        end if;
        -- Compute tau, tan
        if gamma = to_sfixed(0, 9, -6) then
            tau_var := to_sfixed(256, 9, -6);
        else
            tau_var := resize((beta - alpha) / (fixedmultiply(to_sfixed(2.0, 9, -6), gamma)), 9, -6);
        end if;
        
        if tau > to_sfixed(0, 9, -6) then
            abstau_var := tau;
        else
            abstau_var := fixedmultiply(to_sfixed(-1, 9, -6), tau);
        end if;
        
    end if;
end if;
end if;
tau <= tau_var;
tau_in <= resize(1+fixedmultiply(tau_var, tau_var), 9, -6);
abstau <= abstau_var;

end process MATA;

findtan: process(clk)
variable tan_var : sfixed(9 downto -6) := (others => '0');
begin
if rising_edge(clk) then
if tau_done = '1' then
    tan_var := resize(sign/(abstau + tau_out), 9, -6);
end if;
end if;
tan <= tan_var;
tan_in <= resize(1+fixedmultiply(tan_var, tan_var), 9, -6);
end process findtan;

findsincos : process(clk)
begin
if rising_edge(clk) then
if tan_done = '1' then
     cos <= resize(1/tan_out, 9, -6);
     sin <= resize(tan/tan_out, 9, -6);
end if;
end if;
end process findsincos;

--------------get Jacobi matrix------------
jacobi : process(clk)
begin
if rising_edge(clk) then
if j_en = '1' then

    matrix_J(0)(0) <= cos;
    matrix_J(0)(1) <= sin;
    matrix_J(1)(0) <= fixedmultiply(to_sfixed(-1, 9, -6), sin);
    matrix_J(1)(1) <= cos;
        
end if;
end if;
end process jacobi;

----------------get U and A -----------------
UA : process(clk)
begin
if rising_edge(clk) then
-- Find Matrix V, A
if RST = '1' then
    V_in <= matrix_V;
    A_in <= matrix_A;
end if;
    -- matrix multiply u2
    -- matrix multiply u3
if update = '1' then
    A_in <= A_prime_sig; 
    V_in <= V_sig;
end if;
end if;
end process UA;

A_prime <= A_prime_sig;
V_prime <= V_sig;

---------------------FSM-----------------------
stateupdate: process(clk)
begin
if rising_edge(clk) then
    CS <= NS;
end if;
end process stateupdate;

nextstatelogic: process(cs, en, p_tc, m_done, tau_done, tan_done, mav_done)
begin
NS <= CS;
RST <= '0';
ce <= '0';
m_en <= '0';
j_en <= '0';
mav_en <= '0';
tau_en <= '0';
tan_en <= '0';
update <= '0';
done <= '0';

case cs is
    when idle =>
        if en = '1' then
            ns <= clear;
        end if;
    when clear =>
        RST <= '1';
        ns <= count;
    when count =>
    ce <= '1';
    ns <= swait;
    when swait =>
        ns <= multiplyAtA;
    when multiplyAtA =>
        m_en <= '1';
        if m_done = '1' then
            ns <= sqtau;
        end if;
    when sqtau =>
        tau_en <= '1';
        if tau_done = '1' then
            ns <= sqtan;
        end if;
    when sqtan =>
        tan_en <= '1';
        if tan_done = '1' then
            ns <= getJacobi;
        end if;
    when getJacobi => 
        j_en <= '1';
        ns <= multiplyA_V;
    when multiplyA_V =>
        mav_en <= '1';
        if mav_done = '1' then
            ns <= updateAV;
        end if;
    when updateAV =>
        update <= '1';
        ns <= finish;
    when finish => 
        done <= '1';
        ns <= idle;
    when others => ns <= idle;
end case;

end process nextstatelogic;


end behavioral;