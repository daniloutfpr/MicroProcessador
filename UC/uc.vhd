library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UC is 
    port(
        instr: in unsigned (14 downto 0);
        clock: in std_logic;
        reset: in std_logic;
        jump_en: out std_logic;
        pc_wr_en: out std_logic

    );
end entity;

architecture a_UC of  UC is 
    signal opcode: unsigned(3 downto 0);
    signal state_s: std_logic;

    component fsm_state
        port(
            clock: in std_logic;
            reset: in std_logic;
            state: out std_logic
        );
    end component;

begin 

     --State machine
    inst_fsm: fsm_state
        port map(
            clock => clock,
            reset => reset,
            state => state_s
        );
    
    opcode  <= instr(14 downto 11);

    jump_en  <= '1' when opcode = "1111" else '0';

    pc_wr_en <= '1' when state_s = '1' else '0';

end architecture;
    