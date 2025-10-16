library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uc is
end entity;

architecture a_tb_uc of tb_uc is
    -- Component declaration
    component UC
        port(
            clock: in std_logic;
            reset: in std_logic;
            pc_out: out unsigned(6 downto 0);
            instr_out: out unsigned(14 downto 0)
        );
    end component;

    -- Test signals
    signal clock_tb: std_logic := '0';
    signal reset_tb: std_logic := '0';
    signal pc_out_tb: unsigned(6 downto 0);
    signal instr_out_tb: unsigned(14 downto 0);

    -- Clock period
    constant clk_period: time := 10 ns;

begin
    -- DUT (Device Under Test) instantiation
    dut: UC
        port map(
            clock => clock_tb,
            reset => reset_tb,
            pc_out => pc_out_tb,
            instr_out => instr_out_tb
        );

    -- Clock generation
    clk_process: process
    begin
        clock_tb <= '0';
        wait for clk_period/2;
        clock_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Test stimulus
    stimulus: process
    begin
        report "Starting UC testbench simulation";
        
        -- Reset
        report "Applying reset";
        reset_tb <= '1';
        wait for 50 ns;
        reset_tb <= '0';
        report "Reset released";
        
        -- Wait for initialization
        wait for 50 ns;
        report "After initialization - PC: " & integer'image(to_integer(pc_out_tb)) & 
               ", Instruction: " & integer'image(to_integer(instr_out_tb));
        
        -- Let it run
        wait for 100 ns;
        report "PC: " & integer'image(to_integer(pc_out_tb)) & 
               ", Instruction: " & integer'image(to_integer(instr_out_tb));
        
        wait for 100 ns;
        report "PC: " & integer'image(to_integer(pc_out_tb)) & 
               ", Instruction: " & integer'image(to_integer(instr_out_tb));
        
        wait for 100 ns;
        report "PC: " & integer'image(to_integer(pc_out_tb)) & 
               ", Instruction: " & integer'image(to_integer(instr_out_tb));
        
        wait for 200 ns;
        report "Final - PC: " & integer'image(to_integer(pc_out_tb)) & 
               ", Instruction: " & integer'image(to_integer(instr_out_tb));
        
        -- End simulation
        report "Testbench completed";
        wait;
    end process;

end architecture;