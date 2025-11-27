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
    type rom_array_type is array (0 to 127) of unsigned(14 downto 0);

    signal rom_memory : rom_array_type := (
        -- 1: Initialization
        -- R8 = 31 (mask 011111)
        0  => "0001" & "1000" & "0000000", -- 0: CLR R8
        1  => "0101" & "1000" & "0011111", -- 1: ADDI R8, 31
        
        2  => "0001" & "0001" & "0000000", -- 2: CLR R1
        3  => "0101" & "0001" & "0000001", -- 3: ADDI R1, 1

        -- loop init (Addr 4)
        4  => "1010" & "0001" & "0001" & "000", -- SW R1, (R1)
        5  => "0101" & "0001" & "0000001", -- ADDI R1, 1
        
        -- check (or logic)
        6  => "0010" & "0111" & "0001" & "000", -- MOV R7, R1
        7  => "1011" & "0111" & "1000" & "000", -- OR R7, R8 
        8  => "0100" & "0111" & "1000" & "000", -- SUB R7, R8
        
        -- BLS for loop init (Target=4). PC=9. Offset = -5
        9  => "0111" & "0000" & "1111011", -- BLS -5
        10 => "0000" & "0000" & "0000000", -- NOP

        -- 2: filters for multiple numbers
        11 => "0001" & "0000" & "0000000", -- CLR R0

        -- --- 2 filter ---
        12 => "0001" & "0010" & "0000000", -- CLR R2
        13 => "0101" & "0010" & "0000100", -- ADDI R2, 4

        -- loop check 2 (Addr 14)
        14 => "0010" & "0111" & "0010" & "000", -- MOV R7, R2
        15 => "1011" & "0111" & "1000" & "000", -- OR R7, R8
        16 => "0100" & "0111" & "1000" & "000", -- SUB R7, R8
        
        -- BLS for CLEARING (Target=21). PC=17. Offset = +4
        -- Se (R2 OR 31) - 31 == 0, branches for clear. If not, JMP.
        17 => "0111" & "0000" & "0000100", -- BLS +4
        18 => "0000" & "0000" & "0000000", -- NOP
        
        -- JMP for filter 3 (Target=25)
        19 => "0110" & "0000" & "0011001", -- JMP 25
        20 => "0000" & "0000" & "0000000", -- NOP

        -- clear 2 (Addr 21)
        -- SW R2(Addr/Rx), R0(Data/Ry)
        21 => "1010" & "0010" & "0000" & "000", 
        22 => "0101" & "0010" & "0000010", -- ADDI R2, 2
        
        -- JMP for loop check 2 (Target=14)
        23 => "0110" & "0000" & "0001110", -- JMP 14
        24 => "0000" & "0000" & "0000000", -- NOP

        -- filter for 3  (Addr 25)
        25 => "0001" & "0010" & "0000000", 
        26 => "0101" & "0010" & "0000110", -- ADDI R2, 6

        -- loop check 3 (Addr 27)
        27 => "0010" & "0111" & "0010" & "000", 
        28 => "1011" & "0111" & "1000" & "000", -- OR R7, R8 (NOVO!)
        29 => "0100" & "0111" & "1000" & "000", 
        
        -- BLS for clearing (Target=34). PC=30. Offset = +4
        30 => "0111" & "0000" & "0000100", 
        31 => "0000" & "0000" & "0000000", 
        
        -- JMP for filter 5 (Target=38)
        32 => "0110" & "0000" & "0100110", -- JMP 38
        33 => "0000" & "0000" & "0000000", 

        -- clear 3 (Addr 34)
        34 => "1010" & "0010" & "0000" & "000", 
        35 => "0101" & "0010" & "0000011", -- ADDI R2, 3
        
        -- JMP for loop check 3 (Target=27)
        36 => "0110" & "0000" & "0011011", -- JMP 27
        37 => "0000" & "0000" & "0000000", 

        -- filter 5 (Addr 38)
        38 => "0001" & "0010" & "0000000", 
        39 => "0101" & "0010" & "0001010", -- ADDI R2, 10

        -- loop check 5 (Addr 40)
        40 => "0010" & "0111" & "0010" & "000", 
        41 => "1011" & "0111" & "1000" & "000", -- OR R7, R8
        42 => "0100" & "0111" & "1000" & "000", 
        
        -- BLS for clear (Target=47). PC=43. Offset = +4
        43 => "0111" & "0000" & "0000100", 
        44 => "0000" & "0000" & "0000000", 
        
        -- JMP for reading (Target=51)
        45 => "0110" & "0000" & "0110011", -- JMP 51
        46 => "0000" & "0000" & "0000000", 

        -- clear 5 (Addr 47)
        47 => "1010" & "0010" & "0000" & "000", 
        48 => "0101" & "0010" & "0000101", -- ADDI R2, 5
        
        -- JMP for loop check 5 (Target=40)
        49 => "0110" & "0000" & "0101000", -- JMP 40
        50 => "0000" & "0000" & "0000000", 

        -- 3: read and display
        -- Addr 51
        51 => "0001" & "0001" & "0000000", 
        52 => "0101" & "0001" & "0000010", 

        -- read loop (Addr 53)
        53 => "1001" & "0100" & "0001" & "000", -- LW R4, (R1)
        54 => "0000" & "0000" & "0000000", 
        55 => "0010" & "0110" & "0100" & "000", -- MOV R6, R4
        
        56 => "0101" & "0001" & "0000001", -- ADDI R1, 1
        
        -- check read end (using OR logic )
        57 => "0010" & "0111" & "0001" & "000", 
        58 => "1011" & "0111" & "1000" & "000", -- OR R7, R8
        59 => "0100" & "0111" & "1000" & "000", 

        -- BLS for read loop (Target=53). PC=60. Offset = -7
        60 => "0111" & "0000" & "1111001", -- BLS -7
        61 => "0000" & "0000" & "0000000", 


        62 =>"0001" & "0001" & "0000000", -- CLR R1

        63 => "1111" & "00000000000", -- INVALID OPCODE ( BREAKS EXECUTION )

        64 =>"0101" & "0001" & "0000001", -- ADDI R1, 1

        65 => "0110" & "0000" & "1000001", -- JMP 64 (final loop)
        66 => "0000" & "0000" & "0000000", 



        others => (others => '0')
    );
begin
    process(clk)
    begin
        if rising_edge(clk) then
            data <= rom_memory(to_integer(address));
        end if;
    end process;
end architecture a_rom;