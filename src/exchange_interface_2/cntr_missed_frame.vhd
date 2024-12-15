library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cntr_missed_frame is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        bus_active_i        : in    std_logic;
        can_valid_i         : in    std_logic;
        fifo_ready_i        : in    std_logic;

        cnt_missed_frame_o  : out   std_logic
    );
end entity cntr_missed_frame;

architecture rtl of cntr_missed_frame is

    type state_t    is (active_s, idle_s, valid_s, stored_s);
    signal current_state, new_state     : state_t;

    signal cnt_missed_frame_s       : std_logic;

begin

    cnt_missed_frame_o <= cnt_missed_frame_s;

    sm_p : process(current_state, bus_active_i, can_valid_i, fifo_ready_i)
    begin 
        new_state               <= current_state;
        cnt_missed_frame_s      <= '0';

        case current_state is
            when active_s =>
                if bus_active_i = '1' then
                    new_state <= idle_s;
                end if;

            when idle_s =>
                if can_valid_i = '1' and fifo_ready_i = '0' then 
                    new_state <= valid_s;
                elsif can_valid_i = '1' and fifo_ready_i = '1' then
                    new_state <= stored_s;
                end if;

            when stored_s => 
                if bus_active_i = '1' then
                    new_state <= active_s;
                end if;

            when valid_s => 
                if bus_active_i = '1' and fifo_ready_i = '0' then
                    new_state <= active_s;
                    cnt_missed_frame_s <= '1';
                elsif bus_active_i = '1' and fifo_ready_i = '1' then
                    new_state <= active_s;
                end if;

            when others =>
                new_state <= idle_s;

        end case;

    end process;

    clk_p : process(clk)
    begin 
        if rising_edge(clk) then
            current_state <= new_state;
            if rst_n = '0' then
                current_state <= active_s;
            end if;
        end if;
    end process clk_p;

end rtl ; -- rtl