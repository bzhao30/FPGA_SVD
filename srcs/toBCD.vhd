-- Converts the sfixed matrix format into binary ASCII code for transmission
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
    en : in std_logic;
    input : in matrix;
    output : out std_logic_vector(231 downto 0);
    done : out std_logic);
end toBCD;

architecture behavioral of toBCD is
signal rst, sign_en, int_en, dec_en, frac_en, nxt_tc, next_en : std_logic := '0';
signal output_sig : std_logic_vector(231 downto 0) := (others => '0');
signal nxtcnt : integer := 0;
signal sign1, sign2, sign3, sign4 : std_logic_vector(7 downto 0) := (others => '0');
signal int1, int2, int3, int4, frac1, frac2, frac3, frac4 : std_logic_vector(15 downto 0) := (others => '0');
signal decimal : std_logic_vector(7 downto 0) := (others => '0');
signal tempo, tempa : sfixed(9 downto -6) := (others => '0');
signal debug : std_logic := '0';


type statetype is (idle, clear, swait, sign, int, dec, frac, nxt, finish);
signal cs, ns : statetype := idle;

begin

------------------BUILD MATRIX TEMPLATE------------
output_sig(231 downto 224) <= "01011011"; --      [_ _;_ _]
output_sig(175 downto 168) <= "00100000";
output_sig(119 downto 112) <= "00111011";
output_sig(63 downto 56) <= "00100000";
output_sig(7 downto 0) <= "01011101";

--decimal points
decimal <= "00101110";

-- Determines which index of matrix we are translating
nxtcounter : process(clk)
begin
if rising_edge(clk) then
    if rst = '1' then
        nxtcnt <= 0;
        nxt_tc <= '0';
        tempa <= (others => '0');
    elsif next_en = '1' and nxt_tc = '0' then 
        nxtcnt <= nxtcnt + 1;
    end if;
end if;
if nxtcnt = 3 and next_en = '1' then
    nxt_tc <= '1';
    nxtcnt <= 0;
end if;

case nxtcnt is 
    when 0 => 
        tempa <= input(0)(0);
    when 1 =>
        tempa <= input(0)(1);
    when 2 =>
        tempa <= input(1)(0);
    when 3 =>
        tempa <= input(1)(1);
    when others => tempa <= (others => '0');
end case;


end process nxtcounter;

-- Accounts for the signed aspect of sfixed
flipneg : process(tempa)
begin
    if rst = '1' then
        tempo <= (others => '0');
    end if;
    if tempa(9) = '1' then
        tempo <= fixedmultiply(tempa, to_sfixed(-1, 9, -6));
    else
        tempo <= tempa;
    end if;
end process flipneg;
    
    
-- ASCII for sign part of ultimate printed text
signpart : process(clk)
begin
if rising_edge(clk) then
    if rst = '1' then
        sign1 <= (others => '0');
        sign2 <= (others => '0');
        sign3 <= (others => '0');
        sign4 <= (others => '0');
    end if;
    
    if sign_en = '1' then
        if tempa(9) = '1' then
            debug <= '1';
            case nxtcnt is
                when 0 =>
                    sign1 <= "00101101"; -- "-"
                when 1 =>
                    sign2 <= "00101101";
                when 2 =>
                    sign3 <= "00101101";
                when 3 =>
                    sign4 <= "00101101";
                when others =>
            end case;
         else
            case nxtcnt is
                when 0 =>
                    sign1 <= "00100000"; -- "space"
                when 1 =>
                    sign2 <= "00100000";
                when 2 =>
                    sign3 <= "00100000";
                when 3 =>
                    sign4 <= "00100000";
                when others =>
            end case;   
         end if;      
    end if;
end if;
end process signpart;

-- Determines the whole number part of the sfixed to ASCII conversion
intpart : process(clk)
variable result : std_logic_vector(15 downto 0) := (others => '0');
begin
    if rst = '1' then
        int1 <= (others => '0');
        int2 <= (others => '0');
        int3 <= (others => '0');
        int4 <= (others => '0');
    end if;

if rising_edge(clk) then

    -- LUT was probably the best way to go here
    if int_en = '1' then
        case tempo(8 downto 0) is
        when "000000000" =>
            result := "0011000000110000";  -- 00
        when "000000001" =>
            result := "0011000000110001";  -- 01
        when "000000010" =>
            result := "0011000000110010";  -- 02
        when "000000011" =>
            result := "0011000000110011";  -- 03
        when "000000100" =>
            result := "0011000000110100";  -- 04
        when "000000101" =>
            result := "0011000000110101";  -- 05
        when "000000110" =>
            result := "0011000000110110";  -- 06
        when "000000111" =>
            result := "0011000000110111";  -- 07
        when "000001000" =>
            result := "0011000000111000";  -- 08
        when "000001001" =>
            result := "0011000000111001";  -- 09
        when "000001010" =>
            result := "0011000100110000";  -- 10
        when "000001011" =>
            result := "0011000100110001";  -- 11
        when "000001100" =>
            result := "0011000100110010";  -- 12
        when "000001101" =>
            result := "0011000100110011";  -- 13
        when "000001110" =>
            result := "0011000100110100";  -- 14
        when "000001111" =>
            result := "0011000100110101";  -- 15
        when "000010000" =>
            result := "0011000100110110";  -- 16
        when "000010001" =>
            result := "0011000100110111";  -- 17
        when "000010010" =>
            result := "0011000100111000";  -- 18
        when "000010011" =>
            result := "0011000100111001";  -- 19
        when "000010100" =>
            result := "0011001000110000";  -- 20
        when "000010101" =>
            result := "0011001000110001";  -- 21
        when "000010110" =>
            result := "0011001000110010";  -- 22
        when "000010111" =>
            result := "0011001000110011";  -- 23
        when "000011000" =>
            result := "0011001000110100";  -- 24
        when "000011001" =>
            result := "0011001000110101";  -- 25
        when "000011010" =>
            result := "0011001000110110";  -- 26
        when "000011011" =>
            result := "0011001000110111";  -- 27
        when "000011100" =>
            result := "0011001000111000";  -- 28
        when "000011101" =>
            result := "0011001000111001";  -- 29
        when "000011110" =>
            result := "0011001100110000";  -- 30
        when "000011111" =>
            result := "0011001100110001";  -- 31
        when "000100000" =>
            result := "0011001100110010";  -- 32
        when "000100001" =>
            result := "0011001100110011";  -- 33
        when "000100010" =>
            result := "0011001100110100";  -- 34
        when "000100011" =>
            result := "0011001100110101";  -- 35
        when "000100100" =>
            result := "0011001100110110";  -- 36
        when "000100101" =>
            result := "0011001100110111";  -- 37
        when "000100110" =>
            result := "0011001100111000";  -- 38
        when "000100111" =>
            result := "0011001100111001";  -- 39
        when "000101000" =>
            result := "0011010000110000";  -- 40
        when "000101001" =>
            result := "0011010000110001";  -- 41
        when "000101010" =>
            result := "0011010000110010";  -- 42
        when "000101011" =>
            result := "0011010000110011";  -- 43
        when "000101100" =>
            result := "0011010000110100";  -- 44
        when "000101101" =>
            result := "0011010000110101";  -- 45
        when "000101110" =>
            result := "0011010000110110";  -- 46
        when "000101111" =>
            result := "0011010000110111";  -- 47
        when "000110000" =>
            result := "0011010000111000";  -- 48
        when "000110001" =>
            result := "0011010000111001";  -- 49
        when "000110010" =>
            result := "0011010100110000";  -- 50
        when "000110011" =>
            result := "0011010100110001";  -- 51
        when "000110100" =>
            result := "0011010100110010";  -- 52
        when "000110101" =>
            result := "0011010100110011";  -- 53
        when "000110110" =>
            result := "0011010100110100";  -- 54
        when "000110111" =>
            result := "0011010100110101";  -- 55
        when "000111000" =>
            result := "0011010100110110";  -- 56
        when "000111001" =>
            result := "0011010100110111";  -- 57
        when "000111010" =>
            result := "0011010100111000";  -- 58
        when "000111011" =>
            result := "0011010100111001";  -- 59
        when "000111100" =>
            result := "0011011000110000";  -- 60
        when "000111101" =>
            result := "0011011000110001";  -- 61
        when "000111110" =>
            result := "0011011000110010";  -- 62
        when "000111111" =>
            result := "0011011000110011";  -- 63
        when "001000000" =>
            result := "0011011000110100";  -- 64
        when "001000001" =>
            result := "0011011000110101";  -- 65
        when "001000010" =>
            result := "0011011000110110";  -- 66
        when "001000011" =>
            result := "0011011000110111";  -- 67
        when "001000100" =>
            result := "0011011000111000";  -- 68
        when "001000101" =>
            result := "0011011000111001";  -- 69
        when "001000110" =>
            result := "0011011100110000";  -- 70
        when "001000111" =>
            result := "0011011100110001";  -- 71
        when "001001000" =>
            result := "0011011100110010";  -- 72
        when "001001001" =>
            result := "0011011100110011";  -- 73
        when "001001010" =>
            result := "0011011100110100";  -- 74
        when "001001011" =>
            result := "0011011100110101";  -- 75
        when "001001100" =>
            result := "0011011100110110";  -- 76
        when "001001101" =>
            result := "0011011100110111";  -- 77
        when "001001110" =>
            result := "0011011100111000";  -- 78
        when "001001111" =>
            result := "0011011100111001";  -- 79
        when "001010000" =>
            result := "0011100000110000";  -- 80
        when "001010001" =>
            result := "0011100000110001";  -- 81
        when "001010010" =>
            result := "0011100000110010";  -- 82
        when "001010011" =>
            result := "0011100000110011";  -- 83
        when "001010100" =>
            result := "0011100000110100";  -- 84
        when "001010101" =>
            result := "0011100000110101";  -- 85
        when "001010110" =>
            result := "0011100000110110";  -- 86
        when "001010111" =>
            result := "0011100000110111";  -- 87
        when "001011000" =>
            result := "0011100000111000";  -- 88
        when "001011001" =>
            result := "0011100000111001";  -- 89
        when "001011010" =>
            result := "0011100100110000";  -- 90
        when "001011011" =>
            result := "0011100100110001";  -- 91
        when "001011100" =>
            result := "0011100100110010";  -- 92
        when "001011101" =>
            result := "0011100100110011";  -- 93
        when "001011110" =>
            result := "0011100100110100";  -- 94
        when "001011111" =>
            result := "0011100100110101";  -- 95
        when "001100000" =>
            result := "0011100100110110";  -- 96
        when "001100001" =>
            result := "0011100100110111";  -- 97
        when "001100010" =>
            result := "0011100100111000";  -- 98
        when "001100011" =>
            result := "0011100100111001";  -- 99
        when others =>
            result := "0000000000000000";
        end case;
        
        
        
        case nxtcnt is 
            when 0 => 
                int1 <= result;
            when 1 =>
                int2 <= result;
            when 2 =>
                int3 <= result;
            when 3 =>
                int4 <= result;
            when others =>
        end case;
    end if;
end if;
end process intpart;

-- Same but for fractional component
fracpart : process(clk)
variable result : std_logic_vector(15 downto 0) := (others => '0');
begin
if rising_edge(clk) then
    if rst = '1' then
        frac1 <= (others => '0');
        frac2 <= (others => '0');
        frac3 <= (others => '0');
        frac4 <= (others => '0');
    end if;

    if frac_en = '1' then
        case tempo(-1 downto -6) is
            when "000000" =>
                result := "0011000000110000";  -- 00
            when "000001" =>
                result := "0011000000110010";  -- 02
            when "000010" =>
                result := "0011000000110011";  -- 03
            when "000011" =>
                result := "0011000000110101";  -- 05
            when "000100" =>
                result := "0011000000110110";  -- 06
            when "000101" =>
                result := "0011000000111000";  -- 08
            when "000110" =>
                result := "0011000000111001";  -- 09
            when "000111" =>
                result := "0011000100110001";  -- 11
            when "001000" =>
                result := "0011000100110010";  -- 12
            when "001001" =>
                result := "0011000100110100";  -- 14
            when "001010" =>
                result := "0011000100110110";  -- 16
            when "001011" =>
                result := "0011000100110111";  -- 17
            when "001100" =>
                result := "0011000100111001";  -- 19
            when "001101" =>
                result := "0011001000110000";  -- 20
            when "001110" =>
                result := "0011001000110010";  -- 22
            when "001111" =>
                result := "0011001000110011";  -- 23
            when "010000" =>
                result := "0011001000110101";  -- 25
            when "010001" =>
                result := "0011001000110111";  -- 27
            when "010010" =>
                result := "0011001000111000";  -- 28
            when "010011" =>
                result := "0011001100110000";  -- 30
            when "010100" =>
                result := "0011001100110001";  -- 31
            when "010101" =>
                result := "0011001100110011";  -- 33
            when "010110" =>
                result := "0011001100110100";  -- 34
            when "010111" =>
                result := "0011001100110110";  -- 36
            when "011000" =>
                result := "0011001100111000";  -- 38
            when "011001" =>
                result := "0011001100111001";  -- 39
            when "011010" =>
                result := "0011010000110001";  -- 41
            when "011011" =>
                result := "0011010000110010";  -- 42
            when "011100" =>
                result := "0011010000110100";  -- 44
            when "011101" =>
                result := "0011010000110101";  -- 45
            when "011110" =>
                result := "0011010000110111";  -- 47
            when "011111" =>
                result := "0011010000111000";  -- 48
            when "100000" =>
                result := "0011010100110000";  -- 50
            when "100001" =>
                result := "0011010100110010";  -- 52
            when "100010" =>
                result := "0011010100110011";  -- 53
            when "100011" =>
                result := "0011010100110101";  -- 55
            when "100100" =>
                result := "0011010100110110";  -- 56
            when "100101" =>
                result := "0011010100111000";  -- 58
            when "100110" =>
                result := "0011010100111001";  -- 59
            when "100111" =>
                result := "0011011000110001";  -- 61
            when "101000" =>
                result := "0011011000110010";  -- 62
            when "101001" =>
                result := "0011011000110100";  -- 64
            when "101010" =>
                result := "0011011000110110";  -- 66
            when "101011" =>
                result := "0011011000110111";  -- 67
            when "101100" =>
                result := "0011011000111001";  -- 69
            when "101101" =>
                result := "0011011100110000";  -- 70
            when "101110" =>
                result := "0011011100110010";  -- 72
            when "101111" =>
                result := "0011011100110011";  -- 73
            when "110000" =>
                result := "0011011100110101";  -- 75
            when "110001" =>
                result := "0011011100110111";  -- 77
            when "110010" =>
                result := "0011011100111000";  -- 78
            when "110011" =>
                result := "0011100000110000";  -- 80
            when "110100" =>
                result := "0011100000110001";  -- 81
            when "110101" =>
                result := "0011100000110011";  -- 83
            when "110110" =>
                result := "0011100000110100";  -- 84
            when "110111" =>
                result := "0011100000110110";  -- 86
            when "111000" =>
                result := "0011100000111000";  -- 88
            when "111001" =>
                result := "0011100000111001";  -- 89
            when "111010" =>
                result := "0011100100110001";  -- 91
            when "111011" =>
                result := "0011100100110010";  -- 92
            when "111100" =>
                result := "0011100100110100";  -- 94
            when "111101" =>
                result := "0011100100110101";  -- 95
            when "111110" =>
                result := "0011100100110111";  -- 97
            when "111111" =>
                result := "0011100100111000";  -- 98
            when others => 
                result := "0000000000000000";
        end case;
        
     case nxtcnt is 
        when 0 => 
            frac1 <= result;
        when 1 =>
            frac2 <= result;
        when 2 =>
            frac3 <= result;
        when 3 =>
            frac4 <= result;
        when others =>
    end case;       
    end if;
end if;
end process fracpart;

output_sig(223 downto 216) <= sign1;
output_sig(215 downto 200) <= int1;
output_sig(199 downto 192) <= decimal;
output_sig(191 downto 176) <= frac1;

output_sig(167 downto 160) <= sign2;
output_sig(159 downto 144) <= int2;
output_sig(143 downto 136) <= decimal;
output_sig(135 downto 120) <= frac2;

output_sig(111 downto 104) <= sign3;
output_sig(103 downto 88) <= int3;
output_sig(87 downto 80) <= decimal;
output_sig(79 downto 64) <= frac3;

output_sig(55 downto 48) <= sign4;
output_sig(47 downto 32) <= int4;
output_sig(31 downto 24) <= decimal;
output_sig(23 downto 8) <= frac4;

output <= output_sig;

--------------------FSM--------------------------
stateupdate: process(clk)
begin
if rising_edge(clk) then
    CS <= NS;
end if;
end process stateupdate;

nextstatelogic: process(CS, en, nxt_tc)
begin
NS <= CS;
rst <= '0';
sign_en <= '0';
int_en <= '0';
dec_en <= '0';
frac_en <= '0';
done <= '0';
next_en <= '0';

case CS is
    when idle =>
        if en = '1' then
            NS <= clear;
        end if;
    when clear =>
        rst <= '1';
        ns <= swait;
    when swait => ns <= sign;
    when sign =>
        sign_en <= '1';
        ns <= int;
    when int =>
        int_en <= '1';
        ns <= dec;
    when dec =>
        dec_en <= '1';
        ns <= frac;
    when frac =>
        frac_en <= '1';
        ns <= nxt;
    when nxt =>
        next_en <= '1';
        if nxt_tc = '1' then
            ns <= finish;
        else
            ns <= swait;
        end if;
    when finish =>
        done <= '1';
        NS <= idle;
    when others => ns <= idle;
end case;
end process nextstatelogic;


end behavioral;