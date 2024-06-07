library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FIFO is
port(
    clk: in std_logic;
    write : in std_logic;
    read : in std_logic;
    length : in unsigned(4 downto 0);
    data_in : in std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0);
    empty : out std_logic;
    full : out std_logic);
end FIFO;
    
architecture behavioral of FIFO is

type regfile is array(0 to to_integer(length)-1) of std_logic_vector(7 downto 0);
signal queue : regfile := (others =>(others => '0'));

signal W_ADDR, R_ADDR : integer := 0;
signal element_cnt : integer := 0;
signal full_sig, empty_sig : std_logic := '0';


begin

process(clk, element_cnt)
begin
if rising_edge(clk) then
    if (write = '1') and (full_sig = '0') then
        queue(W_ADDR) <= data_in;
        if W_ADDR = to_integer(length)-1 then
            W_ADDR <= 0;
        else
            W_ADDR <= W_ADDR + 1;
        end if;
    end if;
    
    if (read = '1') and (empty_sig = '0') then
        queue(R_ADDR) <= (others => '0');
        if R_ADDR = to_integer(length) - 1 then
            R_ADDR <= 0;
        else 
            R_ADDR <= R_ADDR + 1;
        end if;
    end if;
    
    if (write = '1') and (full_sig = '0') then
        element_cnt <= element_cnt + 1;
    elsif (read = '1') and (empty_sig = '0') then
        element_cnt <= element_cnt -1;
    end if;
end if;

full_sig <= '0';
empty_sig <= '0';
if element_cnt = to_integer(length) then
    full_sig <= '1';
elsif element_cnt = 0 then
    empty_sig <= '1';
end if;
end process;

full <= full_sig;
empty <= empty_sig;
data_out <= queue(R_ADDR);        
        
end behavioral;