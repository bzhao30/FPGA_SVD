library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity tobcd_tb is
end tobcd_tb;

architecture testbench of tobcd_tb is

component tobcd is
port(
    clk : in std_logic;
    en : in std_logic;
    input : in matrix;
    output : out std_logic_vector(231 downto 0);
    done : out std_logic);
end component;
--
signal clk, en, done : std_logic:= '0';
signal matrix_A : matrix := (others => (others => to_sfixed(0.0, 9, -6)));
signal result : std_logic_vector(231 downto 0) := (others => '0');

begin

uut: tobcd PORT MAP(
    clk => clk,
    en => en,
    input => matrix_A,
    output => result,
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
matrix_A(1)(0) <= to_sfixed(3, 9, -6);
matrix_A(1)(1) <= to_sfixed(-4, 9, -6);


wait for 20 ns;
en <= '1';
wait for 110 ns;
en <= '0';
wait;
end process stim;



end testbench;