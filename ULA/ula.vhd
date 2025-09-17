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

entity ULA is 
    port (
        clk : in std_logic;
        ent1 : in unsigned(15 downto 0); --2 entradas de 16 bits na ula
        ent2: in unsigned(15 downto 0);
        sel_op : in unsigned(1 downto 0);--4(operaçoes)
        saida: out unsigned (15 downto 0);-- saida de 16 bits na ula
        --flags dos carrys in/out (falta)
    )

architecture a_ULA of ULA isl