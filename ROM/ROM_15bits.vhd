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
    -- Opcodes: CLR=0001, MOV=0010, ADD=0011, SUB=0100, ADDI=0101
    --          JMP=0110, BLS=0111, BPL = 1000, LW = 1001, SW = 1010
    
    -- LW/SW FORMAT: Op[14:11] | Rs_Base[10:7] | Rt_Data[6:3] | Ignored[2:0]

    type rom_array_type is array (0 to 127) of unsigned(14 downto 0);

    signal rom_memory : rom_array_type := (
        -- 0: CLR  $r1 (Reg 0001)
        0  => "0001" & "0001" & "0000000",
        -- 1: ADDI $r1, 20 (Imm 0010100)
        1  => "0101" & "0001" & "0010100",
        -- 2: CLR  $r2 (Reg 0010)
        2  => "0001" & "0010" & "0000000",
        -- 3: ADDI $r2, 31 (Imm 0011111)
        3  => "0101" & "0010" & "0011111",
        -- 4: CLR  $r3 (Reg 0011)
        4  => "0001" & "0011" & "0000000",
        -- 5: ADDI $r3, 5 (Imm 0000101)
        5  => "0101" & "0011" & "0000101",

        
        -- 6: CLR  $r6 (Reg 0110)
        6  => "0001" & "0110" & "0000000",
        -- 7: ADDI $r6, 10 (Imm 0001010)
        7  => "0101" & "0110" & "0001010",
        -- 8: sw $r1, ($r6) (Op=1010, Rs=r6, Rt=r1)
        8  => "1010" & "0110" & "0001" & "000",
        
        -- 9: CLR  $r6
        9  => "0001" & "0110" & "0000000",
        -- 10: ADDI $r6, 25 (Imm 0011001)
        10 => "0101" & "0110" & "0011001",
        -- 11: sw $r2, ($r6) (Op=1010, Rs=r6, Rt=r2)
        11 => "1010" & "0110" & "0010" & "000",

        -- 12: CLR  $r6
        12 => "0001" & "0110" & "0000000",
        -- 13: ADDI $r6, 3 (Imm 0000011)
        13 => "0101" & "0110" & "0000011",
        -- 14: sw $r3, ($r6) (Op=1010, Rs=r6, Rt=r3)
        14 => "1010" & "0110" & "0011" & "000",

        -- 15: sw $r1, ($r6) (Overwrite RAM[3] with r1)
        15 => "1010" & "0110" & "0001" & "000",

        
        -- 16: CLR $r1
        16 => "0001" & "0001" & "0000000",
        -- 17: CLR $r2
        17 => "0001" & "0010" & "0000000",
        -- 18: CLR $r3
        18 => "0001" & "0011" & "0000000",

        -- PHASE 4: READ FROM RAM
        -- 19: CLR  $r6
        19 => "0001" & "0110" & "0000000",
        -- 20: ADDI $r6, 25 (Imm 0011001)
        20 => "0101" & "0110" & "0011001",
        -- 21: lw $r4, ($r6) (Op=1001, Rs=r6, Rt=r4)
        21 => "1001" & "0110" & "0100" & "000",

        -- 22: CLR  $r6
        22 => "0001" & "0110" & "0000000",
        -- 23: ADDI $r6, 3 (Imm 0000011)
        23 => "0101" & "0110" & "0000011",
        -- 24: lw $r5, ($r6) (Op=1001, Rs=r6, Rt=r5)
        24 => "1001" & "0110" & "0101" & "000",

        -- 25: CLR  $r6
        25 => "0001" & "0110" & "0000000",
        -- 26: ADDI $r6, 10 (Imm 0001010)
        26 => "0101" & "0110" & "0001010",
        -- 27: lw $r7, ($r6) (Op=1001, Rs=r6, Rt=r7)
        27 => "1001" & "0110" & "0111" & "000",

        -- END
        -- 28: JMP 28 (Addr 0011100)
        28 => "0110" & "0000" & "0011100",

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