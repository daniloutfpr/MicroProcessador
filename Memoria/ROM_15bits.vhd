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

-- FORMATO: Op=[14:11], Rx=[10:7], Ry=[6:3], Imm/Jmp=[6:0]
    -- Opcodes: CLR=0001, MOV=0010, ADD=0011, SUB=0100, ADDI=0101
    --          JMP=0110, BLS=0111

    type rom_array_type is array (0 to 127) of unsigned(14 downto 0);

    signal rom_memory : rom_array_type := (
       -- A. Carrega R3 (o registrador 3) com o valor 0
        -- 0: CLR R3 (Op=0001, Rx=0011)
        0  => "0001" & "0011" & "0000000",

        -- B. Carrega R4 com 0
        -- 1: CLR R4 (Op=0001, Rx=0100)
        1  => "0001" & "0100" & "0000000",

        -- Setup (para Passo E): Carrega R8 com 29
        -- (A condição "Se R3 < 30" é implementada como "Se R3 <= 29")
        -- 2: CLR R8 (Op=0001, Rx=1000)
        2  => "0001" & "1000" & "0000000",
        -- 3: ADDI R8, 29 (Op=0101, Rx=1000, Imm=0011101)
        3  => "0101" & "1000" & "00111001",

        -- C. Soma R3 com R4 e guarda em R4
        -- (Este é o início do loop, no endereço 4)
        -- 4: LOOP: ADD R4, R3 (Op=0011, Rx=0100, Ry=0011)
        4  => "0011" & "0100" & "0011" & "000",

        -- D. Soma 1 em R3
        -- 5: ADDI R3, 1 (Op=0101, Rx=0011, Imm=0000001)
        5  => "0101" & "0011" & "0000001",

        -- E. Se R3 < 30 (R3 <= 29) salta para a instrução do passo C (Addr 4)
        -- Usamos R7 como temporário para R3 - R8
        -- 6: MOV R7, R3 (Op=0010, Rx=0111, Ry=0011) 
        6  => "0010" & "0111" & "0011" & "000",
        -- 7: SUB R7, R8 (Op=0100, Rx=0111, Ry=1000) -- R7 = R3-R8. SETA FLAGS (C, Z)
        7  => "0100" & "0111" & "1000" & "000",
        -- 8: BLS -4 (Op=0111, Offset=1111100) -- Salta p/ 4 (PC=8, 8-4=4)
        8  => "0111" & "0000" & "1111100",

        -- F. Copia valor de R4 para R5
        -- (Só executa quando o loop falha, ou seja, R3 = 30)
        -- 9: MOV R5, R4 (Op=0010, Rx=0101, Ry=0100)
        9  => "0010" & "0101" & "0100" & "000",

        -- Fim. Trava o processador.
        -- 10: FIM: JMP 10 (Op=0110, Addr=0001010)
        10 => "0110" & "0000" & "0001010",

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