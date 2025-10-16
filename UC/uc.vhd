library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UC is 
    port(
        clock: in std_logic;
        reset: in std_logic;
        pc_out: out unsigned(6 downto 0);  -- PC address to ROM
        instr_out: out unsigned(14 downto 0)  -- Current instruction
    );
end entity;

architecture a_UC of UC is 
    signal opcode: unsigned(3 downto 0);
    signal state_s: std_logic;
    signal jump_en: std_logic;
    signal pc_wr_en: std_logic;
    signal current_instr: unsigned(14 downto 0);
    signal pc_current: unsigned(14 downto 0);
    signal pc_next: unsigned(14 downto 0);
    signal pc_incremented: unsigned(14 downto 0);
    signal rom_data: unsigned(14 downto 0);

    component fsm_state
        port(
            clock: in std_logic;
            reset: in std_logic;
            state: out std_logic
        );
    end component;

    component rom
        port(
            clk: in std_logic;
            adrees: in unsigned(6 downto 0); 
            data : out unsigned(14 downto 0)
        );
    end component;

    component ProgramCounter
        port(
            clock: in std_logic;
            reset: in std_logic;
            wr_en: in std_logic;
            instr_in: in unsigned(14 downto 0); 
            instr_out: out unsigned(14 downto 0)
        );
    end component;

    component SumEntity
        port(
            data_in: in unsigned(14 downto 0); 
            data_out: out unsigned(14 downto 0)
        );
    end component;

begin 

    -- State machine instance
    inst_fsm: fsm_state
        port map(
            clock => clock,
            reset => reset,
            state => state_s
        );

    -- Program Counter instance
    inst_pc: ProgramCounter
        port map(
            clock => clock,
            reset => reset,
            wr_en => pc_wr_en,
            instr_in => pc_next,
            instr_out => pc_current
        );

    -- ROM instance
    inst_rom: rom
        port map(
            clk => clock,
            adrees => pc_current(6 downto 0),  -- Use lower 7 bits as address
            data => rom_data
        );

    -- Sum Entity instance for PC increment
    inst_sum: SumEntity
        port map(
            data_in => pc_current,
            data_out => pc_incremented
        );

    -- Extract opcode from current instruction
    opcode <= current_instr(14 downto 11);

    -- Control logic
    jump_en <= '1' when opcode = "1111" else '0';
    pc_wr_en <= '1'; -- Always enable PC write (it will be controlled by clock)

    -- Next PC calculation (jump or increment)
    pc_next <= current_instr when (jump_en = '1' and state_s = '1') else pc_incremented;

    -- Instruction register logic (fetch on state 0)
    process(clock, reset)
    begin
        if reset = '1' then
            current_instr <= (others => '0');
        elsif rising_edge(clock) then
            if state_s = '0' then  -- Fetch state
                current_instr <= rom_data;
            end if;
        end if;
    end process;

    -- Outputs
    pc_out <= pc_current(6 downto 0);
    instr_out <= current_instr;

end architecture;
