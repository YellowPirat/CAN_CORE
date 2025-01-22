library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crc_state_machine is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        enable_i                : in    std_logic;

        enable_crc_o            : out   std_logic
    );
end entity;

architecture rtl of crc_state_machine is

    type state_t is (idle_s, calculate_crc_s);
    signal current_state, new_state : state_t;

begin

    crc_calculation_p : process(current_state, enable_i)
    begin
        new_state <= current_state;
        enable_crc_o <= '0';

        case current_state is
            when idle_s =>
                if enable_i = '1' then
                    new_state <= calculate_crc_s;
                else
                    new_state <= idle_s;
                end if;

            when calculate_crc_s =>
                if enable_i = '1' then
                    new_state <= calculate_crc_s;
                    enable_crc_o <= '1';
                else
                    new_state <= idle_s;
                    enable_crc_o <= '0';
                end if;

            when others =>
                new_state <= idle_s;
        end case;
    end process crc_calculation_p;

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