library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity matrixmultiply_tb is
end matrixmultiply_tb;

architecture testbench of matrixmultiply_tb is

component matrixmultiply is
port(
    clk: in std_logic;
    en : in std_logic;
    matrix_A: in matrix;
    matrix_B: in matrix;
    matrix_C : out matrix;
    done : out std_logic);
end component;
--
signal clk, en, done : std_logic:= '0';
signal matrix_A, matrix_B, matrix_C : matrix := (others => (others => to_sfixed(0.0, 9, -6)));

begin

uut: matrixmultiply PORT MAP(
    clk => clk,
    en => en,
    matrix_A => matrix_A,
    matrix_B => matrix_B,
    matrix_C => matrix_C,
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
matrix_A(0)(1) <= to_sfixed(0, 9, -6);
matrix_A(1)(0) <= to_sfixed(0, 9, -6);
matrix_A(1)(1) <= to_sfixed(1, 9, -6);


--2x2
matrix_B(0)(0) <= to_sfixed(0.75, 9, -6);
matrix_B(0)(1) <= to_sfixed(0, 9, -6);
matrix_B(1)(0) <= to_sfixed(0, 9, -6);
matrix_B(1)(1) <= to_sfixed(1, 9, -6);



wait for 20 ns;
en <= '1';
wait for 110 ns;
en <= '0';
wait;
end process stim;



end testbench;