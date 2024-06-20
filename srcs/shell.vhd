-- Top Level Shell for SVD matrix calculator
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;

entity shell is
port(
    RxExtPort : in std_logic;
    clkExtPort : in std_logic;
    buttonPort : in std_logic;
    TxExtPort : out std_logic);
end shell;

architecture behavioral of shell is

component math_top_level is
port(
    clk : in std_logic; 
    en : in std_logic;
    matrix_A : in matrix;
    matrix_U : out matrix;
    matrix_S : out matrix;
    matrix_Vt : out matrix;
    done : out std_logic);
end component;

component toBCD is
port(
    clk : in std_logic;
    en : in std_logic;
    input : in matrix;
    output : out std_logic_vector(231 downto 0);
    done : out std_logic);
end component;
    
component toMatrix is
port(
    en : in std_logic;
    clk : in std_logic;
    input: in std_logic_vector(71 downto 0);
    output: out matrix;
    done : out std_logic);
end component;
   
component receiver is
port(
    Rx : in std_logic;
    en : in std_logic;
    clk : in std_logic;
    hard_reset : in std_logic;
    Rxout : out std_logic_vector(71 downto 0);
    done : out std_logic);
end component;
    
component transmitter is
port(
    clk : in std_logic;
    en : in std_logic;
    hard_reset : in std_logic;
    data_in : in std_logic_vector(815 downto 0);
    tx : out std_logic;
    done : out std_logic);
end component;

component clkgen is
port(
    clkExtPort: in std_logic;
    clkPort: out std_logic);
end component;

component buttoninterface is 
  port(
       clk: in std_logic;
       buttonPort: in std_logic;
       buttonMpPort: out std_logic);
end component;


type statetype is (clr, waitRx, to_Matrix, math, to_bcd, setup, trans);
signal cs, ns : statetype := waitRx;
signal bport, bmp : std_logic := '0';
signal rx_done, rx_en, tm_en, tm_done, m_en, m_done, tb_en, tb_done, s_en, tx_en, tx_done, hard_reset : std_logic := '0';
signal rx, tx, clkextsig, clk : std_logic;
signal rxout : std_logic_vector(71 downto 0) := (others => '0');
signal matrix_A, matrix_U, matrix_S, matrix_Vt : matrix := (others => (others => to_sfixed(0.0, 9, -6)));
signal outputU, outputS, outputVt : std_logic_vector(231 downto 0) := (others => '0');
signal tx_sig : std_logic := '1';
signal data : std_logic_vector(815 downto 0) := (others => '0');
signal data1 : std_logic_vector(351 downto 0) := (others => '0');
signal data2 : std_logic_vector(463 downto 0) := (others => '0');

begin

clkextsig <= clkextport;
rx <= rxextport;
txextport <= tx;
bport <= buttonport;

u1 : clkgen
port map(
    clkextport => clkextsig,
    clkport => clk);
    
u2 : receiver
port map(
    rx => rx,
    hard_reset => hard_reset,
    en => rx_en, 
    clk => clk,
    rxout => rxout,
    done => rx_done);
    
u3 : toMatrix
port map(
    en => tm_en,
    clk => clk,
    input => rxout,
    output => matrix_A,
    done => tm_done);
    
u4 : math_top_level
port map(
    clk => clk,
    en => m_en,
    matrix_A => matrix_A,
    matrix_U => matrix_U,
    matrix_S => matrix_S,
    matrix_Vt => matrix_Vt,
    done => m_done);
    
u5 : toBCD
port map(
    clk => clk,
    en => tb_en,
    input => matrix_U,
    output => outputU,
    done => tb_done);
    
u6 : toBCD
port map(
    clk => clk,
    en => tb_en,
    input => matrix_S,
    output => outputS);

u7 : toBCD
port map(
    clk => clk,
    en => tb_en,
    input => matrix_Vt,
    output => outputVt);
    
u8: transmitter
port map(
    clk => clk,
    en => tx_en,
    hard_reset => hard_reset,
    data_in => data,
    tx => tx_sig,
    done => tx_done);

u9: buttonInterface
port map(
    clk => clk,
    buttonPort => bport,
    buttonMpPort => hard_reset);
    
--------------------Datapath-------------

-- Load in ASCII values to transmit to PuTTY over UART
process(clk)
begin
if s_en = '1' then --(815 downto 0);
    data(815 downto 792) <= "010100110101011001000100";   --SVD
    data(791 downto 720) <= rxout;   --rxout
    data(719 downto 696) <= "001000000011110100100000";   --space=space
    data(695 downto 464) <= outputU;   --outputU
    data(463 downto 232) <= outputS;   --outputS
    data(231 downto 0)   <= outputVt;   -- outputVt
    
    -- FOR SIMS ONLY
    data1(351 downto 328) <= "010100110101011001000100";   --SVD
    data1(327 downto 256) <= rxout;   --rxout
    data1(255 downto 232) <= "001000000011110100100000";   --space=space
    data1(231 downto 0) <= outputU;   --outputU
    data2(463 downto 232) <= outputS;   --outputS
    data2(231 downto 0)   <= outputVt;   -- outputVt
    

end if;
end process;    

tx <= tx_sig;


-----------------------FSM--------------------
stateupdate : process(clk)
begin
if rising_edge(clk) then
    cs <= ns;
end if;
end process stateupdate;

nextstatelogic : process(cs, rx_done, tm_done, m_done, tb_done, tx_done, hard_reset)
begin
ns <= cs;
tm_en <= '0';
m_en <= '0';
tb_en <= '0';
s_en <= '0';
tx_en <= '0';
rx_en <= '0';

case cs is
    when waitRx =>
        rx_en <= '1';
        if rx_done = '1' then
            ns <= to_matrix;
        end if;
    when to_matrix =>
        tm_en <= '1';
        if hard_reset = '1' then
            ns <= waitRx;
        elsif tm_done = '1' then
            ns <= math;
        end if;
    when math =>    
        m_en <= '1';
        if hard_reset = '1' then
            ns <= waitRx;
        elsif m_done = '1' then
            ns <= to_bcd;
        end if;
    when to_bcd =>
        tb_en <= '1';
        if hard_reset = '1' then
            ns <= waitRx;
        elsif tb_done = '1' then
            ns <= setup;
        end if;
    when setup =>
        s_en <= '1';
        if hard_reset = '1' then
            ns <= waitRx;
        else
            ns <= trans;
        end if;
    when trans =>
        tx_en <= '1';
        if hard_reset = '1' then
            ns <= waitRx;        
        elsif tx_done = '1' then
            ns <= clr;
        end if;
    when clr => 
        ns <= waitRx;
    when others => ns <= clr;
end case;

end process nextstatelogic;


end behavioral;