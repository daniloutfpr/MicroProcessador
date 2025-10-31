library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PCCounterTop is
  port(
    clock:        in  std_logic;
    reset:        in  std_logic;
    wr_en:        in  std_logic;
    
    pc_sel:       in  std_logic; -- Mux (Jump or Pc+1)
    jump_addr_in: in  unsigned (6 downto 0);

    pc_out:       out unsigned (6 downto 0)
  );
end entity;

architecture a_PCCounterTop of PCCounterTop is
  component ProgramCounter is
    port(
      clock:     in  std_logic;
      reset:     in  std_logic;
      wr_en:     in  std_logic;
      instr_in:  in  unsigned(6 downto 0); 
      instr_out: out unsigned(6 downto 0)
    );
  end component;
  
  component SumEntity is
    port(
      data_in:   in  unsigned(6 downto 0); 
      data_out:  out unsigned(6 downto 0)
    );
  end component;
  
  signal s_pc_mux:  unsigned(6 downto 0); -- value of mux that goes to pc
  signal s_pc_out:  unsigned(6 downto 0);
  signal s_sum_out: unsigned(6 downto 0);
  
begin
  pc: ProgramCounter port map(
    clock     => clock,
    reset     => reset,
    wr_en     => wr_en,
    instr_in  => s_pc_mux,
    instr_out => s_pc_out
  );
  
  sum: SumEntity port map(
    data_in   => s_pc_out,
    data_out  => s_sum_out
  );

  s_pc_mux <= s_sum_out    when (pc_sel = '0') else -- pc+1
              jump_addr_in;                        -- Jump
  
  pc_out <= s_pc_out;
end architecture;