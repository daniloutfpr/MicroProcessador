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
   process(clock,reset)
   begin
      if reset='1' then
         state_s <= "00";
      elsif rising_edge(clock) then
         if state_s="10" then        -- se agora esta em 2
            state_s <= "00";         -- o prox vai voltar ao zero
         else
            state_s <= state_s+1;   -- senao avanca
         end if;
      end if;
   end process;
   state <= state_s;
end architecture;