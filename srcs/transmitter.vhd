-- Transmits resulting SVD in ASCII form over to PuTTY
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity transmitter is 
port(
    clk : in std_logic;
    en : in std_logic;
    hard_reset : in std_logic;
    data_in : in std_logic_vector(815 downto 0);
    tx : out std_logic;
    done : out std_logic);
end transmitter;


architecture behavioral of transmitter is

signal data : std_logic_vector(1019 downto 0);

signal t_en, baud_tc, bit_tc, s_tc, s_en, r_en, rst : std_logic := '0';
signal tx_sig : std_logic := '1';
signal baudcount, bitcount : integer := 0;
type statetype is (idle, clr, setup, trans, finish, reset);
signal cs, ns : statetype := idle;

begin
-------------------Counters------------------
baudcounter : process(clk)
begin

if rst = '1' then
  baudcount <= 0;
  baud_tc <= '0';
end if;

if rising_edge(clk) then
if t_en = '1' then
  baudcount <= baudcount+1; 
  if baudcount = 103 then
    baudcount <= 0;
  end if;       
end if;
end if;
if baudcount = 103 then
  baud_TC <= '1';
else
  baud_TC <= '0';
end if;      

end process baudcounter;

bitcounter : process(clk)
begin

if rst = '1' then
  bitcount <= 0;
  bit_TC <= '0';
end if;

if rising_edge(clk) then
if baud_TC = '1' then
  bitcount <= bitcount+1;    
  if bitcount = 1019 then
    bitcount <= 0;
  end if;       
end if;
end if;
if bitcount = 1019 and baudcount = 103 then
  bit_TC <= '1';
else
  bit_TC <= '0';
end if;   

end process bitcounter;

----------------------Shift Register-----------------
SR : process(clk, hard_reset)
variable count : integer := 0;
begin
if rising_edge(clk) then

    if t_en = '1' then
        tx_sig <= data(1019 - bitcount);
    else
        tx_sig <= '1';
    end if;
    -- Can clear screen / send over the singular value decomposition ASCII depending on case
    if r_en = '1' then
        data <= "100011011010101101101001100100101001010010001101101010110110101001000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";
    elsif rst = '1' then 
        count := 0;
        s_tc <= '0';
    elsif s_en = '1' then
        -- Manually calculate the indices
        data(1019 - count * 10) <= '0';  -- Start bit
        data(1010 - count * 10) <= '1';  -- Stop bit

        -- Assign data bits from data_in
        data(1018 - count * 10) <= data_in(808 - count * 8);
        data(1017 - count * 10) <= data_in(809 - count * 8);
        data(1016 - count * 10) <= data_in(810 - count * 8);
        data(1015 - count * 10) <= data_in(811 - count * 8);
        data(1014 - count * 10) <= data_in(812 - count * 8);
        data(1013 - count * 10) <= data_in(813 - count * 8);
        data(1012 - count * 10) <= data_in(814 - count * 8);
        data(1011 - count * 10) <= data_in(815 - count * 8);
        
        count := count + 1;
        if count = 102 then
            count := 0;
            s_tc <= '1';
        end if;
    end if;
end if;
end process SR;

tx <= tx_sig;
--------------------FSM---------------------
stateupdate: process(clk)
begin
if rising_edge(clk) then
    cs <= ns;
end if;
end process stateupdate;

nextstatelogic: process(cs, en, s_tc, bit_tc, hard_reset)
begin
ns <= cs;
rst <= '0';
s_en <= '0';
t_en <= '0';
done <= '0';
r_en <= '0';
case cs is
    when idle =>
        if hard_reset = '1' then
            ns <= reset;
        elsif en = '1' then
            ns <= clr;
        end if;
    when reset =>
        r_en <= '1';
        ns <= trans;
    when clr =>
        rst <= '1';
        if hard_reset = '1' then
            ns <= reset;
        else
            ns <= setup;
        end if;
    when setup =>
        s_en <= '1';
        if hard_reset = '1' then
            ns <= reset;
            
        elsif s_tc = '1' then
            ns <= trans;
        end if;
    when trans =>
        t_en <= '1';
        if hard_reset = '1' then
            ns <= reset;
        elsif bit_tc = '1' then
            ns <= finish;
        end if;
    when finish => 
        done <= '1';
        ns <= idle;
    when others => ns <= idle;
end case;
end process nextstatelogic;

end behavioral;
