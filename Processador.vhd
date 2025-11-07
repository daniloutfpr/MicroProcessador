library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Processor top-level entity
entity processor is
    port (
        clock           : in std_logic;
        reset           : in std_logic
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
            sel_op : in unsigned(1 downto 0);
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
    
            pc_sel:       in  std_logic; -- Mux (Jump or Pc+1)
            jump_addr_in: in  unsigned (6 downto 0); 

            pc_out:       out unsigned (6 downto 0)
        );
    end component;

    component rom is
        port(
            clk: in std_logic;
            adrees: in unsigned(6 downto 0); 
            data : out unsigned(14 downto 0)
        );
    end component;

    component UC is 
        port(
            clock: in std_logic;
            reset: in std_logic;
            opcode: in unsigned (3 downto 0); --[14-11] instructionS
            
            --Wr_en
            pc_wr_en: out std_logic;  -- Enables program counter writing
            ri_wr_en: out std_logic;  -- write on instruction register 
            rb_wr_en: out std_logic;  -- write on RegisterBank
            psw_wr_en: out std_logic; -- write on psw register
            
            --Flags (from PSW)
            isNegative: in std_logic;
            carry: in std_logic;
            isZero: in std_logic;

            --Mux
            pc_sel  : out std_logic;
            mux_alu: out std_logic; --register b or ctc
            mux_rb : out std_logic;-- alu out or data in
            alu_op : out unsigned(1 downto 0)
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

    -- Internal signals

    signal s_pc_wr_en   : std_logic; 
    signal s_ri_wr_en   : std_logic; 
    signal s_rb_wr_en   : std_logic; 
    signal s_psw_wr_en  : std_logic;
    signal s_pc_sel     : std_logic; 
    signal s_mux_alu    : std_logic; 
    signal s_mux_rb     : std_logic; 
    signal s_alu_op     : unsigned(1 downto 0);

    -- ALU -> PSW
    signal s_flag_N_calc : std_logic;           
    signal s_flag_Z_calc : std_logic;
    signal s_flag_C_calc : std_logic;
    signal s_flags_calc_bus : unsigned(2 downto 0); -- 3 bits bus

    -- PSW -> UC
    signal s_flag_N_reg : std_logic;
    signal s_flag_Z_reg : std_logic;
    signal s_flag_C_reg : std_logic;

    -- Branch address calculation
    signal s_pc_branch_offset : signed(6 downto 0);   -- C2 Instruction offset 
    signal s_pc_branch_target : unsigned(6 downto 0); -- Target address (PC + Offset)

    signal s_pc_out     : unsigned(6 downto 0);  -- 7 bits (PC -> ROM)
    signal s_rom_data   : unsigned(14 downto 0); -- 15 bits (ROM -> RI)
    signal s_ri_out     : unsigned(14 downto 0); -- 15 bits (Saída "travada" do RI)
    
    signal s_rb_out_a   : unsigned(14 downto 0); -- 15 bits (RB out A -> ALU)
    signal s_rb_out_b   : unsigned(14 downto 0); -- 15 bits (RB out B -> MUX ALU)
    signal s_alu_in_b   : unsigned(14 downto 0); -- 15 bits (MUX ALU -> ALU)
    signal s_alu_out    : unsigned(14 downto 0); -- 15 bits (ALU -> MUX RB)
    signal s_rb_data_in : unsigned(14 downto 0); -- 15 bits (MUX RB -> RB)

    signal s_opcode_in  : unsigned(3 downto 0);  -- 4 bits (RI -> UC)
    signal s_rb_addr_a  : unsigned(3 downto 0);  -- 4 bits (RI -> RB)
    signal s_rb_addr_b  : unsigned(3 downto 0);  -- 4 bits (RI -> RB)
    signal s_rb_addr_w  : unsigned(3 downto 0);  -- 4 bits (RI -> RB)
    signal s_imm   : unsigned(14 downto 0); -- 15 bits (RI -> MUX ALU)
    signal s_jump_addr  : unsigned(6 downto 0);  -- 7 bits (RI -> PC)

begin
      

    inst_RB: RegisterBank
        port map(
            clock    => clock,
            reset    => reset,
            wr_en    => s_rb_wr_en,     -- UC (state "10")
            data_in  => s_rb_data_in,   
            reg_sel_a=> s_rb_addr_a,    -- RI
            reg_sel_b=> s_rb_addr_b,    -- RI
            wr_addr  => s_rb_addr_w,    -- RI
            data_out_a => s_rb_out_a,   -- ALU ent0
            data_out_b => s_rb_out_b    -- MUX_ALU
        );

    -- ALU instantiation
    inst_ALU: ALU
        port map(
            ent0 => s_rb_out_a,   
            ent1 => s_alu_in_b,   
            sel_op => s_alu_op,   
            alu_out => s_alu_out,  
            
            
            carry => s_flag_C_calc, -- ALU => PSW
            zero => s_flag_Z_calc, -- ALU => PSW
            isNegative => s_flag_N_calc -- ALU => PSW
        );
    
    inst_ROM: rom
        port map(
            clk    => clock,      
            adrees => s_pc_out,   
            data   => s_rom_data 
        );
    
    inst_UC: UC
        port map(
            clock => clock,
            reset => reset,
            opcode => s_opcode_in, -- RI [14-11]

            isNegative => s_flag_N_reg, -- PSW => UC
            isZero => s_flag_Z_reg, -- PSW => UC
            carry => s_flag_C_reg, -- PSW => UC

            psw_wr_en => s_psw_wr_en,
            pc_wr_en => s_pc_wr_en,
            ri_wr_en => s_ri_wr_en,
            rb_wr_en => s_rb_wr_en,
            pc_sel   => s_pc_sel,
            mux_alu  => s_mux_alu,
            mux_rb   => s_mux_rb,
            alu_op   => s_alu_op
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
            wr_en    => s_ri_wr_en,  -- UC (state "00")
            data_in  => s_rom_data, 
            data_out => s_ri_out     
        );

    inst_PSW: psw
        port map(
            clock    => clock,
            reset    => reset,
            wr_en    => s_psw_wr_en,  -- from UC
            data_in  => s_flags_calc_bus, -- from ALU
                
            isNegative => s_flag_N_reg, -- => UC
            carry      => s_flag_C_reg, -- => UC
            isZero     => s_flag_Z_reg  -- => UC
        );

    ----

    s_flags_calc_bus <= s_flag_Z_calc & s_flag_N_calc & s_flag_C_calc;


    -- Address decodification logic (for jumps and branches) 

    -- 1.  Calculation of the relative branch address (2 complement)
    --    Converts the 7 bits offset from the instruction to signed (2 complement)
    s_pc_branch_offset <= signed(s_ri_out(6 downto 0));
    
    --    Sums the current PC (unsigned to signed) with the offset (signed)
    s_pc_branch_target <= unsigned( signed(s_pc_out) + s_pc_branch_offset );


    --    Branch address MUX (selects the value that goes to PC)
    --    If JMP (0110),uses the absolute address (bits 6:0)
    --    If BLS/BPL (0111/1000), uses the relative address (PC + offset)
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
                    (others => '0');
 
end architecture a_processor;
