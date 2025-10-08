--8 bits register
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Register is
  port(
    clock: in std_logic;
    reset: in std_logic;
    wr_en: in std_logic;
    data_in: in unsigned(7 downto 0);
    data_out: out unsigned(7 downto 0)
  );
  end entity;

architecture a_register of Register is
  signal register: unsigned(8 downto 0);
begin
  process(clock, reset)
  begin
    if reset='1' then
      register <= "00000000";
    elsif rising_edge(clock) then
      if wr_en='1' then
        register <= data_in;
      end if;
    end if;
  end process;

  data_out <= register;
end architecture;