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
        store_o                 : out   std_logic;
        store_err_o             : out   std_logic
    );
end entity axi_fifo_cntr;

architecture rtl of axi_fifo_cntr is

    type state_t    is (start_s, idle_s, error_s, transfer_s, wait_s);
    signal current_state, new_state     : state_t;

    signal ready_s          : std_logic;
    signal store_s          : std_logic;
    signal store_error_s    : std_logic;

begin

    ready_o         <= ready_s;
    store_o         <= store_s;
    store_err_o     <= store_error_s;

    sm_p : process(current_state, load_new_i, valid_i)
    begin 
        new_state           <= current_state;
        ready_s             <= '0';
        store_s             <= '0';
        store_error_s       <= '0';

        case current_state is
            when start_s =>
                if valid_i = '1' and load_new_i = '0' then 
                    new_state       <= idle_s;
                    store_s         <= '1';
                    store_error_s   <= '1';
                    ready_s         <= '1';
                elsif valid_i = '1' and load_new_i = '1' then  
                    new_state       <= transfer_s;
                    store_s         <= '1';
                    ready_s         <= '1';
                end if;

            
            

            when idle_s =>
                if valid_i = '1' and load_new_i = '1' then
                    new_state       <= transfer_s;
                    store_s         <= '1';
                    ready_s         <= '1';
                elsif valid_i = '0' and load_new_i = '1' then
                    new_state       <= error_s;
                    store_s         <= '1';
                    store_error_s   <= '1';
                end if;

            when error_s =>
                new_state <= wait_s;

            when transfer_s => 
                new_state <= wait_s;
            
            when wait_s =>
                if load_new_i = '0' then
                    new_state <= idle_s;
                end if;

            when others => 
                new_state <= start_s;

        end case;
    end process sm_p;

    clk_p : process(clk)
    begin 
        if rising_edge(clk) then
            current_state <= new_state;
            if rst_n = '0' then
                current_state <= start_s;
            end if;
        end if;
    end process clk_p;

end rtl ;