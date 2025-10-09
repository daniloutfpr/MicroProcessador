library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor_tb is 
end entity;

architecture a_processor_tb of processor_tb is
    component processor is
        port(
            clock  : in std_logic;
            reset  : in std_logic
        ); 
    end component;

    constant period_time : time      := 100 ns;
    signal   finished    : std_logic := '0';   
    
    
    signal   s_clock, s_reset  : std_logic; 
    
    signal s_reg_sel_a : unsigned(3 downto 0) := (others => '0'); 
    signal s_reg_sel_b : unsigned(3 downto 0) := (others => '0'); 
    signal s_reg_sel_dest : unsigned(3 downto 0) := (others => '0'); 
    signal s_wr_en : std_logic := '0';                             
    signal s_sel_op : unsigned(1 downto 0) := (others => '0');     
    signal s_sel_constante : std_logic := '0';                     

    
    signal s_result_out_ula : unsigned(15 downto 0) := (others => '0'); 

begin 
    uut: processor
        port map(
            clock => s_clock,
            reset => s_reset
        );


   
    clock_proc: process
    begin 
        while finished /= '1' loop
            s_clock <= '0';
            wait for period_time/2;
            s_clock <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clock_proc;

    
    reset_global:process
    begin 
        s_reset <= '1';
        wait for period_time * 2;
        s_reset <= '0';
        wait; 
    end process reset_global;

    
    sim_time_proc: process
    begin
        wait for 10 us;         
        finished <= '1';
        wait;
    end process sim_time_proc;

 
    test: process
    begin 
        
        wait until s_reset = '0';
        wait for period_time;

        ---Test1  R1=5 e R2=10----

        s_wr_en <= '1';
        s_reg_sel_dest <= to_unsigned(1,4); 
        s_result_out_ula <= to_unsigned(5,16); -- R1=5
        
        wait until rising_edge(s_clock); 

        s_wr_en <= '0';
        s_result_out_ula <= (others => '0'); 

        s_wr_en <= '1';
        s_reg_sel_dest <= to_unsigned(2, 4); -- R2
        s_result_out_ula <= to_unsigned(10, 16); -- R2 = 10
        
        wait until rising_edge(s_clock);
        
        s_wr_en <= '0';
        s_result_out_ula <= (others => '0'); 
       
        wait for period_time;

        ---Teste2 - Simular Op R3 = R1 + R2----

        s_reg_sel_a <= to_unsigned(1, 4); -- Ler R1
        s_reg_sel_b <= to_unsigned(2, 4); -- Ler R2
        
    
        s_sel_op <= "00"; -- SOMA
        s_sel_constante <= '0'; 
        
        wait for 1 ns; 

        s_wr_en <= '1';
        s_reg_sel_dest <= to_unsigned(3, 4); -- Endereço de destino R3
        
        wait until rising_edge(s_clock); 
        
        s_wr_en <= '0';
        s_sel_op <= (others => '0');
        s_reg_sel_a <= (others => '0');
        s_reg_sel_b <= (others => '0');
        s_reg_sel_dest <= (others => '0');

        wait for period_time * 2;
        
        
        wait; 
    end process test;
end architecture a_processor_tb;





