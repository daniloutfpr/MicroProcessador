library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is
    
    component processor is  
        port( 
            clock: in std_logic;
            reset: in std_logic;
            exception: out std_logic
        );
    end component;

    --  Testbench signals
    constant period_time : time := 100 ns; -- 10MHz clcok
    signal finished : std_logic := '0';
    signal tb_clk, tb_rst : std_logic;
    signal s_exception: std_logic;
    
begin
    -- Processor tested
    uut: processor port map ( 
        clock => tb_clk,  
        reset => tb_rst,
        exception => s_exception
    );

    -- Process for clock generation
    clk_proc: process
    begin
        while finished = '0' loop
            tb_clk <= '0';
            wait for period_time/2;
            tb_clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;

    -- Process for reset generation
    reset_global: process
    begin
        tb_rst <= '1';
        wait for period_time*2; -- holds reset for 2 clock cicles
        tb_rst <= '0';
        wait;
    end process reset_global;

    -- Simulation duration process
    sim_time_proc: process
    begin
        wait for 200 us; 
        finished <= '1';
        wait;
    end process sim_time_proc;

end architecture;