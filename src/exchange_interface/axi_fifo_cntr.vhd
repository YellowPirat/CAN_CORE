library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_fifo_cntr is 
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        load_new_i              : in    std_logic;
        valid_i                 : in    std_logic;

        ready_o                 : out   std_logic;
        store_o                 : out   std_logic
    );
end entity axi_fifo_cntr;

architecture rtl of axi_fifo_cntr is

    type state_t    is (idle_s, new_frame_received_s, wait_axi_read_s);
    signal current_state, new_state     : state_t;

    signal ready_s          : std_logic;
    signal store_s          : std_logic;

begin

    ready_o         <= ready_s;
    store_o         <= store_s;

    sm_p : process(current_state, load_new_i, valid_i)
    begin 
        new_state           <= current_state;
        ready_s             <= '0';
        store_s             <= '0';

        case current_state is

            when idle_s =>
                if valid_i = '1' then
                    new_state       <= new_frame_received_s;
                    ready_s         <= '1';
                    store_s         <= '1';
                end if;
            
            when new_frame_received_s =>
                new_state           <= wait_axi_read_s;
            
            when wait_axi_read_s =>
                if load_new_i = '1' and valid_i = '0' then
                    new_state       <= idle_s;
                    ready_s         <= '1';
                    store_s         <= '1';
                elsif load_new_i = '1' and valid_i = '1' then
                    new_state       <= new_frame_received_s;
                    ready_s         <= '1';
                    store_s         <= '1';
                end if;             




            when others => 
                new_state <= idle_s;

        end case;
    end process sm_p;

    clk_p : process(clk)
    begin 
        if rising_edge(clk) then
            current_state <= new_state;
            if rst_n = '0' then
                current_state <= idle_s;
            end if;
        end if;
    end process clk_p;

end rtl ;