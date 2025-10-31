--8 bits register
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Declares the Register16bit entity
entity Register16bit is
  port(
    clock: in std_logic;
    reset: in std_logic;
    wr_en: in std_logic;
    data_in: in unsigned(14 downto 0);
    data_out: out unsigned(14 downto 0)
  );
  end entity;

architecture a_register of Register16bit is
  signal s_register: unsigned(14 downto 0) := (others => '0'); -- Initialize to zero
begin
  process(clock)  -- Executes in the clock variation
begin
  if rising_edge(clock) then  
    if reset = '1' then -- Resets the reg
      s_register <= (others => '0');
    elsif wr_en = '1' then
      s_register <= data_in;  -- Writes in the reg
    end if;
  end if;
end process;
data_out <= s_register;  -- Output
end architecture;