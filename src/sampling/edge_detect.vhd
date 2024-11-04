library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edge_detect is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;
        data_i              : in    std_logic;
        edge_detect_o       : out    std_logic
    );
end entity;

architecture rtl of edge_detect is

    type state_t is (idle_s, change_s);
    signal current_state, new_state : state_t;
    signal edge_s           : std_logic;

begin

    edge_detect_o <= edge_s;

    edge_detect_p : process(current_state, data_i)
    begin 
        new_state <= current_state;
        edge_s <= '0';
        
        case current_state is 
            when idle_s => 
                if data_i = '1' then
                    new_state <= change_s;
                    edge_s <= '1';
                end if;
            when change_s =>
                if data_i = '0' then
                    new_state <= idle_s;
                    edge_s <= '1';
                end if;
            when others => 
                new_state <= idle_s;
        end case;
    end process edge_detect_p;

    current_state <= idle_s when rst_n = '0' else new_state when rising_edge(clk);


end architecture;