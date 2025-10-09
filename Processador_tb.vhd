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
            wr_en           : in std_logic;
            sel_op          : in unsigned(1 downto 0);
            sel_constante   : in std_logic;
            data_in         : in unsigned(15 downto 0);
            alu_result      : out unsigned(15 downto 0);
            carry_out       : out std_logic;
            zero_out        : out std_logic;
            negative_out    : out std_logic
        ); 
    end component;

    signal s_clock : std_logic := '0';
    signal s_reset : std_logic := '1';
    signal s_reg_sel_a : unsigned(3 downto 0) := (others => '0');
    signal s_reg_sel_b : unsigned(3 downto 0) := (others => '0');
    signal s_wr_en : std_logic := '0';
    signal s_sel_op : unsigned(1 downto 0) := (others => '0');
    signal s_sel_constante : std_logic := '0';
    signal s_data_in : unsigned(15 downto 0) := (others => '0');
    signal s_alu_result : unsigned(15 downto 0);
    signal s_carry_out : std_logic;
    signal s_zero_out : std_logic;
    signal s_negative_out : std_logic;

begin 
    uut: processor
        port map(
            clock         => s_clock,
            reset         => s_reset,
            reg_sel_a     => s_reg_sel_a,
            reg_sel_b     => s_reg_sel_b,
            wr_en         => s_wr_en,
            sel_op        => s_sel_op,
            sel_constante => s_sel_constante,
            data_in       => s_data_in,
            alu_result    => s_alu_result,
            carry_out     => s_carry_out,
            zero_out      => s_zero_out,
            negative_out  => s_negative_out
        );

    stim_proc: process
    begin
        -- Reset
        s_reset <= '1';
        wait for 30 ns;
        s_reset <= '0';
        wait for 20 ns;

        -- Write R0 = 10
        s_wr_en <= '1';
        s_reg_sel_a <= "0000";
        s_data_in <= x"000A";
        wait for 5 ns;
        s_clock <= '1';
        wait for 20 ns;
        s_clock <= '0';
        wait for 20 ns;

        -- Write R1 = 5
        s_reg_sel_a <= "0001";
        s_data_in <= x"0005";
        wait for 5 ns;
        s_clock <= '1';
        wait for 20 ns;
        s_clock <= '0';
        wait for 20 ns;

        -- Disable write
        s_wr_en <= '0';

        -- Add R0 + R1
        s_reg_sel_a <= "0000";
        s_reg_sel_b <= "0001";
        s_sel_op <= "00";
        s_sel_constante <= '0';
        wait for 30 ns;

        -- Subtract R0 - R1
        s_sel_op <= "01";
        wait for 30 ns;

        -- AND R0 & R1
        s_sel_op <= "10";
        wait for 30 ns;

        -- OR R0 | R1
        s_sel_op <= "11";
        wait for 30 ns;

        wait;
    end process;

end architecture a_processor_tb;





