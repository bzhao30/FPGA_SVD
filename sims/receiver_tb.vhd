library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity receiver_tb is
end receiver_tb;

architecture testbench of receiver_tb is

component receiver is
port(
    Rx : in std_logic;
    en : in std_logic;
    clk : in std_logic;
    hard_reset: in std_logic;
    Rxout : out std_logic_vector(71 downto 0);
    done : out std_logic);
end component;

signal Rx, en, clk, done, hard_reset : std_logic := '0';
signal Rxout : std_logic_vector(71 downto 0);

begin

uut: receiver
PORT MAP(
    Rx => Rx,
    en => en,
    clk => clk,
    hard_reset => hard_reset,
    Rxout => Rxout,
    done => done);
    
clock: process
begin
    clk <= '0';
    wait for 5ns;   
    clk <= '1';
    wait for 5ns;
end process;
  
stim: process
begin
    Rx <= '1';
    wait for 2 us;
    en <= '1';
    wait for 13 us;
     -- ASCII '[' : 01011011  01011011
    Rx <= '0'; -- start bit
    wait for 1us;
    Rx <= '1'; -- LSB
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0'; -- MSB
    wait for 1us;
    Rx <= '1'; -- stop bit
    wait for 10us;

    -- ASCII '1' : 00110001
    Rx <= '0'; -- start bit
    wait for 1us;
    Rx <= '1'; -- LSB
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0'; -- MSB
    wait for 1us;
    Rx <= '1'; -- stop bit
    wait for 10us;

    -- ASCII ' ' : 00100000
    Rx <= '0'; -- start bit
    wait for 1us;
    Rx <= '0'; -- LSB
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0'; -- MSB
    wait for 1us;
    Rx <= '1'; -- stop bit
    wait for 10us;

    -- ASCII '2' : 00110010
    Rx <= '0'; -- start bit
    wait for 1us;
    Rx <= '0'; -- LSB
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0'; -- MSB
    wait for 1us;
    Rx <= '1'; -- stop bit
    wait for 10us;

    -- ASCII ';' : 00111011
    Rx <= '0'; -- start bit
    wait for 1us;
    Rx <= '1'; -- LSB
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0'; -- MSB
    wait for 1us;
    Rx <= '1'; -- stop bit
    wait for 10us;

    -- ASCII '3' : 00110011
    Rx <= '0'; -- start bit
    wait for 1us;
    Rx <= '1'; -- LSB
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0'; -- MSB
    wait for 1us;
    Rx <= '1'; -- stop bit
    wait for 10us;

    -- ASCII ' ' : 00100000
    Rx <= '0'; -- start bit
    wait for 1us;
    Rx <= '0'; -- LSB
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0'; -- MSB
    wait for 1us;
    Rx <= '1'; -- stop bit
    wait for 10us;

    -- ASCII '4' : 00110100
    Rx <= '0'; -- start bit
    wait for 1us;
    Rx <= '0'; -- LSB
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0'; -- MSB
    wait for 1us;
    Rx <= '1'; -- stop bit
    wait for 10us;

    -- ASCII ']' : 01011101 01011101
    Rx <= '0'; -- start bit
    wait for 1us;
    Rx <= '1'; -- LSB
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0'; -- MSB
    wait for 1us;
    Rx <= '1'; -- stop bit
    wait for 10us;
    
    ---CHECK OVERFLOW
    Rx <= '0'; -- start bit
    wait for 1us;
    Rx <= '0'; -- LSB
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '1';
    wait for 1us;
    Rx <= '0';
    wait for 1us;
    Rx <= '0'; -- MSB
    wait for 1us;
    Rx <= '1'; -- stop bit
    wait for 10us;
    hard_reset <= '1';
    wait for 1 us;
    hard_reset <= '0';
    wait;
end process stim;

end testbench;
