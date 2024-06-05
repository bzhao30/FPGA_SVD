library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity sqrt_fixed_tb is
end sqrt_fixed_tb;


architecture testbench of sqrt_fixed_tb is

component sqrt_fixed is
port(
    clk : in std_logic;
    en : in std_logic;
    in1: in sfixed(9 downto -6);
    out1 : out sfixed(9 downto -6);
    done : out std_logic);
end component;

signal clk : std_logic := '0';
signal en : std_logic := '0';
signal in1, out1 : sfixed(9 downto -6) := (others => '0');
signal done : std_logic := '0';

begin

uut: sqrt_fixed port map(
    clk => clk,
    en => en,
    in1 => in1,
    out1 => out1,
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
in1 <= to_sfixed(2, 9, -6);



wait for 20 ns;
en <= '1';
wait for 150 ns;
en <= '0';
wait;
end process stim;

end testbench;