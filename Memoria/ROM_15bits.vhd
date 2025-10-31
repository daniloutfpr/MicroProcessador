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
        -- A. Carrega R3 com 5
        -- 0: CLR R3 (Op=0001, Rx=0011)
        0  => "0001" & "0011" & "0000000",
        -- 1: ADDI R3, 5 (Op=0101, Rx=0011, Imm=0000101)
        1  => "0101" & "0011" & "0000101",

        -- B. Carrega R4 com 8
        -- 2: CLR R4 (Op=0001, Rx=0100)
        2  => "0001" & "0100" & "0000000",
        -- 3: ADDI R4, 8 (Op=0101, Rx=0100, Imm=0001000)
        3  => "0101" & "0100" & "0001000",

        -- C. Soma R3 com R4 e guarda em R5 (R5 = R3 + R4)
        -- 4: MOV R5, R3 (Op=0010, Rx=0101, Ry=0011)
        4  => "0010" & "0101" & "0011" & "000",
        -- 5: ADD R5, R4 (Op=0011, Rx=0101, Ry=0100)
        5  => "0011" & "0101" & "0100" & "000",

        -- D. Subtrai 1 de R5 (R5 = R5 - R6, onde R6=1)
        -- 6: CLR R6 (Op=0001, Rx=0110)
        6  => "0001" & "0110" & "0000000",
        -- 7: ADDI R6, 1 (Op=0101, Rx=0110, Imm=0000001)
        7  => "0101" & "0110" & "0000001",
        -- 8: SUB R5, R6 (Op=0100, Rx=0101, Ry=0110)
        8  => "0100" & "0101" & "0110" & "000",

        -- E. Salta para o endereço 20
        -- 9: JMP 20 (Op=0110, Addr=0010100)
        9  => "0110" & "0000" & "0010100", 

        -- F. Zera R5 (Nunca será executada)
        -- 10: CLR R5 (Op=0001, Rx=0101)
        10 => "0001" & "0101" & "0000000",

        -- ... (11 a 19 são NOPs/Zeros) ...

        -- G. No endereço 20, copia R5 para R3
        -- 20: MOV R3, R5 (Op=0010, Rx=0011, Ry=0101)
        20 => "0010" & "0011" & "0101" & "000",

        -- H. Salta para o passo C (endereço 4)
        -- 21: JMP 4 (Op=0110, Addr=0000100)
        21 => "0110" & "0000" & "0000100",

        -- I. Zera R3 (Nunca será executada)
        -- 22: CLR R3 (Op=0001, Rx=0011)
        22 => "0001" & "0011" & "0000000",

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