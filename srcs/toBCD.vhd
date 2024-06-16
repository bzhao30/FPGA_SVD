library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_textio.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity toBCD is
port(
    clk : in std_logic;
    input : in matrix;
    output : out std_logic);
    
end bcdconv;

