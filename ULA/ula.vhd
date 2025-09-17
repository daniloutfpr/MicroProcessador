--Especificaçoes ULA
--duas entradas de dados de 16 bits;
--•uma saída de resultado de 16 bits;
--•duas ou mais saídas de sinalização de um bit (são as flags, representam o status da
--operação;   consulte   a   tabela   de   branches   condicionais   sorteados   para   você   e
--implemente as flags indicadas na tabela, descritas no PDF do sorteio no Moodle);
--•entradas para seleção da operação

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
    port (
        ent0 : in unsigned(15 downto 0);     -- First 16 bits input
        ent1 : in unsigned(15 downto 0);     -- Second 16 bits input
        sel_op : in unsigned(1 downto 0);    -- 4x (different operations)

        output : out unsigned (15 downto 0); -- 16 bits output for the ALU
        --operation flags
        carry : out std_logic;
        zero : out std_logic;
        isNegative : out std_logic
    )

architecture a_ALU of ALU is

  signal result: unsigned (16 down to 0);

  begin
    result <= (("0" & ent0) + ("0" & ent1)) when sel_op = "00" else  -- Sum operation
              (("0" & ent0) - ("0" & ent1)) when sel_op = "01" else  -- Subtraction operation
              (("0" & ent0) and ("0" & ent1)) when sel_op = "10" else  -- Comparsion operation (each bit)
              (("0" & ent0) or ("0" & ent1)) when sel_op = "11" else  -- Active bit checking (Or operation)
              "00000000000000000"

    output <= result(15 down to 0);
    
    carry <= result(16);

    zero <= '1' when result(15 down to 0) = (others => '0') else '0';

    isNegative < = output(15);

  end architecture;

    