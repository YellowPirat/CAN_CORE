library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity idle_detect is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;
        frame_end_i         : in    std_logic;
        edge_i              : in    std_logic;
        hard_reload_o       : out   std_logic
    );
end entity;

architecture rtl of idle_detect is

    type state_t is (idle_s, active_s);
    signal current_state, new_state : state_t;

    signal reload_s      : std_logic := '0';

begin

    hard_reload_o <= reload_s;

    idle_detect_p : process(current_state, edge_i, frame_end_i)
    begin 
        new_state <= current_state;
        reload_s <= '0';
        
        case current_state is 
            when idle_s => 
                if edge_i = '1' then
                    reload_s <= '1';
                    new_state <= active_s;
                end if;
            when active_s =>
                if frame_end_i = '1' then
                    new_state <= idle_s;
                end if;

            when others => 
                new_state <= idle_s;
        end case;
    end process idle_detect_p;

    p : process(clk)
    begin
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then
                current_state <= idle_s;
            end if;
        end if;
    end process p;

end architecture;