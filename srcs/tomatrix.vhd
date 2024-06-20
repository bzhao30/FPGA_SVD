-- Converts received ASCII binary into an sfixed matrix. Takes in form [1 2;3 4]
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_textio.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity toMatrix is 
port(
    en : in std_logic;
    clk : in std_logic;
    input: in std_logic_vector(71 downto 0);
    output: out matrix;
    done : out std_logic);
end toMatrix;


architecture behavioral of toMatrix is

signal readcnt : integer := 0;
signal read_done, rst, read_en : std_logic := '0';
signal output_sig : matrix := (others => (others => to_sfixed(0.0, 9, -6)));


type statetype is (idle, clear, read, finish);
signal cs, ns : statetype := idle;

begin

-- Sets up counter for next process
readcounter : process(clk)
begin
if rising_edge(clk) then
    if rst = '1' then
        readcnt <= 0;
        read_done <= '0';
    elsif read_en = '1' and read_done = '0' then 
        readcnt <= readcnt + 1;
    end if;
    
    
if readcnt = 3 and read_en = '1' then
    read_done <= '1';
    readcnt <= 0;
end if;
end if;

end process readcounter;

-- For each number it inputs into matrix
readp : process(clk)
variable readin : std_logic_vector(7 downto 0) := (others => '0');
variable result : sfixed(9 downto -6) := (others => '0');
begin
if rising_edge(clk) then
if read_en = '1' then
    case readcnt is
        when 0 => 
            readin := input(63 downto 56);
        when 1 =>
            readin := input(47 downto 40);
        when 2 =>
            readin := input(31 downto 24);
        when 3 =>
            readin := input(15 downto 8);
        when others => 
            readin := (others => '0');
    end case;
    
    case readin is
        when "00110000" => -- ASCII for '0'
            result := to_sfixed(0.0, 9, -6);
        when "00110001" => -- ASCII for '1'
            result := to_sfixed(1.0, 9, -6);
        when "00110010" => -- ASCII for '2'
            result := to_sfixed(2.0, 9, -6);
        when "00110011" => -- ASCII for '3'
            result := to_sfixed(3.0, 9, -6);
        when "00110100" => -- ASCII for '4'
            result := to_sfixed(4.0, 9, -6);
        when "00110101" => -- ASCII for '5'
            result := to_sfixed(5.0, 9, -6);
        when "00110110" => -- ASCII for '6'
            result := to_sfixed(6.0, 9, -6);
        when "00110111" => -- ASCII for '7'
            result := to_sfixed(7.0, 9, -6);
        when "00111000" => -- ASCII for '8'
            result := to_sfixed(8.0, 9, -6);
        when "00111001" => -- ASCII for '9'
            result := to_sfixed(9.0, 9, -6);
        when others =>
            result := to_sfixed(0.0, 9, -6); -- Default case
    end case;
    
    case readcnt is
        when 0 => 
            output_sig(0)(0) <= result;
        when 1 =>
            output_sig(0)(1) <= result;
        when 2 =>
            output_sig(1)(0) <= result;
        when 3 =>
            output_sig(1)(1) <= result;
        when others => 
    end case;    
    
    
end if;
end if;
end process readp;

output <= output_sig;
--------------------FSM--------------------------
stateupdate: process(clk)
begin
if rising_edge(clk) then
    CS <= NS;
end if;
end process stateupdate;

nextstatelogic: process(CS, en, read_done)
begin
NS <= CS;
rst <= '0';
read_en <= '0';
done <= '0';

case CS is
    when idle =>
        if en = '1' then
            NS <= clear;
        end if;
    when clear =>
        rst <= '1';
        ns <= read;
    when read =>
        read_en <= '1';
        if read_done = '1' then
            NS <= finish;
        end if;
    when finish =>
        done <= '1';
        NS <= idle;
    when others => ns <= idle;
end case;
end process nextstatelogic;


end behavioral;