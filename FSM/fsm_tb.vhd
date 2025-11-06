library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_tb is 
end entity;

architecture sim of fsm_tb is
    signal clk    : std_logic := '0';
    signal reset  : std_logic := '1';
    signal state : std_logic;

    component fsm_estado
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            state : out std_logic
        );
    end component;

begin
    uut: fsm_estado
        port map (
            clk => clk,
            reset => reset,
            state => state
        );

    --  clock  10 ns
    clk_process: process
    begin
        while now < 100 ns loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

    -- reset  
    reset_process: process
    begin
        reset <= '1'; wait for 10 ns;
        reset <= '0'; wait;
    end process;

end architecture;

