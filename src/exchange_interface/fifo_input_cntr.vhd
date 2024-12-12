library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_input_cntr is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        frame_valid_i       : in    std_logic;
        fifo_ready_i        : in    std_logic;
        frame_valid_o       : out   std_logic;

        frame_missed_o      : out   std_logic
    );
end entity;

architecture rtl of fifo_input_cntr is

    type state_t is (idle_s, can_frame_valid_s, wait_new_can_frame_s);
    signal current_state, new_state : state_t;

    signal frame_valid_s            : std_logic;
    signal frame_missed_s           : std_logic;

begin

    frame_valid_o           <= frame_valid_s;
    frame_missed_o          <= frame_missed_s;

    fifo_input_cntr_p : process(current_state, frame_valid_i, fifo_ready_i)
    begin 
        new_state           <= current_state;
        frame_valid_s       <= '0';
        frame_missed_s      <= '0';

        case current_state is
            when idle_s =>
                if frame_valid_i = '1' and fifo_ready_i = '0' then
                    new_state           <= can_frame_valid_s;
                elsif frame_valid_i = '1' and fifo_ready_i = '1' then
                    frame_valid_s       <= '1';
                    new_state           <= wait_new_can_frame_s;
                end if;

            when can_frame_valid_s => 
                if frame_valid_i = '1' and fifo_ready_i = '1' then
                    frame_valid_s       <= '1';
                    new_state           <= wait_new_can_frame_s;
                elsif frame_valid_i = '0' and fifo_ready_i = '0' then
                    new_state           <= idle_s;
                end if;

            when wait_new_can_frame_s =>

                if frame_valid_i = '0' then
                    new_state           <= idle_s;
                end if;

            when others =>
                new_state               <= idle_s;
        end case;
    end process fifo_input_cntr_p;

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