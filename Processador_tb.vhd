library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor_tb is 
end entity;

architecture a_processor_tb of processor_tb is
    
    component processor is
        port(
            clock           : in std_logic;
            reset           : in std_logic;
            reg_sel_a       : in unsigned(3 downto 0);
            reg_sel_b       : in unsigned(3 downto 0);
            wr_addr         : in unsigned(3 downto 0); 
            wr_en           : in std_logic;
            sel_write_data  : in std_logic;              
            sel_op          : in unsigned(1 downto 0);
            sel_constante   : in std_logic;
            data_in         : in unsigned(15 downto 0);
            alu_result      : out unsigned(15 downto 0);
            carry_out       : out std_logic;
            zero_out        : out std_logic;
            negative_out    : out std_logic
        ); 
    end component;

    
    signal s_clock          : std_logic := '0';
    signal s_reset          : std_logic := '1';
    signal s_reg_sel_a      : unsigned(3 downto 0) := "1111";
    signal s_reg_sel_b      : unsigned(3 downto 0) := "1111";
    signal s_wr_addr        : unsigned(3 downto 0) := (others => '0'); 
    signal s_wr_en          : std_logic := '0';
    signal s_sel_write_data : std_logic := '0';                         
    signal s_sel_op         : unsigned(1 downto 0) := (others => '0');
    signal s_sel_constante  : std_logic := '0';
    signal s_data_in        : unsigned(15 downto 0) := (others => '0');
    signal s_alu_result     : unsigned(15 downto 0) := (others => '0');
    signal s_carry_out      : std_logic;
    signal s_zero_out       : std_logic;
    signal s_negative_out   : std_logic;

    constant clock_period : time := 20 ns;

begin 
    
    uut: processor
        port map(
            clock          => s_clock,
            reset          => s_reset,
            reg_sel_a      => s_reg_sel_a,
            reg_sel_b      => s_reg_sel_b,
            wr_addr        => s_wr_addr,         
            wr_en          => s_wr_en,
            sel_write_data => s_sel_write_data,  
            sel_op         => s_sel_op,
            sel_constante  => s_sel_constante,
            data_in        => s_data_in,
            alu_result     => s_alu_result,
            carry_out      => s_carry_out,
            zero_out       => s_zero_out,
            negative_out   => s_negative_out
        );

    --Clock
    s_clock <= not s_clock after clock_period/2;

   
    stim_proc: process
    begin
        --Reset
        s_reset <= '1';
        wait for 30 ns;
        s_reset <= '0';
        wait for 20 ns;

        -- Test: R0 <= 10
        s_wr_en          <= '1';
        s_sel_write_data <= '1'; -- "data_in"
        s_wr_addr        <= "0000"; --R0
        s_data_in        <= x"000A"; --10
        wait for clock_period;

        -- Test: R1 <= 5
        s_wr_addr <= "0001"; -- R1
        s_data_in <= x"0005"; -- 5
        wait for clock_period;


        -- Test: R2 <= R0 + R1
        s_wr_en          <= '1';             -- write enable
        s_sel_write_data <= '0';             -- ALU result
        s_wr_addr        <= "0010";          -- R2
        s_reg_sel_a      <= "0000";          -- ALU input = R0 (10)
        s_reg_sel_b      <= "0001";          -- ALU input = R1 (5)
        s_sel_op         <= "00";            -- Op = SUM
        s_sel_constante  <= '0';

        -- ALU (15) R2
        wait for clock_period;

        -- Disable write
        s_wr_en <= '0';

        -- Test: R3 <= R2 - R1
        s_reg_sel_a      <= "0010"; -- ALU input = R2 (15)
        s_reg_sel_b      <= "0001"; -- ALU input = R1 (5)
        s_sel_op         <= "01";   -- Op = SUB
        s_sel_constante  <= '0';
        s_wr_en          <= '1';
        s_sel_write_data <= '0';
        s_wr_addr        <= "0011";          -- R3

        -- ALU (10) R3
        wait for clock_period;

        -- test end
        s_wr_en <= '0';
        wait;
    end process;

end architecture a_processor_tb;