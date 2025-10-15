library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port(
        clk: in std_logic;
        adrees: in unsigned(6 downto 0); 
        data : out unsigned(14 downto 0)
    );
end entity;

architecture a_rom of rom is 
    type mem is array (0 to 127) of unsigned (14 downto 0);
    constant rom_content : mem := (
      -- adress => content
      0  => "000000000000000", --nop
      1  => "111100000001010", --jump 10
      

      others => (others => '0')
    );
begin 
    process(clk)
    begin 
        if(rising_edge(clk)) then 
            data <= rom_content(to_integer(adrees));
        end if;
    end process;
end architecture;