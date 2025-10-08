-- Register bank with 9 registers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterBank is
  port(
    clock: in std_logic;
    reset: in std_logic;
    wr_en: in std_logic;
    data_in: in unsigned(15 downto 0);
    reg_sel_a: in unsigned(3 downto 0); -- register a selection
    reg_sel_b: in unsigned(3 downto 0); -- register b selection
    data_out_a: out unsigned(15 downto 0)
    data_out_b: out unsigned(15 downto 0)
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
  type reg_array is array (0 to 8) of unsigned(15 downto 0);
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
  
  -- Multiplexers to select outputs
  data_out_a <= reg_outputs(to_integer(reg_sel_a)) when to_integer(reg_sel_a) < 9 else (others => '0');

  data_out_b <= reg_outputs(to_integer(reg_sel_b)) when to_integer(reg_sel_b) < 9 else (others => '0');

  
end architecture;