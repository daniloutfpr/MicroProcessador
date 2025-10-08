-- Register bank with 9 registers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterBank is
  port(
    clock: in std_logic;
    reset: in std_logic;
    wr_en: in std_logic_vector(8 downto 0); -- write enable for each register
    data_in: in unsigned(7 downto 0);
    reg_sel: in unsigned(3 downto 0); -- register select for reading
    data_out: out unsigned(7 downto 0)
  );
  end entity;

architecture a_register_bank of RegisterBank is
  -- Component declaration
  component Register is
    port(
      clock: in std_logic;
      reset: in std_logic;
      wr_en: in std_logic;
      data_in: in unsigned(7 downto 0);
      data_out: out unsigned(7 downto 0)
    );
  end component;

 -- Internal signals for register outputs
  type reg_array is array (0 to 8) of unsigned(8 downto 0);
  signal reg_outputs: reg_array;

  -- Instantiate 9 registers
  gen_registers: for i in 0 to 8 generate
    reg_inst: Register
      port map(
        clock => clock,
        reset => reset,
        wr_en => wr_en(i),
        data_in => data_in,
        data_out => reg_outputs(i)
      );
  end generate;
  
  -- Multiplexer to select output
  data_out <= reg_outputs(to_integer(reg_sel)) when to_integer(reg_sel) < 9 else (others => '0');
  
end architecture;