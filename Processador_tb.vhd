library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is
    
    -- 1. Componente: O seu processador inteiro
    -- O NOME DO COMPONENTE FOI CORRIGIDO PARA BATER COM A ENTIDADE
    component processor is  
        port( 
            clock: in std_logic;
            reset: in std_logic
        );
    end component;

    -- 2. Sinais do Testbench
    constant period_time : time := 100 ns;
    signal finished : std_logic := '0';
    signal tb_clk, tb_rst : std_logic; -- Renomeado para evitar conflito
    
begin
    -- 3. Instância do Processador (Unidade Sob Teste)
    
    uut: processor port map ( 
        clock => tb_clk,  
        reset => tb_rst
    );

    -- 4. Processo de Geração de Clock
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

    -- 5. Processo de Geração de Reset
    reset_global: process
    begin
        tb_rst <= '1';
        wait for period_time*2; -- Segura o reset por 2 ciclos
        tb_rst <= '0';
        wait;
    end process reset_global;

    -- 6. Processo de Duração da Simulação
    sim_time_proc: process
    begin
        wait for 50 us; 
        finished <= '1';
        wait;
    end process sim_time_proc;
    
end architecture;