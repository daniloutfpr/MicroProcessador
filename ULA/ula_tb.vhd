-----test_bench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is 
end ALU_tb;

architecture a_ALU_tb of ALU_tb is
    component ALU is
        port(
            ent0 : in unsigned(15 downto 0);     -- First 16 bits input
            ent1 : in unsigned(15 downto 0);     -- Second 16 bits input
            sel_op : in unsigned(1 downto 0);    -- 4x (different operations)

            alu_out: out unsigned (15 downto 0); -- 16 bits output for the ALU
            --operation flags
            carry : out std_logic;
            zero : out std_logic;
            isNegative : out std_logic
        );
    end component;
    --Signals for ALU inputs and outputs
    signal s_ent0 : unsigned(15 downto 0);
    signal s_ent1 : unsigned(15 downto 0);
    signal s_sel_op : unsigned(1 downto 0);

    signal s_alu_out : unsigned(15 downto 0);
    signal s_carry      : std_logic;
    signal s_zero       : std_logic;
    signal s_isNegative : std_logic;

   

    begin 
        uut:ALU port map(
            ent0 => s_ent0,
            ent1 => s_ent1,
            sel_op => s_sel_op,
            alu_out => s_alu_out,
            carry => s_carry,
            zero => s_zero, 
            isNegative => s_isNegative
        );

    process 
        begin 
            --add
            s_sel_op <= "00";
            s_ent0 <= to_unsigned(5,16);
            s_ent1 <= to_unsigned(10,16);

            wait for 50 ns;
            --carry
            s_ent0 <= "1111111111111111"; -- 65535
            s_ent1 <= "0000000000000001"; -- 1

            wait for 50 ns;
            --sub
            s_sel_op <= "01";
            s_ent0 <= to_unsigned(20,16);
            s_ent1 <= to_unsigned(8,16);

            wait for 50 ns;
            --zero
            s_ent0 <= to_unsigned(10,16);
            s_ent1 <= to_unsigned(10,16);

            wait for 50 ns;
            --isNegative
            s_ent0 <= to_unsigned(5,16);
            s_ent1 <= to_unsigned(10,16);
           
            
            wait for 50 ns;
            --and 
            s_sel_op <= "10";
            s_ent0 <= x"0F0F";--binario "0000111100001111"
            s_ent1 <= x"FFFF";--binario "1111111111111111"

            wait for 50 ns;
            --or
            s_sel_op <= "11";
            s_ent0 <= x"0F0F";
            s_ent1 <= x"F0F0"; --binario "1111000011110000"

            wait for 50 ns;

            report "End Simulation!";
            wait ;
        end process;
    end architecture a_ALU_tb;


            

