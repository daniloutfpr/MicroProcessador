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
      reg_sel_a: in unsigned(3 downto 0); -- register a selection
      reg_sel_b: in unsigned(3 downto 0); -- register b selection
      data_out_a: out unsigned(15 downto 0);
      data_out_b: out unsigned(15 downto 0)
    );
  end component;

  signal s_clock : std_logic;
  signal s_reset : std_logic;
  signal s_wr_en : std_logic;
  signal s_data_in : unsigned(15 downto 0);
  signal s_reg_sel_a : unsigned(3 downto 0);
  signal s_reg_sel_b : unsigned(3 downto 0);
  signal s_data_out_a : unsigned(15 downto 0);
  signal s_data_out_b : unsigned(15 downto 0);

  begin
    uut:RegisterBank port map(
      clock => s_clock,
      reset => s_reset,
      wr_en => s_wr_en,
      data_in => s_data_in,
      reg_sel_a => s_reg_sel_a,
      reg_sel_b => s_reg_sel_b,
      data_out_a => s_data_out_a,
      data_out_b => s_data_out_b
    );

  process
  begin
    -- Initialize signals
    s_clock <= '0';
    s_reset <= '1';
    s_wr_en <= '0';
    s_data_in <= (others => '0');
    s_reg_sel_a <= (others => '0');
    s_reg_sel_b <= (others => '0');
    wait for 20 ns;
    
    -- Release reset
    s_reset <= '0';
    wait for 20 ns;
    
    -- Test 1: Write value 0x1234 to R0
    s_wr_en <= '1';
    s_reg_sel_a <= "0000";
    s_data_in <= x"1234";
    s_clock <= '1';
    wait for 10 ns;
    s_clock <= '0';
    wait for 10 ns;
    
    -- Test 2: Write value 0xABCD to R1
    s_reg_sel_a <= "0001";
    s_data_in <= x"ABCD";
    s_clock <= '1';
    wait for 10 ns;
    s_clock <= '0';
    wait for 10 ns;
    
    -- Test 3: Write value 0x5678 to register R2
    s_reg_sel_a <= "0010";
    s_data_in <= x"5678";
    s_clock <= '1';
    wait for 10 ns;
    s_clock <= '0';
    wait for 10 ns;
    
    -- Test 4: Disable write and read from R0
    s_wr_en <= '0';
    s_reg_sel_a <= "0000";
    s_reg_sel_b <= "0001";
    wait for 20 ns;
    
    -- Test 5: Read from R1 and R2
    s_reg_sel_a <= "0001";
    s_reg_sel_b <= "0010";
    wait for 20 ns;
    
    -- Test 6: Read from same register on both ports
    s_reg_sel_a <= "0000";
    s_reg_sel_b <= "0000";
    wait for 20 ns;
    
    -- Test 7: Test reset functionality
    s_reset <= '1';
    wait for 20 ns;
    s_reset <= '0';
    wait for 20 ns;
    
    -- Test 8: Verify registers are cleared after reset
    s_reg_sel_a <= "0000";
    s_reg_sel_b <= "0001";
    wait for 20 ns;
    
    -- End simulation
    wait;
  end process;

end architecture a_Reg_Bank_tb;

