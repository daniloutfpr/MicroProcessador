library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Processor Store Word (register for flags storage)
entity psw is
  port(
    clock: in std_logic;
    reset: in std_logic;
    wr_en: in std_logic;
    data_in: in unsigned(2 downto 0);

    -- Flags
    isNegative: out std_logic;
    carry: out std_logic;
    isZero: out std_logic;
  );
  end entity;

architecture a_psw of psw is
  signal flag: unsigned(2 downto 0) := (others => '0');
begin
  process(reset, clock)
  begin
    if reset = '1'
      flag <= (others => '0');
    elsif rising_edge(clock) then
      if wr_en = '1' then
        flag <= data_in;
      end if;
    end if;
  end process;

  isZero <=flag(2); 
  isNegative <= flag(1);  
  carry <= flag(0);       

end architecture;
