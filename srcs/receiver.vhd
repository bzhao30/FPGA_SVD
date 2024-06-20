-- Receives ASCII input from PuTTY over UART
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity receiver is
port(
    Rx : in std_logic;
    en : in std_logic;
    clk : in std_logic;
    hard_reset : in std_logic;
    Rxout : out std_logic_vector(71 downto 0);
    done : out std_logic);
end receiver;


architecture behavioral of receiver is

signal baudcount, bitcount, datacount : integer := 0;
signal load, baud_tc, bit_tc, data_tc: std_logic := '0';
signal rst, count_en, data_en, send : std_logic := '0';
signal data :  std_logic_vector(7 downto 0) := (others => '0');
type statetype is (idle, clear, count, move, ssend, finish, init);
signal cs, ns : statetype := init;
signal rx_sig : std_logic_vector(71 downto 0) := (others => '0');

begin
    
------------------COUNTERS---------------
baudcounter : process(clk)
begin

if rst = '1' then
  baudcount <= 0;
  baud_tc <= '0';
end if;

if rising_edge(clk) then
if count_en = '1' then
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
  if bitcount = 8 then
    bitcount <= 0;
  end if;       
end if;
end if;
if bitcount = 8 and baudcount = 103 then
  bit_TC <= '1';
else
  bit_TC <= '0';
end if;   

end process bitcounter;

-- Sends signals to controller letting it know when all data has been received
datacounter : process(clk, hard_reset)
begin

if send = '1' then
  datacount <= 0;
end if;


if rising_edge(clk) then
    if bit_tc = '1' and data_tc = '0' then
      datacount <= datacount+1;  
      if datacount = 8 then
        datacount <= 0;
      end if;       
    end if;
    
    
    if baudcount = 103 and bitcount = 7 and datacount = 8 then
        data_TC <= '1';
    elsif hard_reset = '1' then
        data_tc <= '0';
    end if;
end if;

end process datacounter;


----------------SHIFT REGISTERS----------------
-- receives the incoming UART and writes into data signal
SR8 : process(clk, hard_reset)
begin
if hard_reset = '1' then
    data <= (others => '0');
end if;
if rising_edge(clk) then
    if baud_tc = '1' and bit_tc = '0' then
        data <= RX & data(7 downto 1);
    end if;
end if;

end process SR8;

-- loads each character into a continuous string of ascii 
SR72 : process(clk, hard_reset)
begin
if hard_reset = '1' then
    rx_sig <= (others => '0');
end if;
if rising_edge(clk) then
    if data_en = '1' then
        rx_sig <= rx_sig(63 downto 0) & data;
    end if;
end if;


end process SR72;
rxout <= rx_sig;

---------------------FSM----------------------
stateupdate: process(clk)
begin
if rising_edge(clk) then
    cs <= ns;
end if;
end process stateupdate;

nextstatelogic: process(cs, rx, bit_tc, data_tc)
begin
ns <= cs;
rst <= '0';
count_en <= '0';
data_en <= '0';
send <= '0';
done <= '0';

case cs is 
    when init => 
        if en = '1' then 
            ns <= idle;
        end if;
    when idle =>
        if rx = '0' then
            ns <= clear;
        end if;
    when clear =>
        rst <= '1';
        ns <= count;
    when count =>
        count_en <= '1';
        if bit_tc = '1' then
            ns <= move;
        end if;
    when move =>
        data_en <= '1';
        if data_tc = '1' then
            ns <= ssend;
        else
            ns <= idle;
        end if;
    when ssend =>
        send <= '1';
        ns <= finish;
    when finish =>
        done <= '1';
        ns <= init;
    when others => ns <= init;
end case;
end process nextstatelogic;

end behavioral;