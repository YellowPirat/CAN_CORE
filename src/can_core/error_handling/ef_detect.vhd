library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ef_detect is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_i                   : in    std_logic;
        sample_i                : in    std_logic;
        enable_i                : in    std_logic;

        pe_dec_o                : out   std_logic;
        pe_cnt_done_i           : in    std_logic;
        pe_cnt_i                : in    unsigned(2 downto 0);

        ae_dec_o                : out   std_logic;
        ae_cnt_done_i           : in    std_logic;
        ae_cnt_i                : in    unsigned(2 downto 0);

        ed_dec_o                : out   std_logic;
        ed_cnt_done_i           : in    std_logic;

        eof_detect_o            : out   std_logic;
        reload_o                : out   std_logic
    );
end entity;

architecture rtl of ef_detect is

    type state_t is(
        idle_s,
        passive_error_s,
        active_error_s,
        error_del_s,
        error_s,
        if_s
    );

    signal current_state, new_state : state_t;

    signal eof_detect_s             : std_logic;

    signal pe_dec_s                 : std_logic;
    signal ae_dec_s                 : std_logic;
    signal ed_dec_s                 : std_logic;
    signal reload_s                 : std_logic;

begin

    eof_detect_o                <= eof_detect_s;
    reload_o                    <= reload_s;
    pe_dec_o                    <= pe_dec_s;
    ae_dec_o                    <= ae_dec_s;
    ed_dec_o                    <= ed_dec_s;


    eof_detect_p : process(current_state, rxd_i, sample_i, enable_i, pe_cnt_done_i, ae_cnt_done_i, ed_cnt_done_i)
    begin
        new_state               <= current_state;
        eof_detect_s            <= '0';
        pe_dec_s                <= '0';
        ae_dec_s                <= '0';
        ed_dec_s                <= '0';
        reload_s                <= '0';

        case current_state is
            when idle_s =>
                
                if sample_i = '1' and enable_i = '1' then
                    new_state   <= passive_error_s;
                end if;

            when passive_error_s => 
                if enable_i = '1' then
                    if pe_cnt_done_i = '0' and sample_i = '1' then
                        if pe_cnt_i = 6 then
                            pe_dec_s            <= '1';
                        else
                            if rxd_i = '0' then
                                pe_dec_s        <= '1';
                            else 
                                new_state       <= error_s;
                            end if;
                        end if;
                    elsif pe_cnt_done_i = '1' and sample_i = '1' then
                        if rxd_i = '1' then
                            new_state       <= error_del_s;
                        else 
                            new_state       <= active_error_s;
                        end if;
                    end if;
                else 
                    new_state       <= if_s;
                    
                end if;

            when active_error_s => 
                if enable_i = '1' then
                    if ae_cnt_done_i = '0' and sample_i = '1' then
                        if ae_cnt_i = 6 then
                            ae_dec_s        <= '1';
                        else
                            if rxd_i = '0' then
                                ae_dec_s    <= '1';
                            else
                                new_state   <= error_del_s;
                            end if;
                        end if;
                    elsif ae_cnt_done_i = '1' and sample_i = '1' then
                        new_state       <= error_del_s;
                    end if;
                else 
                    new_state       <= if_s;
                end if; 

            when error_del_s =>
                if enable_i = '1' then
                    if ed_cnt_done_i = '0' and sample_i = '1' then
                        ed_dec_s        <= '1';
                    elsif ed_cnt_done_i = '1' and sample_i = '1' then
                        new_state       <= if_s;
                        
                    end if;
                else 
                    new_state       <= if_s;
                end if; 

            when if_s => 
                new_state           <= idle_s;
                eof_detect_s        <= '1';
                reload_s            <= '1';

            when error_s => 
                new_state           <= if_s;
          

            when others =>
                    new_state       <= idle_s;

        end case;
    end process eof_detect_p;

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