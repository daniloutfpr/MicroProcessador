-- Register bank with 9 registers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterBank is
  port(
    clock: in std_logic;
    reset: in std_logic;
    wr_en: in std_logic;
    data_in: in unsigned(14 downto 0);
    reg_sel_a: in unsigned(3 downto 0); -- register a selection (read)
    reg_sel_b: in unsigned(3 downto 0); -- register b selection (read)
    wr_addr: in unsigned(3 downto 0); --wr register selection (write) 
    data_out_a: out unsigned(14 downto 0);
    data_out_b: out unsigned(14 downto 0)
  );
end entity;

architecture a_register_bank of RegisterBank is
  -- Component declaration
  component Register16bit is
    port(
      clock: in std_logic;
      reset: in std_logic;
      wr_en: in std_logic;
      data_in: in unsigned(14 downto 0);
      data_out: out unsigned(14 downto 0)
    );
  end component;

  -- Internal signals for register outputs
  type reg_array is array (0 to 8) of unsigned(14 downto 0); -- Declares the register array (9 regs with 16 bits)
  signal reg_outputs: reg_array;
  signal wr_en_array: std_logic_vector(0 to 8);

begin

  -- Combinational write-enable decoder
  process(wr_en, wr_addr)
  begin
    wr_en_array <= (others => '0');
    if wr_en = '1' and to_integer(wr_addr) <= 8 then  -- If bank write-enable and address exists
      wr_en_array(to_integer(wr_addr)) <= '1';  -- Enables writing for selected register
    end if;
  end process;

  -- Instantiate 9 registers
  gen_registers: for i in 0 to 8 generate -- Loop for generating 9 instances of registers
    reg_inst: Register16bit -- Types the instances as Register16bits
      port map(
        clock => clock,
        reset => reset,
        wr_en => wr_en_array(i),
        data_in => data_in,
        data_out => reg_outputs(i)
      );
  end generate;
  
  -- Multiplexers to select outputs
  -- Gets the output data stored in the register if the address exists
  data_out_a <= reg_outputs(to_integer(reg_sel_a)) when to_integer(reg_sel_a) < 9 else (others => '0');

  data_out_b <= reg_outputs(to_integer(reg_sel_b)) when to_integer(reg_sel_b) < 9 else (others => '0');

end architecture;