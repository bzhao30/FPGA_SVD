library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity math_top_level_tb is
end math_top_level_tb;

architecture testbench of math_top_level_tb is

component math_top_level is
port(
    clk : in std_logic; 
    en : in std_logic;
    matrix_A : in matrix;
    matrix_U : out matrix;
    matrix_S : out matrix;
    matrix_Vt : out matrix;
    done : out std_logic);
end component;

signal clk, en, done : std_logic:= '0';
signal matrix_A, matrix_U, matrix_S, matrix_Vt: matrix := (others => (others => to_sfixed(0.0, 9, -6)));

begin

uut: math_top_level PORT MAP(
    clk => clk,
    en => en,
    matrix_A => matrix_A,
    matrix_U => matrix_U,
    matrix_S => matrix_S,
    matrix_Vt => matrix_Vt,
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
matrix_A(0)(0) <= to_sfixed(10, 9, -6);
matrix_A(0)(1) <= to_sfixed(2, 9, -6);
matrix_A(1)(0) <= to_sfixed(3, 9, -6);
matrix_A(1)(1) <= to_sfixed(4, 9, -6);



wait for 20 ns;
en <= '1';
wait for 27 us;
en <= '0';
wait;
end process stim;



end testbench;