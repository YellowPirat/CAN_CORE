library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity destuffing_cntr is
    port (
        clk                         : in    std_logic                           := '0';
        rst_n                       : in    std_logic                           := '1';
        enable_i                    : in    std_logic                           := '0';
        disable_destuffing_i        : in    std_logic                           := '0';
        stuff_error_i               : in    std_logic                           := '0';
        enable_destuffing_o         : out   std_logic                           := '0';
        reload_destuffing_o         : out   std_logic                           := '0'
    );
end entity;

architecture rtl of destuffing_cntr is

    type state_t is(
        idle_s,
        destuffing_enable_s,
        destuffing_disable_s,
        wait_bus_inactive_s
    );

    signal current_state, new_state : state_t                                   := idle_s;

    signal enable_destuffing_s      : std_logic                                 := '0';
    signal reload_destuffing_s      : std_logic                                 := '0';

begin

    enable_destuffing_o         <= enable_destuffing_s;
    reload_destuffing_o         <= reload_destuffing_s;

    destuffing_cntr_p : process(current_state, enable_i, disable_destuffing_i, stuff_error_i)
    begin
        new_state               <= current_state;
        enable_destuffing_s     <= '0';
        reload_destuffing_s     <= '0';

        case current_state is 
            when idle_s =>
                if enable_i = '1' then
                    new_state               <= destuffing_enable_s;
                    enable_destuffing_s     <= '1';
                end if;

            when destuffing_enable_s =>
                
                if disable_destuffing_i = '1' or stuff_error_i = '1' then
                    new_state               <= wait_bus_inactive_s;
                else
                    enable_destuffing_s     <= '1';
                end if;

            when wait_bus_inactive_s =>
                if enable_i = '0' then 
                    new_state               <= destuffing_disable_s;
                end if;

            when destuffing_disable_s =>
                if enable_i = '1' and disable_destuffing_i = '1' then
                    new_state               <= destuffing_enable_s;
                end if;

            when others =>
                new_state <= idle_s;
        end case;
    end process destuffing_cntr_p;


    p : process(clk)
    begin
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then
                current_state <= idle_s;
            end if;
        end if;
    end process p;

end rtl ; -- rtl