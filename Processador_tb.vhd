library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is
    
    -- 1. Componente: O seu processador inteiro
    component processor is  
        port( 
            clock: in std_logic;
            reset: in std_logic
        );
    end component;

    -- 2. Sinais do Testbench
    constant period_time : time := 100 ns; -- Clock de 10MHz
    signal finished : std_logic := '0';
    signal tb_clk, tb_rst : std_logic;
    
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
        -- Aumentado para 60us (600 ciclos @ 10MHz) para garantir
        -- que o loop BLS (~450 ciclos) e o teste BPL (~30 ciclos)
        -- tenham tempo de sobra para rodar.
        wait for 60 us; 
        finished <= '1';
        wait;
    end process sim_time_proc;


    -- =========================================================================
    -- GUIA DE VERIFICAÇÃO PARA SEU WAVEFORM (Simulação)
    -- =========================================================================
    --
    -- Para testar, adicione estes sinais do seu 'processor' ao waveform:
    --
    -- 1. Sinais Principais:
    --    - tb_rst
    --    - tb_clk
    --    - uut/s_pc_out         (O contador de programa)
    --    - uut/s_opcode_in      (O opcode indo para a UC)
    --    - uut/s_ri_out         (A instrução completa)
    --
    -- 2. Sinais das Novas Funcionalidades (Flags e Desvios):
    --    - uut/s_psw_wr_en      (Sinal da UC que habilita escrita nas flags)
    --    - uut/s_pc_sel         (Sinal da UC que seleciona o desvio)
    --    - uut/inst_PSW/isNegative (Flag N lida do PSW)
    --    - uut/inst_PSW/isZero     (Flag Z lida do PSW)
    --    - uut/inst_PSW/carry      (Flag C lida do PSW)
    --    - uut/inst_UC/take_branch (Sinal interno da UC, se visível)
    --
    --
    -- O QUE OBSERVAR NO TESTE 'BLS' (Loop, Addr 0-9):
    --
    -- A. Observe 's_pc_out'. Ele deve executar o loop 4 -> 5 -> 6 -> 7 -> 8 -> 4.
    -- B. Isso deve se repetir 30 vezes (enquanto R3 de 0 a 29).
    -- C. No 's_pc_out' = 7 (SUB R7, R8):
    --    - 's_psw_wr_en' deve ir para '1'.
    --    - As flags no PSW ('isNegative', 'isZero', 'carry') serão atualizadas.
    -- D. No 's_pc_out' = 8 (BLS -4):
    --    - 's_psw_wr_en' deve ser '0' (BLS não atualiza flags).
    --    - 's_pc_sel' deve ser '1' (pois C=0 ou Z=1 será verdadeiro), fazendo o PC pular para 4.
    -- E. QUANDO O LOOP TERMINAR (R3 = 30):
    --    - No 's_pc_out' = 7 (SUB 30, 29): O resultado é +1. As flags serão N=0, Z=0, C=1.
    --    - No 's_pc_out' = 8 (BLS -4): A condição 'C=0 or Z=1' será '0 or 0' = FALSO.
    --    - 's_pc_sel' deve agora ser '0'.
    --    - O 's_pc_out' deve ir para 9 (PROVA QUE O BLS FUNCIONOU).
    --
    --
    -- O QUE OBSERVAR NO TESTE 'BPL' (Falha no Salto, Addr 10-18):
    --
    -- A. O 's_pc_out' deve agora estar em 10, 11, 12, 13...
    -- B. QUANDO 's_pc_out' = 14 (SUB R1, R2, que é 3-5 = -2):
    --    - A ULA deve gerar N=1.
    --    - 's_psw_wr_en' deve ir para '1'.
    --    - No próximo ciclo, 'uut/inst_PSW/isNegative' (a flag N lida) deve ser '1'.
    -- C. QUANDO 's_pc_out' = 15 (BPL +2, opcode "1000"):
    --    - A UC lerá 'isNegative' = '1'.
    --    - A condição do BPL ('N=0') é FALSA.
    --    - 's_pc_sel' deve ser '0'.
    -- D. O 's_pc_out' deve ir para 16 (MOV R6, R1). (***ISSO PROVA QUE O BPL FUNCIONOU***).
    -- E. O 's_pc_out' NÃO DEVE PULAR para 17.
    -- F. O 's_pc_out' eventualmente chegará em 18 e ficará "travado" (JMP 18).
    --
    -- =========================================================================
    
end architecture;