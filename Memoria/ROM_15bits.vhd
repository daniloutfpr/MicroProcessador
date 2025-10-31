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
    type mem is array (0 to 127) of unsigned (14 downto 0);
    --NOP         0000 xxx xxx xxxxx
    --CLR Rn      0001 ddd xxxx xxxx
    --MOV Rn,Rm:  0010 ddd sss xxxxx
    --ADD Rn,Rm:  0011 ddd sss xxxxx
    --SUB Rn,Rm:  0100 ddd sss xxxxx
    --ADDI Rn,c:  0101 ddd xxx xcccc
    --JMP:        0110 xxx xxx eeeee

    --A. Carrega R3 (o registrador 3) com o valor 5
    --B. Carrega R4 com 8
    --C. Soma R3 com R4 e guarda em R5
    --D. Subtrai 1 de R5
    --E. Salta para o endereço 20
    --F. Zera R5 (nunca será executada)
    --G. No endereço 20, copia R5 para R3
    --H. Salta para o passo C desta lista (R5 <= R3+R4)
    --I. Zera R3 (nunca será executada)

    constant rom_content : mem := (
        -- adress => content
        -- A. Carrega R3 com 5 (R3 <= 0 + 5)
    0  => "000101100000000", -- CLR R3
    1  => "010101100000101", -- ADDI R3, 5

    -------------------
    2  => "000110000000000", -- CLR R4
    3  => "010110000001000", -- ADDI R4, 8

    ---------------
   
    4  => "001010101100000", -- MOV R5, R3 (R5 <= R3)
    5  => "001110110000000", -- ADD R5, R4 (R5 <= R5 + R4)

    -- ---------------------
    
    6  => "000111000000000", -- CLR R6          (R6 = 0)
    7  => "010111000000001", -- ADDI R6, 1      (R6 = 1)
    8  => "010010111000000", -- SUB R5, R6      (R5 <= R5 - R6)

    -- ---------------------
  
    9  => "011000000010100", -- JMP 20

    -- -------------------------------
    10 => "000110100000000", -- CLR R5

    -- -----------------------
    11 => "000000000000000", -- NOP
    12 => "000000000000000", -- NOP
    13 => "000000000000000", -- NOP
    14 => "000000000000000", -- NOP
    15 => "000000000000000", -- NOP
    16 => "000000000000000", -- NOP
    17 => "000000000000000", -- NOP
    18 => "000000000000000", -- NOP
    19 => "000000000000000", -- NOP

    -- --------------------
    20 => "001001110100000", -- MOV R3, R5 (R3 <= R5)

  -------------------------------
    
    21 => "011000000000100", -- JMP 4

    ---------------------------
    22 => "000101100000000", -- CLR R3
      

      others => (others => '0')
    );
begin 
    process(clk)
    begin 
        if(rising_edge(clk)) then 
            data <= rom_content(to_integer(adrees));
        end if;
    end process;
end architecture;