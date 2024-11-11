library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sample_cnt is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;
        reload_i            : in    std_logic;
        hard_reload_i       : in    std_logic;
        sync_enable_i       : in    std_logic;
        sample_o            : out   std_logic
    );
end entity;

architecture rtl of sample_cnt is

    type state_t is(sync_seg_s, prob_seg_s, resync_p_s, phase_sig_one_s, phase_sig_two_s, resync_n_s);
    signal current_state, new_state : state_t;

    signal reload_value_s           : unsigned(5 downto 0);

    signal done_s                   : std_logic;
    signal cnt_s                    : unsigned(5 downto 0);
    signal reload_quantum_s         : std_logic;

    signal phase_cnt_s              : unsigned(5 downto 0);
    signal store_s                  : std_logic;

    signal sample_s                 : std_logic;

begin

    sample_o <= sample_s;

    quantum_cnt_i0 : entity work.quantum_cnt
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            reload_value_i          => reload_value_s,
            reload_i                => reload_quantum_s,

            done_o                  => done_s,
            cnt_o                   => cnt_s
        );

    phase_p : process(clk)
    begin 
        if rising_edge(clk) then
            if store_s = '1' then
                phase_cnt_s <= cnt_s;
            end if;

            if rst_n = '0' then
                phase_cnt_s <= to_unsigned(0, phase_cnt_s'length);
            end if;
        end if;
    end process;

    sampling_p : process(current_state, reload_i, hard_reload_i, done_s, sync_enable_i)
    begin 
        new_state <= current_state;
        reload_value_s <= to_unsigned(0, reload_value_s'length);
        reload_quantum_s <= '0';
        store_s <= '0';
        sample_s <= '0';

        case current_state is
            when sync_seg_s =>
                if hard_reload_i = '1' then
                    new_state <= sync_seg_s;
                    reload_value_s <= to_unsigned(12, reload_value_s'length);
                    reload_quantum_s <= '1';
                elsif done_s = '1' then
                    new_state <= prob_seg_s;
                    reload_value_s <= to_unsigned(24, reload_value_s'length);
                    reload_quantum_s <= '1';
                end if;

            when prob_seg_s => 
                if hard_reload_i = '1' then
                    new_state <= sync_seg_s;
                    reload_value_s <= to_unsigned(12, reload_value_s'length);
                    reload_quantum_s <= '1';
                elsif done_s = '1' then
                    new_state <= phase_sig_one_s;
                    reload_value_s <= to_unsigned(32, reload_value_s'length);
                    reload_quantum_s <= '1';
                elsif reload_i = '1' and sync_enable_i = '1' then
                    new_state <= resync_p_s;
                    store_s <= '1';
                end if;

            when phase_sig_one_s =>
                if hard_reload_i = '1' then
                    new_state <= sync_seg_s;
                    reload_value_s <= to_unsigned(12, reload_value_s'length);
                    reload_quantum_s <= '1';
                elsif done_s = '1' then
                    new_state <= phase_sig_two_s;
                    reload_value_s <= to_unsigned(32, reload_value_s'length);
                    reload_quantum_s <= '1';
                    sample_s <= '1';
                end if;

            when resync_p_s =>
                if hard_reload_i = '1' then
                    new_state <= sync_seg_s;
                    reload_value_s <= to_unsigned(12, reload_value_s'length);
                    reload_quantum_s <= '1';
                elsif done_s = '1' then
                    new_state <= phase_sig_one_s;
                    reload_value_s <= to_unsigned(32, reload_value_s'length) + phase_cnt_s;
                    reload_quantum_s <= '1';
                end if;

            when phase_sig_two_s =>
                if hard_reload_i = '1' then
                    new_state <= sync_seg_s;
                    reload_value_s <= to_unsigned(12, reload_value_s'length);
                    reload_quantum_s <= '1';
                elsif done_s = '1' then
                    new_state <= sync_seg_s;
                    reload_value_s <= to_unsigned(12, reload_value_s'length);
                    reload_quantum_s <= '1';
                elsif reload_i = '1' and sync_enable_i = '1' then
                    new_state <= resync_n_s;
                    reload_value_s <= to_unsigned(12, reload_value_s'length);
                    reload_quantum_s <= '1';
                end if;

            when resync_n_s =>
                if hard_reload_i = '1' then
                    new_state <= sync_seg_s;
                    reload_value_s <= to_unsigned(12, reload_value_s'length);
                    reload_quantum_s <= '1';
                elsif done_s = '1' then
                    new_state <= prob_seg_s;
                    reload_value_s <= to_unsigned(24, reload_value_s'length);
                    reload_quantum_s <= '1';
                end if;

            when others =>
                new_state <= sync_seg_s;

        end case;
    end process;
                    
    p : process(clk)
    begin 
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then 
                current_state <= sync_seg_s;
            end if;
        end if;
    end process p;
        
    


end architecture;