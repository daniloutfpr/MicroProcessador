library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port(
        clk: in std_logic;
        address: in unsigned(6 downto 0);
        data : out unsigned(14 downto 0)
    );
end entity;

architecture a_rom of rom is
-- INSTRUCTION FORMAT: Op=[14:11], Rx=[10:7], Ry=[6:3], Imm/Jmp=[6:0]
    -- Opcodes: NOP=0000, CLR=0001, MOV=0010, ADD=0011, SUB=0100, ADDI=0101
    --          JMP=0110, BLS=0111, BPL = 1000, LW = 1001, SW = 1010, OR = 1011
    
    -- LW/SW FORMAT: Op[14:11] | Rs_Base[10:7] | Rt_Data[6:3] | Ignored[2:0]

    type rom_array_type is array (0 to 127) of unsigned(14 downto 0);

    signal rom_memory : rom_array_type := (
-- ============================================================
        -- FASE 1: INICIALIZAÇÃO (Preencher RAM 1..32)
        -- ============================================================
        -- R8 = 32 (Limite)
        0  => "0001" & "1000" & "0000000", -- 0: CLR R8
        1  => "0101" & "1000" & "0100000", -- 1: ADDI R8, 32
        
        -- R1 = 1 (Contador)
        2  => "0001" & "0001" & "0000000", -- 2: CLR R1
        3  => "0101" & "0001" & "0000001", -- 3: ADDI R1, 1

        -- LOOP INIT (Addr 4)
        4  => "1010" & "0001" & "0001" & "000", -- 4: SW R1, (R1)
        5  => "0101" & "0001" & "0000001", -- 5: ADDI R1, 1
        6  => "0010" & "0111" & "0001" & "000", -- 6: MOV R7, R1
        7  => "0100" & "0111" & "1000" & "000", -- 7: SUB R7, R8
        
        -- BLS para LOOP INIT (Target=4). PC=8. Offset = -4
        8  => "0111" & "0000" & "1111100", -- 8: BLS -4
        9  => "0000" & "0000" & "0000000", -- 9: NOP (Delay Slot)

        -- ============================================================
        -- FASE 2: FILTROS (2, 3, 5) - USANDO ADDI DIRETO
        -- ============================================================
        10 => "0001" & "0000" & "0000000", -- 10: CLR R0

        -- --- FILTRO DO 2 ---
        11 => "0001" & "0010" & "0000000", -- 11: CLR R2
        12 => "0101" & "0010" & "0000100", -- 12: ADDI R2, 4
        -- (Removido R9 Init)

        -- LOOP CHECK 2 (Addr 13)
        13 => "0010" & "0111" & "0010" & "000", -- 13: MOV R7, R2
        14 => "0100" & "0111" & "1000" & "000", -- 14: SUB R7, R8
        
        -- BLS para APAGAR (Target=19). PC=15. Offset = +4
        15 => "0111" & "0000" & "0000100", -- 15: BLS +4
        16 => "0000" & "0000" & "0000000", -- 16: NOP
        
        -- JMP para FILTRO 3 (Target=23). Se falhou BLS, acabou este filtro.
        17 => "0110" & "0000" & "0010111", -- 17: JMP 23
        18 => "0000" & "0000" & "0000000", -- 18: NOP

        -- APAGAR 2 (Addr 19)
        19 => "1010" & "0000" & "0010" & "000", -- 19: SW R0, (R2)
        20 => "0101" & "0010" & "0000010", -- 20: ADDI R2, 2 (USANDO IMEDIATO!)
        
        -- JMP para LOOP CHECK 2 (Target=13)
        21 => "0110" & "0000" & "0001101", -- 21: JMP 13
        22 => "0000" & "0000" & "0000000", -- 22: NOP

        -- --- FILTRO DO 3 --- (Addr 23)
        23 => "0001" & "0010" & "0000000", -- 23: CLR R2
        24 => "0101" & "0010" & "0000110", -- 24: ADDI R2, 6
        -- (Removido R9 Init)

        -- LOOP CHECK 3 (Addr 25)
        25 => "0010" & "0111" & "0010" & "000", -- 25: MOV R7, R2
        26 => "0100" & "0111" & "1000" & "000", -- 26: SUB R7, R8
        
        -- BLS para APAGAR (Target=31). PC=27. Offset = +4
        27 => "0111" & "0000" & "0000100", -- 27: BLS +4
        28 => "0000" & "0000" & "0000000", -- 28: NOP
        
        -- JMP para FILTRO 5 (Target=35)
        29 => "0110" & "0000" & "0100011", -- 29: JMP 35
        30 => "0000" & "0000" & "0000000", -- 30: NOP

        -- APAGAR 3 (Addr 31)
        31 => "1010" & "0000" & "0010" & "000", -- 31: SW R0, (R2)
        32 => "0101" & "0010" & "0000011", -- 32: ADDI R2, 3 (USANDO IMEDIATO!)
        
        -- JMP para LOOP CHECK 3 (Target=25)
        33 => "0110" & "0000" & "0011001", -- 33: JMP 25
        34 => "0000" & "0000" & "0000000", -- 34: NOP

        -- --- FILTRO DO 5 --- (Addr 35)
        35 => "0001" & "0010" & "0000000", -- 35: CLR R2
        36 => "0101" & "0010" & "0001010", -- 36: ADDI R2, 10
        -- (Removido R9 Init)

        -- LOOP CHECK 5 (Addr 37)
        37 => "0010" & "0111" & "0010" & "000", -- 37: MOV R7, R2
        38 => "0100" & "0111" & "1000" & "000", -- 38: SUB R7, R8
        
        -- BLS para APAGAR (Target=43). PC=39. Offset = +4
        39 => "0111" & "0000" & "0000100", -- 39: BLS +4
        40 => "0000" & "0000" & "0000000", -- 40: NOP
        
        -- JMP para LEITURA (Target=47)
        41 => "0110" & "0000" & "0101111", -- 41: JMP 47
        42 => "0000" & "0000" & "0000000", -- 42: NOP

        -- APAGAR 5 (Addr 43)
        43 => "1010" & "0000" & "0010" & "000", -- 43: SW R0, (R2)
        44 => "0101" & "0010" & "0000101", -- 44: ADDI R2, 5 (USANDO IMEDIATO!)
        
        -- JMP para LOOP CHECK 5 (Target=37)
        45 => "0110" & "0000" & "0100101", -- 45: JMP 37
        46 => "0000" & "0000" & "0000000", -- 46: NOP

-- ============================================================
        -- FASE 3: LEITURA E DISPLAY (SALVANDO EM R6)
        -- ============================================================
        -- R1 = 2 (Endereço inicial)
        -- R6 = REGISTRADOR DE VIZUALIZAÇÃO (Procure por ele no Waveform)
        
        -- (Addr 47)
        47 => "0001" & "0001" & "0000000", -- 47: CLR R1
        48 => "0101" & "0001" & "0000010", -- 48: ADDI R1, 2

        -- LOOP LEITURA (Addr 49)
        -- 1. Leitura da RAM para R4
        49 => "1001" & "0100" & "0001" & "000", -- 49: LW R4, (R1)
        
        -- 2. NOP de Estabilização (Para garantir a escrita em R4)
        50 => "0000" & "0000" & "0000000", -- 50: NOP
        
        -- 3. MOV R6, R4 (SALVA EM R6)
        -- Op=MOV(0010) | Rx=R6(0110) | Ry=R4(0100)
        -- R6 ficará com o valor estável até a próxima leitura
        51 => "0010" & "0110" & "0100" & "000", -- 51: MOV R6, R4
        
        -- 4. Incremento e Controle de Loop
        52 => "0101" & "0001" & "0000001", -- 52: ADDI R1, 1
        53 => "0010" & "0111" & "0001" & "000", -- 53: MOV R7, R1
        54 => "0100" & "0111" & "1000" & "000", -- 54: SUB R7, R8

        -- BLS para LOOP LEITURA (Target=49). PC=55. Offset = 49-55 = -6
        55 => "0111" & "0000" & "1111010", -- 55: BLS -6
        56 => "0000" & "0000" & "0000000", -- 56: NOP (Delay Slot)

        -- FIM
        57 => "0110" & "0000" & "0111001", -- 57: JMP 57 (Halt)
        58 => "0000" & "0000" & "0000000", -- 58: NOP (Delay Slot)
        
        -- The rest of the memory is zero (NOP)
        others => (others => '0')
    );

begin
    -- Syncronous ROM's logic
    process(clk)
    begin
        if rising_edge(clk) then
            data <= rom_memory(to_integer(address));
        end if;
    end process;
end architecture a_rom;