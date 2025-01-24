library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

    use work.baud_intf.all;

entity sample is
    generic (
        width_g         : natural
    );
    port (
        clk             : in    std_logic;
        rst_n           : in    std_logic;

        edge_i          : in    std_logic;
        hard_reload_i   : in    std_logic;
        sync_enable_i   : in    std_logic;

        baud_config_i   : in    baud_intf_t;

        sample_o        : out   std_logic
    );
end entity;

architecture rtl of sample is

    signal prescale_enable_s        : std_logic;

    signal reload_sync_s            : std_logic;
    signal done_sync_s              : std_logic;
    signal cnt_sync_s               : unsigned(width_g - 1 downto 0);
    signal shift_val_sync_s         : unsigned(width_g - 1 downto 0);

    signal reload_prob_s            : std_logic;
    signal done_prob_s              : std_logic;
    signal cnt_prob_s               : unsigned(width_g - 1 downto 0);
    signal shift_val_prob_s         : unsigned(width_g - 1 downto 0);

    signal reload_phase1_s          : std_logic;
    signal done_phase1_s            : std_logic;
    signal cnt_phase1_s             : unsigned(width_g - 1 downto 0);
    signal shift_val_phase1_s       : unsigned(width_g - 1 downto 0);

    signal reload_phase2_s          : std_logic;
    signal done_phase2_s            : std_logic;
    signal cnt_phase2_s             : unsigned(width_g - 1 downto 0);
    signal shift_val_phase2_s       : unsigned(width_g - 1 downto 0);

begin


    prescaler_i0 : entity work.quantum_prescaler
        generic map(
            width_g       => width_g
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,

            prescaler_i => baud_config_i.prescaler,

            en_o        => prescale_enable_s
        );

    sync_cnt_i0 : entity work.seq_cnt
        generic map(
            width_g     => width_g
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,

            en_i        => prescale_enable_s,
            reload_i    => reload_sync_s,
            shift_val_i => shift_val_sync_s,
            start_i     => baud_config_i.sync_seg,

            done_o      => done_sync_s,
            cnt_o       => cnt_sync_s
        );

    prob_cnt_i0 : entity work.seq_cnt
        generic map(
            width_g     => width_g
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,

            en_i        => prescale_enable_s,
            reload_i    => reload_prob_s,
            shift_val_i => shift_val_prob_s,
            start_i     => baud_config_i.prob_seg,

            done_o      => done_prob_s,
            cnt_o       => cnt_prob_s
        );

    phase1_cnt_i0 : entity work.seq_cnt
        generic map(
            width_g     => width_g
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,

            en_i        => prescale_enable_s,
            reload_i    => reload_phase1_s,
            shift_val_i => shift_val_phase1_s,
            start_i     => baud_config_i.phase_seg1,

            done_o      => done_phase1_s,
            cnt_o       => cnt_phase1_s
        );

    phase2_cnt_i0 : entity work.seq_cnt
        generic map(
            width_g     => width_g
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,

            en_i        => prescale_enable_s,
            reload_i    => reload_phase2_s,
            shift_val_i => shift_val_phase2_s,
            start_i     => baud_config_i.phase_seg2,

            done_o      => done_phase2_s,
            cnt_o       => cnt_phase2_s
        );

    sample_cntr_i0 : entity work.sample_cntr
        generic map(
            width_g             => width_g
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
            shift_val_phase2_o  => shift_val_phase2_s,

            sync_seg_i          => baud_config_i.sync_seg,
            prob_seg_i          => baud_config_i.prob_seg,
            phase_seg1_i        => baud_config_i.phase_seg1,
            phase_seg2_i        => baud_config_i.phase_seg2
        );

end rtl ; -- rtl