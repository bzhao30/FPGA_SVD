library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity sortcol_tb is
end sortcol_tb;

architecture testbench of sortcol_tb is

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
--
signal clk, en, done : std_logic:= '0';
signal S, U, V, S1, U1, Vt : matrix := (others => (others => to_sfixed(0.0, 9, -6)));

begin

uut: sortcol PORT MAP(
    clk => clk,
    en => en,
    S => S,
    U => U,
    V => V,
    S1 => S1,
    U1 => U1, 
    Vt => Vt,
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

-- U
U(0)(0) <= to_sfixed(1, 9, -6);
U(0)(1) <= to_sfixed(0, 9, -6);
U(1)(0) <= to_sfixed(0, 9, -6);
U(1)(1) <= to_sfixed(1, 9, -6);

-- S
S(0)(0) <= to_sfixed(1, 9, -6);
S(1)(1) <= to_sfixed(1, 9, -6);

-- V
V(0)(0) <= to_sfixed(0, 9, -6);
V(0)(1) <= to_sfixed(0, 9, -6);
V(1)(0) <= to_sfixed(1, 9, -6);
V(1)(1) <= to_sfixed(2, 9, -6);

wait for 20 ns;
en <= '1';
wait for 110 ns;
en <= '0';
wait;
end process stim;



end testbench;