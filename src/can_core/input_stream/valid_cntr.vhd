library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity valid_cntr is 
    port (
        clk                             : in    std_logic                               := '0';
        rst_n                           : in    std_logic                               := '1';
        bus_active_i                    : in    std_logic                               := '0';
        frame_finished_i                : in    std_logic                               := '0';
        valid_o                         : out   std_logic                               := '0'
    );
end entity;

architecture rtl of valid_cntr is

    type state_t is( idle_s, bus_active_s, frame_finished_s, valid_s);
    signal current_state, new_state     : state_t                                       := idle_s;

    signal frame_valid_s                : std_logic                                     := '0';
begin

    valid_o                 <= frame_valid_s;

    valid_p : process(current_state, bus_active_i, frame_finished_i)
    begin
			new_state               <= current_state;
        frame_valid_s             <= '0';

        case current_state is
            when idle_s =>
                if bus_active_i = '1' and frame_finished_i = '0'then
                    new_state <= bus_active_s;
                end if;

            when bus_active_s =>
                if bus_active_i = '1' and frame_finished_i = '1' then
                    new_state <= frame_finished_s;
                end if;

            when frame_finished_s =>
                if bus_active_i = '0' and frame_finished_i = '0' then 
                    new_state <= valid_s;
                end if;

            when valid_s => 
                if bus_active_i = '1' and frame_finished_i = '0' then
                    new_state <= bus_active_s;
                end if;
					 frame_valid_s <= '1';

            
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