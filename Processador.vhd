library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entidade do processador completo
entity processor is
    port (
        clock         : in std_logic;
        reset         : in std_logic
    );
end entity processor;


architecture a_processor of processor is
    
    
    component RegisterBank is
        port (
             clock: in std_logic;
            reset: in std_logic;
            wr_en: in std_logic;
            data_in: in unsigned(15 downto 0);
            reg_sel_a: in unsigned(3 downto 0); -- register a selection
            reg_sel_b: in unsigned(3 downto 0); -- register b selection 
            data_out_a: out unsigned(15 downto 0);
            data_out_b: out unsigned(15 downto 0)
        );
    end component;

    
    component ALU is
        port (
            ent0 : in unsigned(15 downto 0);     -- First 16 bits input
            ent1 : in unsigned(15 downto 0);     -- Second 16 bits input
            sel_op : in unsigned(1 downto 0);    -- 4x (different operations)

            alu_out : out unsigned (15 downto 0); -- 16 bits output for the ALU
            --operation flags
            carry : out std_logic;
            zero : out std_logic;
            isNegative : out std_logic
        );
    end component;

    
    
    signal s_out_reg_a : unsigned(15 downto 0);
    signal s_out_reg_b : unsigned(15 downto 0);
    signal s_result_out_ula : unsigned(15 downto 0);
    signal s_ent_b_ula : unsigned(15 downto 0);

    signal s_reg_sel_a : unsigned(3 downto 0) := (others => '0');
    signal s_reg_sel_b : unsigned(3 downto 0) := (others => '0');
    signal s_wr_en : std_logic := '0';
    signal s_sel_op : unsigned(1 downto 0) := (others => '0');
    signal s_sel_constante : std_logic := '0';
    constant c_constante_externa : unsigned(15 downto 0) := (others => '0');

    signal s_carry : std_logic;
    signal s_zero : std_logic;
    signal s_isNegative : std_logic;

    


begin
        --
    RegisterBank_1: component RegisterBank
        port map (
           
            clock      => clock,
            reset      => reset,
            data_out_a => s_out_reg_a,  
            data_out_b => s_out_reg_b,  
            data_in    => s_result_out_ula, 
            
            reg_sel_a  => s_reg_sel_a,
            reg_sel_b  => s_reg_sel_b,
            wr_en      => s_wr_en
        );

  
    ALU_1: component ALU
        port map (
             ent0        => s_out_reg_a,    
            ent1        => s_ent_b_ula, 
            
            alu_out     => s_result_out_ula, 
        
            sel_op      => s_sel_op,        
            carry       => s_carry,
            zero        => s_zero,
            isNegative  => s_isNegative
        );
        --
        s_ent_b_ula <= s_out_reg_b when s_sel_constante = '0' else
                   c_constante_externa;

end architecture a_processor;