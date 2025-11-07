library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port(
        clk: in std_logic;
        adrees: in unsigned(6 downto 0);
        data : out unsigned(14 downto 0)
    );
end entity;

architecture a_rom of rom is

    -- FORMATO DO NOSSO PROCESSADOR (Hardware):
    -- Op=[14:11], Rx=[10:7], Ry=[6:3], Imm/Jmp=[6:0]

    -- Opcodes: CLR=0001, MOV=0010, ADD=0011, SUB=0100, ADDI=0101, JMP=0110
    
    -- Endereços de Registrador (4 bits):
    -- R0=0000, R1=0001, R2=0010, R3=0011, R4=0100, R5=0101, R6=0110...

    type rom_array_type is array (0 to 127) of unsigned(14 downto 0);

    signal rom_memory : rom_array_type := (
       -- A. Carrega R3 com 0
        -- 0: CLR R3 (Op=0001, Rx=0011)
        0  => "0001" & "0011" & "0000000",

        -- B. Carrega R4 com 0
        -- 1: CLR R4 (Op=0001, Rx=0100)
        1  => "0001" & "0100" & "0000000",

        -- Setup: Carrega R8 com 29 (para comparar com R3)
        -- 2: CLR R8 (Op=0001, Rx=1000)
        2  => "0001" & "1000" & "0000000",
        -- 3: ADDI R8, 29 (Op=0101, Rx=1000, Imm=0011101)
        3  => "0101" & "1000" & "0000011",

        -- C. Soma R3 com R4 e guarda em R4
        -- 4: LOOP: ADD R4, R3 (Op=0011, Rx=0100, Ry=0011)
        4  => "0011" & "0100" & "0011" & "000",

        -- D. Soma 1 em R3
        -- 5: ADDI R3, 1 (Op=0101, Rx=0011, Imm=0000001)
        5  => "0101" & "0011" & "0000001",

        -- E. Compara R3 com R8 (R3 - 29) e salta se R3 <= 29
        -- 6: MOV R7, R3 (Op=0010, Rx=0111, Ry=0011) -- 
        6  => "0010" & "0111" & "0011" & "000",
        -- 7: SUB R7, R8 (Op=0100, Rx=0111, Ry=1000) -- R7 = R3-R8. SETA FLAGS
        7  => "0100" & "0111" & "1000" & "000",
        -- 8: BLS -4 (Op=0111, Offset=1111100) -- Salta p/ 4 (8-4=4)
        8  => "0111" & "0000" & "1111100",

        -- F. Copia valor de R4 para R5 (só executa quando R3=30)
        -- 9: MOV R5, R4 (Op=0010, Rx=0101, Ry=0100)
        9  => "0010" & "0101" & "0100" & "000",

        -- Vamos calcular 3 - 5 = -2 (N=1)
        10 => "0001" & "0001" & "0000000", -- 10: CLR R1
        11 => "0001" & "0010" & "0000000", -- 11: CLR R2
        12 => "0101" & "0001" & "0000011", -- 12: ADDI R1, 3 (R1=3)
        13 => "0101" & "0010" & "0000101", -- 13: ADDI R2, 5 (R2=5)
        
        -- SUB R1, R2 (R1 = 3-5 = -2). Flags: N=1, Z=0
        -- A UC deve ativar 'psw_wr_en' aqui.
        14 => "0100" & "0001" & "0010" & "000", -- 14: SUB R1, R2. (Define N=1)
        
        -- BPL +2. Como N=1, o desvio NÃO DEVE ser tomado.
        -- A UC deve ler N=1 do PSW e 'take_branch' deve ser '0'.
        15 => "1000" & "0000" & "0000010", -- 15: BPL +2 (Offset=2)

        -- Esta instrução DEVE EXECUTAR (pois o salto falhou)
        -- Copia R1 (que contém -2) para R6.
        16 => "0010" & "0110" & "0001" & "000", -- 16: MOV R6, R1

        -- Esta instrução é o alvo do salto (que não deve ocorrer)
        17 => "0001" & "0111" & "0000000", -- 17: CLR R7 

    -- Vamos calcular 5 - 3 = +2 (N=0)
        18 => "0001" & "0001" & "0000000", -- 18: CLR R1
        19 => "0001" & "0010" & "0000000", -- 19: CLR R2
        20 => "0101" & "0001" & "0000101", -- 20: ADDI R1, 5 (R1=5)
        21 => "0101" & "0010" & "0000011", -- 21: ADDI R2, 3 (R2=3)
        
        -- SUB R1, R2 (R1 = 5-3 = +2). Flags: N=0, Z=0
        -- A UC deve ativar 'psw_wr_en' aqui.
        22 => "0100" & "0001" & "0010" & "000", -- 22: SUB R1, R2. (Define N=0)
        
        -- BPL +2. Como N=0, o desvio DEVE ser tomado.
        -- A UC deve ler N=0 e 'take_branch' deve ser '1'.
        -- O PC deve saltar de 23 para 23 + 2 = 25.
        23 => "1000" & "0000" & "0000010", -- 23: BPL +2 (Offset=2)

        -- === ESTA INSTRUÇÃO DEVE SER PULADA ===
        -- Se o PC executar 24, o teste FALHOU.
        24 => "0001" & "0111" & "0000000", -- 24: CLR R7 (R7=0)

        -- === ESTA INSTRUÇÃO É O ALVO DO SALTO ===
        -- O PC deve chegar aqui (em 25) vindo direto do 23.
        25 => "0001" & "0101" & "0000000", -- 25: CLR R5 (R5=0)

        -- Fim. Trava o processador.
        26 => "0110" & "0000" & "0011010", -- 26: FIM: JMP 26 (Addr=26)

        -- Restante da memória é zero (NOP)
        others => (others => '0')
    );

begin
    -- Lógica de Leitura da ROM Síncrona
    process(clk)
    begin
        if rising_edge(clk) then
            data <= rom_memory(to_integer(adrees));
        end if;
    end process;
end architecture a_rom;