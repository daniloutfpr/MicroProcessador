library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Processor top-level entity
entity processor is
    port (
        clock           : in std_logic;
        reset           : in std_logic;
        
        exception : out std_logic 
    );
end entity processor;

architecture a_processor of processor is
    
    component RegisterBank is
        port (
            clock: in std_logic;    
            reset: in std_logic;
            wr_en: in std_logic;
            data_in: in unsigned(14 downto 0);
            reg_sel_a: in unsigned(3 downto 0);
            reg_sel_b: in unsigned(3 downto 0);
            wr_addr: in unsigned(3 downto 0);
            data_out_a: out unsigned(14 downto 0);
            data_out_b: out unsigned(14 downto 0)
        );
    end component;

    component ALU is
        port (
            ent0 : in unsigned(14 downto 0);
            ent1 : in unsigned(14 downto 0);
            -- ATUALIZADO: Agora são 3 bits para suportar o OR
            sel_op : in unsigned(2 downto 0); 
            alu_out : out unsigned (14 downto 0);
            carry : out std_logic;
            zero : out std_logic;
            isNegative : out std_logic
        );
    end component;

    component instr_reg is
        port(
            clock : in std_logic;
            reset : in std_logic;
            wr_en: in std_logic;
            data_in : in unsigned(14 downto 0);
            data_out : out unsigned (14 downto 0)
        );
    end component;

    component PCCounterTop is 
        port(
            clock:        in  std_logic;
            reset:        in  std_logic;
            wr_en:        in  std_logic;
            pc_sel:       in  std_logic; 
            jump_addr_in: in  unsigned (6 downto 0); 
            pc_out:       out unsigned (6 downto 0)
        );
    end component;

    component rom is
        port(
            clk: in std_logic;
            address: in unsigned(6 downto 0); 
            data : out unsigned(14 downto 0)
        );
    end component;

    component UC is 
        port(
            clock: in std_logic;
            reset: in std_logic;
            opcode: in unsigned (3 downto 0); 
            
            --Wr_en
            pc_wr_en: out std_logic;  
            ram_wr_en: out std_logic; 
            ri_wr_en: out std_logic;  
            rb_wr_en: out std_logic;  
            psw_wr_en: out std_logic; 
            
            --Flags (from PSW)
            isNegative: in std_logic;
            carry: in std_logic;
            isZero: in std_logic;

            --Mux
            pc_sel  : out std_logic;
            mux_alu: out std_logic; 
            mux_rb : out std_logic;
           
            alu_op : out unsigned(2 downto 0);
            
            invalid_op : out std_logic
        );
    end component;

    component psw is
      port(
        clock: in std_logic;
        reset: in std_logic;
        wr_en: in std_logic;
        data_in: in unsigned(2 downto 0);
        
        --Flags
        isNegative: out std_logic;
        carry: out std_logic;
        isZero: out std_logic
      );
    end component;

    component ram is
      port(
        clk: in std_logic;
        address: in unsigned(6 downto 0);
        wr_en: in std_logic;
        data_in: in unsigned(14 downto 0);   
        data_out: out unsigned(14 downto 0)  
      );
    end component;

    -- Internal signals

    signal s_pc_wr_en   : std_logic; 
    signal s_ri_wr_en   : std_logic; 
    signal s_rb_wr_en   : std_logic; 
    signal s_psw_wr_en  : std_logic;
    signal s_ram_wr_en  : std_logic;
    signal s_pc_sel     : std_logic; 
    signal s_mux_alu    : std_logic; 
    signal s_mux_rb     : std_logic; 
    
    -- ATUALIZADO: Barramento de controle da ULA aumentado para 3 bits
    signal s_alu_op     : unsigned(2 downto 0);

    -- ADICIONADO: Sinal interno para carregar o erro
    signal s_invalid_op : std_logic;

    -- ALU -> PSW
    signal s_flag_N_calc : std_logic;           
    signal s_flag_Z_calc : std_logic;
    signal s_flag_C_calc : std_logic;
    signal s_flags_calc_bus : unsigned(2 downto 0); 

    -- PSW -> UC
    signal s_flag_N_reg : std_logic;
    signal s_flag_Z_reg : std_logic;
    signal s_flag_C_reg : std_logic;

    -- Branch address calculation
    signal s_pc_branch_offset : signed(6 downto 0);   
    signal s_pc_branch_target : unsigned(6 downto 0); 

    signal s_pc_out     : unsigned(6 downto 0);  
    signal s_rom_data   : unsigned(14 downto 0); 
    signal s_ri_out     : unsigned(14 downto 0); 
    
    signal s_rb_out_a   : unsigned(14 downto 0); 
    signal s_rb_out_b   : unsigned(14 downto 0); 
    signal s_alu_in_b   : unsigned(14 downto 0); 
    signal s_alu_out    : unsigned(14 downto 0); 
    signal s_rb_data_in : unsigned(14 downto 0); 
    signal s_ram_data_out : unsigned(14 downto 0); 

    signal s_opcode_in  : unsigned(3 downto 0);  
    signal s_rb_addr_a  : unsigned(3 downto 0);  
    signal s_rb_addr_b  : unsigned(3 downto 0);  
    signal s_rb_addr_w  : unsigned(3 downto 0);  
    signal s_imm   : unsigned(14 downto 0); 
    signal s_jump_addr  : unsigned(6 downto 0);  

begin
      
    -- Conectando a saída do Top-Level ao sinal interno
    exception<= s_invalid_op;

    inst_RB: RegisterBank
        port map(
            clock    => clock,
            reset    => reset,
            wr_en    => s_rb_wr_en,    
            data_in  => s_rb_data_in,   
            reg_sel_a=> s_rb_addr_a,    
            reg_sel_b=> s_rb_addr_b,    
            wr_addr  => s_rb_addr_w,    
            data_out_a => s_rb_out_a,   
            data_out_b => s_rb_out_b    
        );

    -- ALU instantiation
    inst_ALU: ALU
        port map(
            ent0 => s_rb_out_a,   
            ent1 => s_alu_in_b,   
            sel_op => s_alu_op,    -- Conectando o sinal de 3 bits
            alu_out => s_alu_out,  
            
            carry => s_flag_C_calc, 
            zero => s_flag_Z_calc, 
            isNegative => s_flag_N_calc 
        );
    
    inst_ROM: rom
        port map(
            clk    => clock,      
            address => s_pc_out,   
            data   => s_rom_data 
        );
    
    inst_UC: UC
        port map(
            clock => clock,
            reset => reset,
            opcode => s_opcode_in, 

            isNegative => s_flag_N_reg, 
            isZero => s_flag_Z_reg, 
            carry => s_flag_C_reg, 

            ram_wr_en => s_ram_wr_en,
            psw_wr_en => s_psw_wr_en,
            pc_wr_en => s_pc_wr_en,
            ri_wr_en => s_ri_wr_en,
            rb_wr_en => s_rb_wr_en,
            pc_sel   => s_pc_sel,
            mux_alu  => s_mux_alu,
            mux_rb   => s_mux_rb,
            alu_op   => s_alu_op,     -- Conectando o sinal de 3 bits
            invalid_op => s_invalid_op -- Conectando o novo sinal de erro
        );

    inst_PC: PCCounterTop
        port map(
            clock        => clock,
            reset        => reset,
            wr_en        => s_pc_wr_en,   
            pc_sel       => s_pc_sel,     
            jump_addr_in => s_jump_addr,  
            pc_out       => s_pc_out      
        );

    inst_IR: instr_reg
        port map(
            clock    => clock,
            reset    => reset,
            wr_en    => s_ri_wr_en,  
            data_in  => s_rom_data, 
            data_out => s_ri_out     
        );

    inst_PSW: psw
        port map(
            clock    => clock,
            reset    => reset,
            wr_en    => s_psw_wr_en,  
            data_in  => s_flags_calc_bus, 
                
            isNegative => s_flag_N_reg, 
            carry      => s_flag_C_reg, 
            isZero     => s_flag_Z_reg  
        );

    inst_RAM: ram
        port map(
            clk      => clock,
            wr_en    => s_ram_wr_en,         
            
            address  => s_rb_out_a(6 downto 0), 
            data_in  => s_rb_out_b,          
            data_out => s_ram_data_out       
        );


    ----

    s_flags_calc_bus <= s_flag_Z_calc & s_flag_N_calc & s_flag_C_calc;


    -- Address decodification logic (for jumps and branches) 

    s_pc_branch_offset <= signed(s_ri_out(6 downto 0));
    
    s_pc_branch_target <= unsigned( signed(s_pc_out) + s_pc_branch_offset );


    s_jump_addr <= s_ri_out(6 downto 0) when (s_opcode_in = "0110") else -- JMP
                   s_pc_branch_target;  -- relative branches

    s_opcode_in <= s_ri_out(14 downto 11); 
    s_rb_addr_a <= s_ri_out(10 downto 7);  
    s_rb_addr_b <= s_ri_out(6 downto 3);   
    s_rb_addr_w <= s_ri_out(10 downto 7);

    s_imm(14 downto 7) <= (others => s_ri_out(6));
    s_imm(6 downto 0)  <= s_ri_out(6 downto 0);

    s_alu_in_b <= s_rb_out_b when s_mux_alu = '0' else
                  s_imm;

    s_rb_data_in <= s_alu_out when s_mux_rb = '0' else
                    s_ram_data_out; 

end architecture a_processor;