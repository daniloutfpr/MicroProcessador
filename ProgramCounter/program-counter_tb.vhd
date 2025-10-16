library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_PCCounterTop is
end entity;

architecture a_tb_PCCounterTop of tb_PCCounterTop is
  component ProgramCounter is
    port(
      clock: in std_logic;
      reset: in std_logic;
      wr_en: in std_logic;
      instr_in: in unsigned(14 downto 0); 
      instr_out: out unsigned(14 downto 0)
    );
  end component;
  
  component SumEntity is
    port(
      data_in: in unsigned(14 downto 0); 
      data_out: out unsigned(14 downto 0)
    );
  end component;
  
  -- Test signals
  signal s_clock: std_logic := '0';
  signal s_reset: std_logic := '0';
  signal s_wr_en: std_logic := '0';
  signal s_pc_out: unsigned(14 downto 0);
  signal s_sum_out: unsigned(14 downto 0);
  
  -- Clock period
  constant c_clock_period: time := 10 ns;

begin
  -- Connect ProgramCounter and SumEntity directly
  pc: ProgramCounter port map(
    clock => s_clock,
    reset => s_reset,
    wr_en => s_wr_en,
    instr_in => s_sum_out,
    instr_out => s_pc_out
  );
  
  sum: SumEntity port map(
    data_in => s_pc_out,
    data_out => s_sum_out
  );
  
  -- Clock generation
  s_clock <= not s_clock after c_clock_period/2;
  
  -- Test process
  process
  begin
    -- Test 1: Reset functionality
    s_reset <= '1';
    s_wr_en <= '0';
    wait for 20 ns;
    
    -- Test 2: Release reset, enable write
    s_reset <= '0';
    s_wr_en <= '1';
    wait for 10 ns;
    
    -- Test 3: Check auto-increment (should be 1 after first clock)
    wait for 10 ns;
    assert s_pc_out = "000000000000001" 
      report "First increment failed" severity error;
    
    -- Test 4: Check continuous increment
    wait for 10 ns;
    assert s_pc_out = "000000000000010" 
      report "Second increment failed" severity error;
    
    wait for 10 ns;
    assert s_pc_out = "000000000000011" 
      report "Third increment failed" severity error;
    
    -- Test 5: Disable write enable
    s_wr_en <= '0';
    wait for 20 ns;
    assert s_pc_out = "000000000000011" 
      report "Write disable failed" severity error;
    
    -- Test 6: Re-enable write
    s_wr_en <= '1';
    wait for 10 ns;
    assert s_pc_out = "000000000000100" 
      report "Write re-enable failed" severity error;
    
    -- Test 7: Reset during operation
    s_reset <= '1';
    wait for 10 ns;
    assert s_pc_out = "000000000000000" 
      report "Reset during operation failed" severity error;
    
    -- Test 8: Continue running
    s_reset <= '0';
    s_wr_en <= '1';
    for i in 0 to 10 loop
      wait for 10 ns;
    end loop;
    
    report "Testbench completed successfully" severity note;
    wait;
  end process;
  
end architecture;