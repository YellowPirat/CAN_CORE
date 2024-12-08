library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

entity sample is
    generic (
        prescaler_g     : natural;
        sync_seg_g      : natural;
        prob_seg_g      : natural;
        phase_seg1_g    : natural;
        phase_seg2_g    : natural
    );
    port (
        clk             : in    std_logic;
        rst_n           : in    std_logic;

        edge_i          : in    std_logic;
        hard_reload_i   : in    std_logic;
        sync_enable_i   : in    std_logic;

        sample_o        : out   std_logic
    );
end entity;

architecture rtl of sample is

    signal prescale_enable_s        : std_logic;

    signal reload_sync_s            : std_logic;
    signal done_sync_s              : std_logic;
    signal cnt_sync_s               : unsigned(log2ceil(sync_seg_g + 1) - 1 downto 0);
    signal shift_val_sync_s         : unsigned(log2ceil(sync_seg_g + 1) - 1 downto 0);

    signal reload_prob_s            : std_logic;
    signal done_prob_s              : std_logic;
    signal cnt_prob_s               : unsigned(log2ceil(prob_seg_g + 1) - 1 downto 0);
    signal shift_val_prob_s         : unsigned(log2ceil(prob_seg_g + 1) - 1 downto 0);

    signal reload_phase1_s          : std_logic;
    signal done_phase1_s            : std_logic;
    signal cnt_phase1_s             : unsigned(log2ceil(phase_seg1_g + 1) - 1 downto 0);
    signal shift_val_phase1_s       : unsigned(log2ceil(phase_seg1_g + 1) - 1 downto 0);

    signal reload_phase2_s          : std_logic;
    signal done_phase2_s            : std_logic;
    signal cnt_phase2_s             : unsigned(log2ceil(phase_seg2_g + 1) - 1 downto 0);
    signal shift_val_phase2_s       : unsigned(log2ceil(phase_seg2_g + 1) - 1 downto 0);

begin


    prescaler_i0 : entity work.quantum_prescaler
        generic map(
            div_g       => prescaler_g
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,

            en_o        => prescale_enable_s
        );

    sync_cnt_i0 : entity work.seq_cnt
        generic map(
            start_g     => sync_seg_g
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,

            en_i        => prescale_enable_s,
            reload_i    => reload_sync_s,
            shift_val_i => shift_val_sync_s,

            done_o      => done_sync_s,
            cnt_o       => cnt_sync_s
        );

    prob_cnt_i0 : entity work.seq_cnt
        generic map(
            start_g     => prob_seg_g
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,

            en_i        => prescale_enable_s,
            reload_i    => reload_prob_s,
            shift_val_i => shift_val_prob_s,

            done_o      => done_prob_s,
            cnt_o       => cnt_prob_s
        );

    phase1_cnt_i0 : entity work.seq_cnt
        generic map(
            start_g     => phase_seg1_g
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,

            en_i        => prescale_enable_s,
            reload_i    => reload_phase1_s,
            shift_val_i => shift_val_phase1_s,

            done_o      => done_phase1_s,
            cnt_o       => cnt_phase1_s
        );

    phase2_cnt_i0 : entity work.seq_cnt
        generic map(
            start_g     => phase_seg2_g
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,

            en_i        => prescale_enable_s,
            reload_i    => reload_phase2_s,
            shift_val_i => shift_val_phase2_s,

            done_o      => done_phase2_s,
            cnt_o       => cnt_phase2_s
        );

    sample_cntr_i0 : entity work.sample_cntr
        generic map(
            sync_seg_g          => sync_seg_g,
            prob_seg_g          => prob_seg_g,
            phase_seg1_g        => phase_seg1_g,
            phase_seg2_g        => phase_seg2_g
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            edge_i              => edge_i,
            hard_reload_i       => hard_reload_i,
            sync_enable_i       => sync_enable_i,
            sample_o            => sample_o,

            reload_sync_o       => reload_sync_s,
            done_sync_i         => done_sync_s,
            cnt_sync_i          => cnt_sync_s,
            shift_val_sync_o    => shift_val_sync_s,

            reload_prob_o       => reload_prob_s,
            done_prob_i         => done_prob_s,
            cnt_prob_i          => cnt_prob_s,
            shift_val_prob_o    => shift_val_prob_s,

            reload_phase1_o     => reload_phase1_s,
            done_phase1_i       => done_phase1_s,
            cnt_phase1_i        => cnt_phase1_s,
            shift_val_phase1_o  => shift_val_phase1_s,

            reload_phase2_o     => reload_phase2_s,
            done_phase2_i       => done_phase2_s,
            cnt_phase2_i        => cnt_phase2_s,
            shift_val_phase2_o  => shift_val_phase2_s
        );

end rtl ; -- rtl