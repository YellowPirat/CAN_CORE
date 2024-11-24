library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity valid_cntr is 
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        bus_active_i        : in    std_logic;
        frame_finished_i    : in    std_logic;

        valid_o             : out   std_logic
    );
end entity;

architecture rtl of valid_cntr is

    type state_t is( idle_s, bus_was_active_s);
    signal current_state, new_state : state_t;

    signal valid_s          : std_logic;
begin

    valid_o                 <= valid_s;

    valid_p : process(current_state, bus_active_i, frame_finished_i)
    begin
        valid_s             <= '0';

        case current_state is
            when idle_s =>
                if frame_finished_i = '1'then
                    new_state   <= bus_was_active_s;
                end if;

            when bus_was_active_s =>
                if bus_active_i = '0'then
                    valid_s     <= '1';
                end if;
            
            when others =>
                new_state       <= idle_s;

        end case;
    end process valid_p;

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