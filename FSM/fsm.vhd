library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity fsm_state is
   port( clock,reset: in std_logic;
         state: out unsigned(1 downto 0)
   );
end entity;
architecture a_fsm_state of fsm_state is
   signal state_s: unsigned(1 downto 0);
begin

   -- PROCESSOR STATES:
   -- 00 = Instruction Fetch
   -- 01 = Instruction Decode
   -- 10 = Execute / Write back
   process(clock,reset)
   begin
      if reset='1' then
         state_s <= "00";           
      elsif rising_edge(clock) then
         if state_s="10" then        -- if it's in the last state
            state_s <= "00";         -- the next is the first again (00)
         else
            state_s <= state_s+1;   -- else, goes to next state
         end if;
      end if;
   end process;
   state <= state_s;
end architecture;