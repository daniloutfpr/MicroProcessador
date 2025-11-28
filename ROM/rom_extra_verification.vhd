-- extra verification
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
       -- 0: CLR R1 
        0  => "0001" & "0001" & "0000000",

        -- 1: ADDI R1,10
        1  => "0101" & "0001" & "0001010",

        -- 2: CLR  R2 
        2  => "0001" & "0010" & "0000000",

        -- 3: ADDI R2,5
        3  => "0101" & "0010" & "0000101",

        -- 4: CLR R3
        4  => "0001" & "0011" & "0000000",

        -- 5: ADD R3,R1
        5  => "0011" & "0011" & "0001" & "000",

        -- 6: ADD R3,R2
        6  => "0011" & "0011" & "0010" & "000",

        -- 7: MOV R4,R3
        7 => "0010" & "0100" & "0011" & "000",

        -- 8:CLR R5
        8 => "0001" & "0101" & "0000000",

        -- 9: SUB R5 , R3 
        9  => "0100" & "0101" & "0011" & "000",

        --10:BLS 12
        10 => "0111" & "0000" & "0000010",

        --11:JMP 1
        11 => "0110" & "0000" & "0000001",

        --12:CLR R5
        12 => "0001" & "0101" & "0000000",

        --13:SW R5,R4
        13=> "1010" & "0101" & "0100" & "000",
        
        --14:CLR R6
        14 => "0001" & "0110" & "0000000",

        --15:LW R6,R5
        15 => "1001" & "0110" & "0101" & "000",

        --16:CLR R7
        16 => "0001" & "0111" & "0000000",
        
        --17:ADDI R7,1
        17 => "0101" & "0111" & "0000001",

        --18:OR R7,R6
        18 => "1011" & "0111" & "0110" & "000",

        --19:CLR R8
        19 => "0001" & "1000" & "0000000",

        --20:ADDI R8,20
        20 => "0101" & "1000" & "0010100",

        --21:SUB R8,R7
        21 => "0100" & "1000" & "0111" & "000",

        --22:BPL 24
        22 => "1000" & "0000" & "0000010",

        --23:JMP 1
        23 => "0110" & "0000" & "0000001",

        --24:CLR R9
        24 => "0001" & "1001" & "0000000",

        --25:JMP 25
        25 => "0110" & "0000" & "0011001",

        26 => "1111" & "00000000000" ,

        27 =>  "0101" & "0111" & "0000011",

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