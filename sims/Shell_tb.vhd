library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shell_tb is
end shell_tb;

architecture testbench of shell_tb is

component shell is
port(
    Rx : in std_logic;
    clkextport : in std_logic;
    Tx : out std_logic);
end component;

signal Rx, clkextport, Tx : std_logic := '0';

begin

uut: shell
PORT MAP(
    Rx => Rx,
    clkextport => clkextport,
    Tx => Tx);
    
clock: process
begin
    clkextport <= '0';
    wait for 5ns;   
    clkextport <= '1';
    wait for 5ns;
end process;
  
stim: process
begin
    Rx <= '1';
    wait for 15 us;
    -- ASCII '[' : 01011011
    Rx <= '0'; -- start bit
    wait for 104 us;
    Rx <= '1'; -- LSB
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0'; -- MSB
    wait for 104 us;
    Rx <= '1'; -- stop bit
    wait for 104 us;

    -- ASCII '1' : 00110001
    Rx <= '0'; -- start bit
    wait for 104 us;
    Rx <= '1'; -- LSB
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0'; -- MSB
    wait for 104 us;
    Rx <= '1'; -- stop bit
    wait for 104 us;

    -- ASCII ' ' : 00100000
    Rx <= '0'; -- start bit
    wait for 104 us;
    Rx <= '0'; -- LSB
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0'; -- MSB
    wait for 104 us;
    Rx <= '1'; -- stop bit
    wait for 104 us;

    -- ASCII '2' : 00110010
    Rx <= '0'; -- start bit
    wait for 104 us;
    Rx <= '0'; -- LSB
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0'; -- MSB
    wait for 104 us;
    Rx <= '1'; -- stop bit
    wait for 104 us;

    -- ASCII ';' : 00111011
    Rx <= '0'; -- start bit
    wait for 104 us;
    Rx <= '1'; -- LSB
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0'; -- MSB
    wait for 104 us;
    Rx <= '1'; -- stop bit
    wait for 104 us;

    -- ASCII '3' : 00110011
    Rx <= '0'; -- start bit
    wait for 104 us;
    Rx <= '1'; -- LSB
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0'; -- MSB
    wait for 104 us;
    Rx <= '1'; -- stop bit
    wait for 104 us;

    -- ASCII ' ' : 00100000
    Rx <= '0'; -- start bit
    wait for 104 us;
    Rx <= '0'; -- LSB
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0'; -- MSB
    wait for 104 us;
    Rx <= '1'; -- stop bit
    wait for 104 us;

    -- ASCII '4' : 00110100
    Rx <= '0'; -- start bit
    wait for 104 us;
    Rx <= '0'; -- LSB
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '0'; -- MSB
    wait for 104 us;
    Rx <= '1'; -- stop bit
    wait for 104 us;

    -- ASCII ']' : 01011101
    Rx <= '0'; -- start bit
    wait for 104 us;
    Rx <= '1'; -- LSB
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0';
    wait for 104 us;
    Rx <= '1';
    wait for 104 us;
    Rx <= '0'; -- MSB
    wait for 104 us;
    Rx <= '1'; -- stop bit
    wait;

end process stim;

end testbench;
