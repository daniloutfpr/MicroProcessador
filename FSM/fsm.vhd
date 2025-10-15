library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_state is 
    port(
        clock: in std_logic;--first clock fetch , second decode/execute
        reset: in std_logic;
        state: out std_logic;
    );
end entity;

architecture behavorial of fsm_state is 
signal state_s: std_logic := '0';-- (0-fetch , 1-execute)
    process(reset,clock)
    begin 
        if reset = '1' then 
            state_s <= '0';
        elsif rising_edge(clock) then 
            state_s <= not state_s;
        end if 
    end process;
    state <= state_s;
end architecture;

