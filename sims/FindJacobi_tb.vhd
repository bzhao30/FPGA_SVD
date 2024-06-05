library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity FindJacobi_tb is
end FindJacobi_tb;

architecture testbench of FindJacobi_tb is

component FindJacobi is
port(
    en : in std_logic;
    matrix_A : in matrix;
    clk : in std_logic;
    matrix_V : in matrix;
    V_prime : out matrix;
    A_prime : out matrix;
    done : out std_logic);
end component;
--
signal clk, en, done : std_logic:= '0';
signal matrix_A , matrix_V, A_prime, V_prime: matrix := (others => (others => to_sfixed(0.0, 9, -6)));

begin

uut: FindJacobi PORT MAP(
    en => en,
    matrix_A => matrix_A,
    clk => clk,
    matrix_V => matrix_V,
    A_prime => A_prime,
    V_prime => V_prime,
    done => done);
    
clock: process
begin
wait for 10 ns;
clk <= '1';
wait for 10 ns;
clk <= '0';
end process clock;


stim: process
begin
wait for 20 ns;

--2x2
matrix_A(0)(0) <= to_sfixed(1, 9, -6);
matrix_A(0)(1) <= to_sfixed(2, 9, -6);
matrix_A(1)(0) <= to_sfixed(4, 9, -6);
matrix_A(1)(1) <= to_sfixed(5, 9, -6);


--2x2
matrix_V(0)(0) <= to_sfixed(1, 9, -6);
matrix_V(0)(1) <= to_sfixed(0, 9, -6);
matrix_V(1)(0) <= to_sfixed(0, 9, -6);
matrix_V(1)(1) <= to_sfixed(1, 9, -6);


wait for 20 ns;
en <= '1';
wait for 10 ms;
en <= '0';
wait;
end process stim;



end testbench;