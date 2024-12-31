library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_sampling is
    generic(
        width_g                 : natural
    );
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_i                   : in    std_logic;
        frame_finished_i        : in    std_logic;
        enable_destuffing_i     : in    std_logic;
        reset_destuffing_i      : in    std_logic;

        rxd_sync_o              : out   std_logic;
        sample_o                : out   std_logic;
        stuff_bit_o             : out   std_logic;
        bus_active_detect_o     : out   std_logic;
        stuff_error_o           : out   std_logic;

        sync_seg_i              : in    unsigned(width_g - 1 downto 0);
        prob_seg_i              : in    unsigned(width_g - 1 downto 0);
        phase_seg1_i            : in    unsigned(width_g - 1 downto 0);
        phase_seg2_i            : in    unsigned(width_g - 1 downto 0);
        prescaler_i             : in    unsigned(width_g - 1 downto 0)
    );
end entity;

architecture rtl of de1_sampling is

    signal rxd_async_s      : std_logic_vector(0 downto 0);
    signal rxd_sync_s       : std_logic_vector(0 downto 0);
    signal edge_s           : std_logic;
    signal sample_s         : std_logic;
    signal bus_active_s     : std_logic;
    signal stuff_bit_s      : std_logic;

    signal hard_reload_s    : std_logic;
    signal sync_enable_s    : std_logic;

    signal rst_h            : std_logic;
begin
    rxd_async_s(0)          <= rxd_i;
    rst_h                   <= not rst_n;
    rxd_sync_o              <= rxd_sync_s(0);
    sample_o                <= sample_s;
    stuff_bit_o             <= stuff_bit_s;
    bus_active_detect_o     <= bus_active_s;

    sync_stage_i0 : entity work.olo_intf_sync
        generic map(
            RstLevel_g      => '1'
        )
        port map(
            Clk             => clk,
            Rst             => rst_h,
            DataAsync       => rxd_async_s,
            DataSync        => rxd_sync_s
        );

    edge_detect_i0 : entity work.edge_detect
        port map(
            clk             => clk,
            rst_n           => rst_n,

            data_i          => rxd_sync_s(0),

            edge_detect_o   => edge_s
        );

    sample_i0 : entity work.sample
        generic map(

            width_g         => width_g
        )
        port map(
            clk             => clk, 
            rst_n           => rst_n,

            edge_i          => edge_s,
            hard_reload_i   => hard_reload_s,
            sync_enable_i   => sync_enable_s,
            
            sync_seg_i      => sync_seg_i,
            prob_seg_i      => prob_seg_i,
            phase_seg1_i    => phase_seg1_i,
            phase_seg2_i    => phase_seg2_i,
            prescaler_i     => prescaler_i,

            sample_o        => sample_s
        );

    idle_detect_i0 : entity work.idle_detect
        port map(
            clk             => clk,
            rst_n           => rst_n,

            frame_end_i     => frame_finished_i,
            edge_i          => edge_s,

            hard_reload_o   => hard_reload_s, 
            bus_active_o    => bus_active_s
        );

    destuffing_i0 : entity work.destuffing
        port map(
            clk             => clk,
            rst_n           => rst_n,

            data_i          => rxd_sync_s(0),
            sample_i        => sample_s,
            enable_i        => enable_destuffing_i,
            reset_i         => reset_destuffing_i,
            
            stuff_bit_o     => stuff_bit_s,
            stuff_error_o   => stuff_error_o
        );

    resync_validator_i0 : entity work.sample_validator
        port map(
            clk             => clk,
            rst_n           => rst_n,

            data_i          => rxd_sync_s(0),
            sample_i        => sample_s,
            edge_i          => edge_s,

            resync_valid_o  => sync_enable_s
        );



end architecture;