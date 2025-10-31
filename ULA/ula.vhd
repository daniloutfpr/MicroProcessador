library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
    port (
        ent0 : in unsigned(14 downto 0);     -- First 16 bits input
        ent1 : in unsigned(14 downto 0);     -- Second 16 bits input
        sel_op : in unsigned(1 downto 0);    -- 4x (different operations)

        alu_out : out unsigned (14 downto 0); -- 16 bits output for the ALU
        --operation flags
        carry : out std_logic;
        zero : out std_logic;
        isNegative : out std_logic
    );
  end;
architecture a_ALU of ALU is

  signal result: unsigned (15 downto 0);

  begin
    result <= (("0" & ent0) + ("0" & ent1)) when sel_op = "00" else  -- Sum operation
              (("0" & ent0) - ("0" & ent1)) when sel_op = "01" else  -- Subtraction operation
              ("0" & ent1) when sel_op = "10" else  -- Comparsion operation (each bit) --(MOV)
              "0000000000000000"; --CLR

    alu_out <= result(14 downto 0);
    
    carry <= result(15);

    zero <= '1' when result(14 downto 0) = "000000000000000" else '0';

    isNegative <= result(14);

  end architecture;

    