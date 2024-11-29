library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

entity sample_cntr is 
    generic (
        sync_seg_g      : natural;
        prob_seg_g      : natural;
        phase_seg1_g    : natural;
        phase_seg2_g    : natural
    );
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        edge_i              : in    std_logic;
        hard_reload_i       : in    std_logic;
        sync_enable_i       : in    std_logic;
        sample_o            : out   std_logic;

        reload_sync_o       : out   std_logic;
        done_sync_i         : in    std_logic;
        cnt_sync_i          : in    unsigned(log2ceil(sync_seg_g + 1) - 1 downto 0);
        shift_val_sync_o    : out   unsigned(log2ceil(sync_seg_g + 1) - 1 downto 0);

        reload_prob_o       : out   std_logic;
        done_prob_i         : in    std_logic;
        cnt_prob_i          : in    unsigned(log2ceil(prob_seg_g + 1) - 1 downto 0);
        shift_val_prob_o    : out   unsigned(log2ceil(prob_seg_g + 1) - 1 downto 0);

        reload_phase1_o     : out   std_logic;
        done_phase1_i       : in    std_logic;
        cnt_phase1_i        : in    unsigned(log2ceil(phase_seg1_g + 1) - 1 downto 0);
        shift_val_phase1_o  : out   unsigned(log2ceil(phase_seg1_g + 1) - 1 downto 0);

        reload_phase2_o     : out   std_logic;
        done_phase2_i       : in    std_logic;
        cnt_phase2_i        : in    unsigned(log2ceil(phase_seg2_g + 1) - 1 downto 0);
        shift_val_phase2_o  : out   unsigned(log2ceil(phase_seg2_g + 1) - 1 downto 0)
    );
end entity;

architecture rtl of sample_cntr is

    type state_t is (
        sync_seg_s,
        prob_seg_s,
        phase_sig1_s,
        phase_sig2_s
    );
    signal current_state, new_state : state_t;

    signal reload_sync_s            : std_logic;
    signal reload_prob_s            : std_logic;
    signal reload_phase1_s          : std_logic;
    signal reload_phase2_s          : std_logic;

    signal shift_val_sync_s         : unsigned(log2ceil(sync_seg_g + 1) - 1 downto 0);
    signal shift_val_prob_s         : unsigned(log2ceil(prob_seg_g + 1) - 1 downto 0);
    signal shift_val_phase1_s       : unsigned(log2ceil(phase_seg1_g + 1) - 1 downto 0);
    signal shift_val_phase2_s       : unsigned(log2ceil(phase_seg2_g + 1) - 1 downto 0);

    signal shift_val_s              : unsigned(log2ceil(prob_seg_g + 1) - 1 downto 0);
    signal store_shift_s            : std_logic;
    signal clear_shift_s            : std_logic;

    signal sample_s                 : std_logic;

    signal negative_resync          : std_logic;
    signal positive_resync          : std_logic;

begin

    reload_sync_o                   <= reload_sync_s;
    reload_prob_o                   <= reload_prob_s;
    reload_phase1_o                 <= reload_phase1_s;
    reload_phase2_o                 <= reload_phase2_s;

    shift_val_sync_o                <= shift_val_sync_s;
    shift_val_prob_o                <= shift_val_prob_s;
    shift_val_phase1_o              <= shift_val_phase1_s;
    shift_val_phase2_o              <= shift_val_phase2_s;
     

    sample_o                        <= sample_s;

    process(clk)
    begin 
        if rising_edge(clk) then
            shift_val_s     <= shift_val_s;

            if store_shift_s = '1' then
                shift_val_s     <= cnt_prob_i;
            end if;

            if clear_shift_s = '1' then
                shift_val_s     <= to_unsigned(0, shift_val_s'length);
            end if;

            if rst_n = '0' then
                shift_val_s <= to_unsigned(0, shift_val_s'length);
            end if;
        end if;
    end process;

    sampling_cntr_p : process(
        current_state,
        edge_i,
        hard_reload_i,
        sync_enable_i,
        done_sync_i,
        done_prob_i,
        done_phase1_i,
        done_phase2_i)
    begin

        new_state           <= current_state;

        reload_sync_s       <= '0';
        reload_prob_s       <= '0';
        reload_phase1_s     <= '0';
        reload_phase2_s     <= '0';

        sample_s            <= '0';

        negative_resync     <= '0';
        positive_resync     <= '0';

        store_shift_s       <= '0';
        clear_shift_s       <= '0';

        shift_val_sync_s    <= to_unsigned(0, log2ceil(sync_seg_g + 1));
        shift_val_prob_s    <= to_unsigned(0, log2ceil(prob_seg_g + 1));
        shift_val_phase1_s  <= to_unsigned(0, log2ceil(phase_seg1_g + 1));
        shift_val_phase2_s  <= to_unsigned(0, log2ceil(phase_seg2_g + 1)); 

        case current_state is
            when sync_seg_s =>
                if done_sync_i = '1' then
                    new_state       <= prob_seg_s;
                    reload_prob_s   <= '1';
                end if;

                if hard_reload_i = '1' then
                    new_state       <= sync_seg_s;
                    reload_sync_s   <= '1';
                end if;

            when prob_seg_s =>
                if done_prob_i = '1' then
                    new_state       <= phase_sig1_s;
                    reload_phase1_s <= '1';
                    if shift_val_s > 0 then
                        clear_shift_s   <= '1';
                        shift_val_phase1_s  <= to_unsigned(prob_seg_g - to_integer(shift_val_s) + 1, shift_val_phase1_s'length);
                    end if;
                end if;

                if edge_i = '1' and sync_enable_i = '1' then
                    store_shift_s       <= '1';
                    negative_resync     <= '1';
                end if;

                if hard_reload_i = '1' then
                    new_state       <= sync_seg_s;
                    reload_sync_s   <= '1';
                end if;

            when phase_sig1_s =>
                if done_phase1_i = '1' then
                    new_state       <= phase_sig2_s;
                    reload_phase2_s <= '1';
                    sample_s        <= '1';
                end if;

                if hard_reload_i = '1' then
                    new_state       <= sync_seg_s;
                    reload_sync_s   <= '1';
                end if;

            when phase_sig2_s =>
                if done_phase2_i = '1' then
                    new_state       <= sync_seg_s;
                    reload_sync_s   <= '1';
                end if;

                if edge_i = '1' and sync_enable_i = '1' then
                    new_state       <= sync_seg_s;
                    reload_sync_s   <= '1';
                    positive_resync <= '1';
                end if;

                if hard_reload_i = '1' then
                    new_state       <= sync_seg_s;
                    reload_sync_s   <= '1';
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

end rtl ; -- rtl