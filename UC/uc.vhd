library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
---- Control of Muxes , write enables , etc...
entity UC is 
    port(
        clock: in std_logic;
        reset: in std_logic;
        opcode: in unsigned (3 downto 0); --[14-11] instructionS
        
        --Flags (from PSW)
        isNegative: in std_logic;
        carry: in std_logic;
        isZero: in std_logic;

        --Wr_en
        pc_wr_en: out std_logic;    -- enables write on Program Counter
        ri_wr_en: out std_logic;    -- write on instruction register 
        rb_wr_en: out std_logic;    -- write on RegisterBank
        psw_wr_en: out std_logic;   -- write on Processor Store Word register (for flags)
        
        --Mux
        pc_sel  : out std_logic;
        mux_alu: out std_logic; --register b or ctc
        mux_rb : out std_logic;-- alu out or data in
        alu_op : out unsigned(1 downto 0)
        
    );
end entity; 

architecture a_UC of UC is 
    signal state_s: unsigned(1 downto 0);

    signal take_branch: std_logic; -- Decides if should branch (conditional or inconditional)

    signal jump: std_logic;
    component fsm_state
        port(
            clock: in std_logic;
            reset: in std_logic;
            state: out unsigned(1 downto 0)
        );
    end component;
  
begin 

    instance_fsm: fsm_state
            port map(
                clock => clock,
                reset => reset,
                state => state_s
            );

    take_branch <= '1' when (opcode = "0110") or -- jump instruction (JMP)
                        (opcode = "0111" and (carry = '1' or isZero = '1')) or -- branch if lower or same (BLS)
                        (opcode = "1000" and isNegative = '0') -- branch if positive of zero (BPL)
                    else '0';

    ri_wr_en <= '1' when (state_s = "00") else
                '0';

    jump <= '1' when (opcode ="0110")  -- opcode jump 0110
                     else '0'; 
                     
    pc_wr_en <= '1' when (state_s = "01")
                else '0';

    pc_sel <= '1' when (state_s = "01" and take_branch = '1')
              else '0';

    -- Only enables writing in the psw when there's an operation that will change the flags value
    psw_wr_en <= '1' when(state_s = "10" and
                    (opcode = "0011" or      -- ADD opcode
                     opcode = "0100" or      -- SUB opcode
                     opcode = "0101"))       -- ADDI opcode
                    else '0';

    -- Only enables writing in the registers for the operations that actually need to do it 
    rb_wr_en <= '1' when (state_s = "10") and 
                         (opcode = "0001" or  -- CLR
                          opcode = "0010" or  -- MOV
                          opcode = "0011" or  -- ADD
                          opcode = "0100" or  -- SUB
                          opcode = "0101")    -- ADDI
                         else '0';

    mux_alu <= '1' when (opcode = "0101") -- ADDI
               else '0';
               
    mux_rb <= '0'; -- always select alu out

    alu_op <= "00" when (opcode = "0011" or opcode = "0101") else -- ADD, ADDI
              "01" when (opcode = "0100") else                   -- SUB
              "10" when (opcode = "0010") else                   -- MOV (Passa B)
              "11" when (opcode = "0001") else                   -- CLR (Gera 0)
              "00";




end architecture;
