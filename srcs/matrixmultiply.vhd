library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.myPackage.all;
use work.fixed_pkg.all;


entity matrixmultiply is
port(
    clk: in std_logic;
    en : in std_logic;
    matrix_A: in matrix;
    matrix_B: in matrix;
    matrix_C : out matrix;
    done : out std_logic);
end matrixmultiply;

architecture behavioral of matrixmultiply is
  signal i, j, k, iHold, jHold: integer := 0;
  signal K_TC, J_TC, I_TC, over, ins: std_logic := '0';
  signal rst, calc : std_logic := '0';
  signal sum : sfixed(9 downto -6) := (others => '0');
  signal C: matrix := (others => (others => (to_sfixed(0.0, 9, -6))));

  type statetype is (idle, clear, calculate, insert, finish);
  signal cs, ns : statetype := idle;

begin
------------------ THREE COUNTERS I J K --------------------------
  counter_K : process(clk, rst, calc, k)
  begin
    
    if rst = '1' then
      k <= 0;
      K_TC <= '0';
    end if;
    
    if rising_edge(clk) then
    if calc = '1' then
      k <= k+1; 
      if k = 1 then
        k <= 0;
      end if;       
    end if;
    end if;
    if k = 1 then
      K_TC <= '1';
    else
      K_TC <= '0';
    end if;      

  end process counter_K;

  counter_J : process(clk, rst, k_TC, j, k)
  begin

    if rst = '1' then
      j <= 0;
      J_TC <= '0';
    end if;

    if rising_edge(clk) then
    if k_TC = '1' then
      j <= j+1;    
      if j = 1 then
        j <= 0;
      end if;       
    end if;
    end if;
    if j = 1 and k = 1 then
      J_TC <= '1';
    else
      J_TC <= '0';
    end if;   

  end process counter_J;

  counter_I : process(clk, rst, J_TC, i, j)
  begin

    if rst = '1' then
      i <= 0;
      I_TC <= '0';
    end if;

    if rising_edge(clk) then
    if J_TC = '1' then
      i <= i+1;  
      if i = 1 then
        i <= 0;
      end if;       
    end if;
    end if;
    if i = 1 and j = 1 and k = 1 then
      I_TC <= '1';
    else
      I_TC <= '0';
    end if;   

  end process counter_I;

------------------ CALCULATION ------------------

  sum_reg : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sum <= (others => '0');
      elsif calc = '1' then
        if k = 0 then
          sum <= fixedmultiply(matrix_A(i)(k), matrix_B(k)(j));  -- Start new sum for a new C(i, j)
        else
          sum <= resize(sum + fixedmultiply(matrix_A(i)(k), matrix_B(k)(j)), 9, -6);
        end if;
      end if;
    end if;
  end process sum_reg;

  C_reg : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        C <= (others => (others => to_sfixed(0.0, 9, -6)));
      elsif ins = '1' then
        C(iHold)(jHold) <= sum;
      end if;
    end if;
  end process C_reg;
  
  holdUpdate: process(clk)
  begin
    if rising_edge(clk) then
      if K_TC = '1' then
        iHold <= i;
        jHold <= j;
      end if;
    end if;
  end process;

  TCUpdate: process(clk)
  begin
    if rising_edge(clk) then
      over <= '0';
      if I_TC = '1' then
        over <= '1';
      end if;
    end if;
  end process;
  
  matrix_C <= C;

------------------FSM-----------------------

  stateupdate: process(clk)
  begin
    if rising_edge(clk) then
      CS <= NS;
    end if;
  end process stateupdate;

  nextstatelogic: process(CS, en, I_TC, K_TC)
  begin
    NS <= CS;
    rst <= '0';
    calc <= '0';
    done <= '0';
    ins <= '0';
    
    case CS is
      when idle =>
        if en = '1' then
          NS <= clear;
        end if;
      when clear => 
        rst <= '1';
        ns <= calculate;
      when calculate =>
        calc <= '1';
        if K_TC = '1' then
          NS <= insert;
        end if;
      when insert =>
        ins <= '1';
        if over = '1' then
          ns <= finish;
        else
          ns <= calculate;
        end if;        
      when finish =>
        done <= '1';
        NS <= idle;
      when others => ns <= idle;
    end case;
  end process nextstatelogic;

end behavioral;