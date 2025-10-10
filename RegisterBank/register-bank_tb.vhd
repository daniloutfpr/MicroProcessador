library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_bank_tb is
end entity;

architecture a_register_bank_tb of register_bank_tb is

    component RegisterBank is
        port(
            clock      : in std_logic;
            reset      : in std_logic;
            wr_en      : in std_logic;
            data_in    : in unsigned(15 downto 0);
            reg_sel_a  : in unsigned(3 downto 0);
            reg_sel_b  : in unsigned(3 downto 0);
            wr_addr    : in unsigned(3 downto 0);
            data_out_a : out unsigned(15 downto 0);
            data_out_b : out unsigned(15 downto 0)
        );
    end component;


    signal s_clock      : std_logic := '0';
    signal s_reset      : std_logic;
    signal s_wr_en      : std_logic;
    signal s_data_in    : unsigned(15 downto 0);
    signal s_reg_sel_a  : unsigned(3 downto 0);
    signal s_reg_sel_b  : unsigned(3 downto 0);
    signal s_wr_addr    : unsigned(3 downto 0);
    signal s_data_out_a : unsigned(15 downto 0);
    signal s_data_out_b : unsigned(15 downto 0);

    constant clock_period : time := 20 ns;

begin

 
    uut: RegisterBank
        port map(
            clock      => s_clock,
            reset      => s_reset,
            wr_en      => s_wr_en,
            data_in    => s_data_in,
            reg_sel_a  => s_reg_sel_a,
            reg_sel_b  => s_reg_sel_b,
            wr_addr    => s_wr_addr,
            data_out_a => s_data_out_a,
            data_out_b => s_data_out_b
        );

    -- Clock
    s_clock <= not s_clock after clock_period / 2;

   
    stim_proc: process
    begin
        
        s_reset <= '1';
        wait for 30 ns;
        s_reset <= '0';
        wait for clock_period;

        
        s_wr_en   <= '1';
        s_wr_addr <= "0101"; 
        s_data_in <= x"AAAA";
        wait for clock_period;

        
        s_wr_addr <= "0110"; 
        s_data_in <= x"BBBB";
        wait for clock_period;

        
        s_wr_en <= '0';
        s_data_in <= x"0000"; 
        wait for 5 ns; 

        
        s_reg_sel_a <= "0101";
        s_reg_sel_b <= "0110"; 
        wait for clock_period;

        
        s_reg_sel_a <= "0101"; 
        s_reg_sel_b <= "0110"; 
        s_wr_en   <= '1';
        s_wr_addr <= "0111";
        s_data_in <= x"CCCC";
        wait for clock_period;

        
        s_wr_en <= '0';
        wait;
    end process;

end architecture;