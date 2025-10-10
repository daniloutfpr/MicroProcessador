library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Entidade do processador completo
entity processor is
    port (
        clock           : in std_logic;
        reset           : in std_logic;
        -- Add control inputs for testing
        reg_sel_a       : in unsigned(3 downto 0);
        reg_sel_b       : in unsigned(3 downto 0);
        wr_addr         : in unsigned(3 downto 0);
        wr_en           : in std_logic;
        sel_op          : in unsigned(1 downto 0);
        sel_constante   : in std_logic;
        sel_write_data  : in std_logic;
        data_in         : in unsigned(15 downto 0);
        -- Add outputs for observation
        alu_result      : out unsigned(15 downto 0);
        carry_out       : out std_logic;
        zero_out        : out std_logic;
        negative_out    : out std_logic
    );
end entity processor;

architecture a_processor of processor is
    
    component RegisterBank is
        port (
            clock: in std_logic;
            reset: in std_logic;
            wr_en: in std_logic;
            data_in: in unsigned(15 downto 0);
            reg_sel_a: in unsigned(3 downto 0);
            reg_sel_b: in unsigned(3 downto 0);
            wr_addr: in unsigned(3 downto 0);
            data_out_a: out unsigned(15 downto 0);
            data_out_b: out unsigned(15 downto 0)
        );
    end component;

    component ALU is
        port (
            ent0 : in unsigned(15 downto 0);
            ent1 : in unsigned(15 downto 0);
            sel_op : in unsigned(1 downto 0);
            alu_out : out unsigned (15 downto 0);
            carry : out std_logic;
            zero : out std_logic;
            isNegative : out std_logic
        );
    end component;

    -- Internal signals
    signal s_out_reg_a : unsigned(15 downto 0);
    signal s_out_reg_b : unsigned(15 downto 0);
    signal s_result_out_ula : unsigned(15 downto 0);
    signal s_ent_b_ula : unsigned(15 downto 0);
    signal s_reg_write_data : unsigned(15 downto 0);

begin
        --Mux_wr_regBank(out_alu or data_in)
     s_reg_write_data <= s_result_out_ula when sel_write_data = '0' else
                         data_in;

    -- Register Bank instantiation
    RegisterBank_1: RegisterBank
        port map (
            clock      => clock,
            reset      => reset,
            wr_en      => wr_en,
            data_in    => s_reg_write_data,
            reg_sel_a  => reg_sel_a,
            reg_sel_b  => reg_sel_b,
            wr_addr    => wr_addr,
            data_out_a => s_out_reg_a,
            data_out_b => s_out_reg_b
        );

    -- ALU instantiation
    ALU_1: ALU
        port map (
            ent0       => s_out_reg_a,
            ent1       => s_ent_b_ula,
            sel_op     => sel_op,
            alu_out    => s_result_out_ula,
            carry      => carry_out,
            zero       => zero_out,
            isNegative => negative_out
        );

    -- Multiplexer for constant or register input to ALU
    s_ent_b_ula <= s_out_reg_b when sel_constante = '0' else
                   data_in;

    -- Connect ALU result to output
    alu_result <= s_result_out_ula;
 

end architecture a_processor;