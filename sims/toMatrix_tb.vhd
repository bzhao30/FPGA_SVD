library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity toMatrix_tb is
end toMatrix_tb;

architecture testbench of toMatrix_tb is

component toMatrix is
port(
    clk : in std_logic;
    en : in std_logic;
    input : in std_logic_vector(71 downto 0);
    output : out matrix;
    done : out std_logic);
end component;
--
signal clk, en, done : std_logic:= '0';
signal matrix_A : matrix := (others => (others => to_sfixed(0.0, 9, -6)));
signal input : std_logic_vector(71 downto 0);
begin

uut: toMatrix PORT MAP(
    clk => clk,
    en => en,
    input => input,
    output => matrix_A,
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

input(71 downto 64) <= "01011011";
input(63 downto 56) <= "00110001";
input(55 downto 48) <= "00100000";
input(47 downto 40) <= "00110010";
input(39 downto 32) <= "00111011";
input(31 downto 24) <= "00110011";
input(23 downto 16) <= "00100000";
input(15 downto 8) <= "00110100";
input(7 downto 0) <= "01011101";


wait for 20 ns;
en <= '1';
wait for 110 ns;
en <= '0';
wait;
end process stim;



end testbench;