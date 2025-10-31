-- Program Counter entity (basically a data register)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ProgramCounter is
  port(
    clock: in std_logic;
    reset: in std_logic;
    wr_en: in std_logic;
    instr_in: in unsigned(6 downto 0); 
    instr_out: out unsigned(6 downto 0)
  );
end entity;

architecture a_ProgramCounter of ProgramCounter is
  signal s_data: unsigned(6 downto 0);

begin
  process(clock)  -- Executes in the clock variation
  begin
    if rising_edge(clock) then  
      if reset = '1' then -- Resets the reg
        s_data <= (others => '0');
      elsif wr_en = '1' then
        s_data <= instr_in;  -- Writes in the reg
      end if;
    end if;
  end process;
  instr_out <= s_data;  -- Output
end architecture;
