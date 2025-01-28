library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity resync_cntr is
    port(
        clk                         : in    std_logic                   := '0';
        rst_n                       : in    std_logic                   := '1';  
        sample_edge_i               : in    std_logic                   := '0';
        raw_data_edge_i             : in    std_logic                   := '0';
        resync_valid_o              : out   std_logic                   := '0'
    );
end entity;

architecture rtl of resync_cntr is

    type state_t is (resync_disable_s, resync_enable_s);

    signal current_state, new_state : state_t                           := resync_disable_s;
    signal resync_valid_s           : std_logic                         := '0';

begin

    resync_valid_o <= resync_valid_s;

    resync_cntr_p : process(current_state, sample_edge_i, raw_data_edge_i)
    begin 
        new_state <= current_state;
        resync_valid_s <= '0';

        case current_state is
            when resync_disable_s =>
                resync_valid_s <= '0';
                if sample_edge_i = '1' then
                    new_state <= resync_enable_s;
                end if;

            when resync_enable_s =>
                resync_valid_s <= '1';
                if raw_data_edge_i = '1' then
                    new_state <= resync_disable_s;
                end if;

            when others =>
                new_state <= resync_disable_s;
        end case;
    end process resync_cntr_p;

    p : process(clk)
    begin 
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then 
                current_state <= resync_disable_s;
            end if;
        end if;
    end process p;

end rtl ; -- rtl