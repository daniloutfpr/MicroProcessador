-----test_bench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg_Bank_tb is
end Reg_Bank_tb;

architecture a_Reg_Bank_tb of Reg_Bank_tb is
  component RegisterBank is
    port(
      clock: in std_logic;
      reset: in std_logic;
      wr_en: in std_logic;
      data_in: in unsigned(15 downto 0);
      reg_sel_a: in unsigned(3 downto 0);
      reg_sel_b: in unsigned(3 downto 0);
      data_out_a: out unsigned(15 downto 0);
      data_out_b: out unsigned(15 downto 0)
    );
  end component;

  signal s_clock : std_logic := '0';
  signal s_reset : std_logic := '1';
  signal s_wr_en : std_logic := '0';
  signal s_data_in : unsigned(15 downto 0) := (others => '0');
  signal s_reg_sel_a : unsigned(3 downto 0) := (others => '0');
  signal s_reg_sel_b : unsigned(3 downto 0) := (others => '0');
  signal s_data_out_a : unsigned(15 downto 0);
  signal s_data_out_b : unsigned(15 downto 0);

begin
  uut:RegisterBank
    port map(
      clock => s_clock,
      reset => s_reset,
      wr_en => s_wr_en,
      data_in => s_data_in,
      reg_sel_a => s_reg_sel_a,
      reg_sel_b => s_reg_sel_b,
      data_out_a => s_data_out_a,
      data_out_b => s_data_out_b
    );

  stim_proc: process
  begin
    -- Reset
    s_reset <= '1';
    wait for 30 ns;
    s_reset <= '0';
    wait for 20 ns;

    -- Write R0 = 0x1234
    s_wr_en <= '1';
    s_reg_sel_a <= "0000";
    s_data_in <= x"1234";
    wait for 5 ns;  -- Setup time
    s_clock <= '1';
    wait for 20 ns;
    s_clock <= '0';
    wait for 20 ns;

    -- Write R1 = 0xABCD
    s_reg_sel_a <= "0001";
    s_data_in <= x"ABCD";
    wait for 5 ns;  -- Setup time
    s_clock <= '1';
    wait for 20 ns;
    s_clock <= '0';
    wait for 20 ns;
    
    -- Write R2 = 0x5678
    s_reg_sel_a <= "0010";
    s_data_in <= x"5678";
    wait for 5 ns;  -- Setup time
    s_clock <= '1';
    wait for 20 ns;
    s_clock <= '0';
    wait for 20 ns;

    -- Disable write
    s_wr_en <= '0';

    -- Read R0 (A) and R1 (B)
    s_reg_sel_a <= "0000";
    s_reg_sel_b <= "0001";
    wait for 30 ns;

    -- Read R1 (A) and R2 (B)
    s_reg_sel_a <= "0001";
    s_reg_sel_b <= "0010";
    wait for 30 ns;

    -- Read same register (R0 on both)
    s_reg_sel_a <= "0000";
    s_reg_sel_b <= "0000";
    wait for 30 ns;

    -- Assert reset and check clear
    s_reset <= '1';
    wait for 25 ns;
    s_reset <= '0';
    wait for 25 ns;

    -- Verify cleared (R0, R1)
    s_reg_sel_a <= "0000";
    s_reg_sel_b <= "0001";
    wait for 40 ns;

    wait;
  end process;

end architecture a_Reg_Bank_tb;

