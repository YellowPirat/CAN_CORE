library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity uart_cntr is 
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        data_valid_i        : in    std_logic;
        uart_ready_i        : in    std_logic;
        done_i              : in    std_logic;
        
        uart_valid_o        : out   std_logic;

        cnt_en_o            : out   std_logic;
        reload_o            : out   std_logic;
        lf_o                : out   std_logic;
        rl_o                : out   std_logic
    );
end entity;

architecture rtl of uart_cntr is
    type state_t is (idle_s, write_uart_s, wait_uart_s, wait_lf_s, write_lf_s, done_s, wait_rl_s, write_rl_s);
    signal current_state, new_state : state_t;

    signal uart_valid_s     : std_logic;
    signal cnt_en_s         : std_logic;
    signal reload_s         : std_logic;
    signal lf_s             : std_logic;
    signal rl_s             : std_logic;


begin

    uart_valid_o            <= uart_valid_s;
    cnt_en_o                <= cnt_en_s;
    reload_o                <= reload_s;
    lf_o                    <= lf_s;
    rl_o                    <= rl_s;


    uart_cntr_p : process(current_state, data_valid_i, uart_ready_i, done_i)
    begin
        new_state           <= current_state;
        uart_valid_s        <= '0';
        cnt_en_s            <= '0';
        reload_s            <= '0';
        lf_s                <= '0';
        rl_s                <= '0';

        case current_state is
            when idle_s =>
                if data_valid_i = '1' and uart_ready_i = '1' then
                    new_state       <= write_uart_s;
                    uart_valid_s    <= '1';
                elsif data_valid_i = '1' and uart_ready_i = '0' then
                    new_state       <= wait_uart_s;
						  
                end if;

            when wait_uart_s =>
                if data_valid_i = '1' and uart_ready_i = '1' then
                    new_state       <= write_uart_s;
                    uart_valid_s    <= '1';
                elsif data_valid_i = '0' then
                    new_state       <= idle_s;
                    reload_s        <= '1';
                end if;

            when write_uart_s =>
                if data_valid_i = '0' then
                    new_state       <= idle_s;
                    reload_s        <= '1';
                elsif done_i = '1' then
                    cnt_en_s        <= '1';
                    new_state       <= wait_lf_s;
                else
                    new_state       <= wait_uart_s;
                    cnt_en_s        <= '1';
                end if;

            when wait_lf_s => 
                if data_valid_i = '1' and uart_ready_i = '1' then
                    uart_valid_s    <= '1';
                    lf_s            <= '1';
                    new_state       <= write_lf_s;
                end if;

            when write_lf_s =>
                new_state           <= wait_rl_s;

            when wait_rl_s => 
                if data_valid_i = '1' and uart_ready_i = '1' then
                    uart_valid_s    <= '1';
                    rl_s            <= '1';
                    new_state       <= write_rl_s;
                end if;

            when write_rl_s => 
                new_state           <= done_s;

            when done_s =>
                if data_valid_i = '0' then
                    new_state       <= idle_s;
                    reload_s        <= '1';
                end if;

            when others =>
                new_state           <= idle_s;

        end case;
    end process uart_cntr_p;

    p : process(clk)
    begin
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then
						current_state <= idle_s;
            end if;
        end if;
    end process p;


end rtl;