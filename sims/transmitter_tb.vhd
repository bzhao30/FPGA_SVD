library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity transmitter_tb is
end transmitter_tb;

architecture testbench of transmitter_tb is

component transmitter is
port(
    clk : in std_logic;
    en : in std_logic;
    data_in : in std_logic_vector(815 downto 0);
    tx : out std_logic;
    done : out std_logic);
end component;

signal tx, clk, done, en : std_logic := '0';
signal data_in : std_logic_vector(815 downto 0) := (others => '0');

begin

uut: transmitter
PORT MAP(
    clk => clk,
    en => en,
    data_in => data_in,
    tx => tx,
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
    -- Manually assign ASCII letters 'A' to 'Z' to data_in
    data_in(815 downto 808) <= "01000001"; -- 'A'
    data_in(807 downto 800) <= "01000010"; -- 'B'
    data_in(799 downto 792) <= "01000011"; -- 'C'
    data_in(791 downto 784) <= "01000100"; -- 'D'
    data_in(783 downto 776) <= "01000101"; -- 'E'
    data_in(775 downto 768) <= "01000110"; -- 'F'
    data_in(767 downto 760) <= "01000111"; -- 'G'
    data_in(759 downto 752) <= "01001000"; -- 'H'
    data_in(751 downto 744) <= "01001001"; -- 'I'
    data_in(743 downto 736) <= "01001010"; -- 'J'
    data_in(735 downto 728) <= "01001011"; -- 'K'
    data_in(727 downto 720) <= "01001100"; -- 'L'
    data_in(719 downto 712) <= "01001101"; -- 'M'
    data_in(711 downto 704) <= "01001110"; -- 'N'
    data_in(703 downto 696) <= "01001111"; -- 'O'
    data_in(695 downto 688) <= "01010000"; -- 'P'
    data_in(687 downto 680) <= "01010001"; -- 'Q'
    data_in(679 downto 672) <= "01010010"; -- 'R'
    data_in(671 downto 664) <= "01010011"; -- 'S'
    data_in(663 downto 656) <= "01010100"; -- 'T'
    data_in(655 downto 648) <= "01010101"; -- 'U'
    data_in(647 downto 640) <= "01010110"; -- 'V'
    data_in(639 downto 632) <= "01010111"; -- 'W'
    data_in(631 downto 624) <= "01011000"; -- 'X'
    data_in(623 downto 616) <= "01011001"; -- 'Y'
    data_in(615 downto 608) <= "01011010"; -- 'Z'
    data_in(607 downto 600) <= "01000001"; -- 'A'
    data_in(599 downto 592) <= "01000010"; -- 'B'
    data_in(591 downto 584) <= "01000011"; -- 'C'
    data_in(583 downto 576) <= "01000100"; -- 'D'
    data_in(575 downto 568) <= "01000101"; -- 'E'
    data_in(567 downto 560) <= "01000110"; -- 'F'
    data_in(559 downto 552) <= "01000111"; -- 'G'
    data_in(551 downto 544) <= "01001000"; -- 'H'
    data_in(543 downto 536) <= "01001001"; -- 'I'
    data_in(535 downto 528) <= "01001010"; -- 'J'
    data_in(527 downto 520) <= "01001011"; -- 'K'
    data_in(519 downto 512) <= "01001100"; -- 'L'
    data_in(511 downto 504) <= "01001101"; -- 'M'
    data_in(503 downto 496) <= "01001110"; -- 'N'
    data_in(495 downto 488) <= "01001111"; -- 'O'
    data_in(487 downto 480) <= "01010000"; -- 'P'
    data_in(479 downto 472) <= "01010001"; -- 'Q'
    data_in(471 downto 464) <= "01010010"; -- 'R'
    data_in(463 downto 456) <= "01010011"; -- 'S'
    data_in(455 downto 448) <= "01010100"; -- 'T'
    data_in(447 downto 440) <= "01010101"; -- 'U'
    data_in(439 downto 432) <= "01010110"; -- 'V'
    data_in(431 downto 424) <= "01010111"; -- 'W'
    data_in(423 downto 416) <= "01011000"; -- 'X'
    data_in(415 downto 408) <= "01011001"; -- 'Y'
    data_in(407 downto 400) <= "01011010"; -- 'Z'
    data_in(399 downto 392) <= "01000001"; -- 'A'
    data_in(391 downto 384) <= "01000010"; -- 'B'
    data_in(383 downto 376) <= "01000011"; -- 'C'
    data_in(375 downto 368) <= "01000100"; -- 'D'
    data_in(367 downto 360) <= "01000101"; -- 'E'
    data_in(359 downto 352) <= "01000110"; -- 'F'
    data_in(351 downto 344) <= "01000111"; -- 'G'
    data_in(343 downto 336) <= "01001000"; -- 'H'
    data_in(335 downto 328) <= "01001001"; -- 'I'
    data_in(327 downto 320) <= "01001010"; -- 'J'
    data_in(319 downto 312) <= "01001011"; -- 'K'
    data_in(311 downto 304) <= "01001100"; -- 'L'
    data_in(303 downto 296) <= "01001101"; -- 'M'
    data_in(295 downto 288) <= "01001110"; -- 'N'
    data_in(287 downto 280) <= "01001111"; -- 'O'
    data_in(279 downto 272) <= "01010000"; -- 'P'
    data_in(271 downto 264) <= "01010001"; -- 'Q'
    data_in(263 downto 256) <= "01010010"; -- 'R'
    data_in(255 downto 248) <= "01010011"; -- 'S'
    data_in(247 downto 240) <= "01010100"; -- 'T'
    data_in(239 downto 232) <= "01010101"; -- 'U'
    data_in(231 downto 224) <= "01010110"; -- 'V'
    data_in(223 downto 216) <= "01010111"; -- 'W'
    data_in(215 downto 208) <= "01011000"; -- 'X'
    data_in(207 downto 200) <= "01011001"; -- 'Y'
    data_in(199 downto 192) <= "01011010"; -- 'Z'
    data_in(191 downto 184) <= "01000001"; -- 'A'
    data_in(183 downto 176) <= "01000010"; -- 'B'
    data_in(175 downto 168) <= "01000011"; -- 'C'
    data_in(167 downto 160) <= "01000100"; -- 'D'
    data_in(159 downto 152) <= "01000101"; -- 'E'
    data_in(151 downto 144) <= "01000110"; -- 'F'
    data_in(143 downto 136) <= "01000111"; -- 'G'
    data_in(135 downto 128) <= "01001000"; -- 'H'
    data_in(127 downto 120) <= "01001001"; -- 'I'
    data_in(119 downto 112) <= "01001010"; -- 'J'
    data_in(111 downto 104) <= "01001011"; -- 'K'
    data_in(103 downto 96)  <= "01001100"; -- 'L'
    data_in(95 downto 88)   <= "01001101"; -- 'M'
    data_in(87 downto 80)   <= "01001110"; -- 'N'
    data_in(79 downto 72)   <= "01001111"; -- 'O'
    data_in(71 downto 64)   <= "01010000"; -- 'P'
    data_in(63 downto 56)   <= "01010001"; -- 'Q'
    data_in(55 downto 48)   <= "01010010"; -- 'R'
    data_in(47 downto 40)   <= "01010011"; -- 'S'
    data_in(39 downto 32)   <= "01010100"; -- 'T'
    data_in(31 downto 24)   <= "01010101"; -- 'U'
    data_in(23 downto 16)   <= "01010110"; -- 'V'
    data_in(15 downto 8)    <= "01010111"; -- 'W'
    data_in(7 downto 0)     <= "01011000"; -- 'X'

    -- Wait for a while before enabling the transmitter
    wait for 0.2 us;
    
    -- Enable the transmitter
    en <= '1';
    wait for 0.5 us;
    
    -- Disable the transmitter
    en <= '0';
    
    wait;
end process stim;

end testbench;
