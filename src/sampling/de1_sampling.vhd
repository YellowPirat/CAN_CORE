library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_sampling is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;
        rxd_i               : in    std_logic
    );
end entity;

architecture rtl of de1_sampling is

    signal rxd_async_s      : std_logic_vector(0 downto 0);
    signal rxd_sync_s       : std_logic_vector(0 downto 0);
    signal edge_s           : std_logic;
    signal sample_s         : std_logic;
    signal enable_sample_s  : std_logic;
    signal stuff_bit_s      : std_logic;
    signal bit_stuff_error  : std_logic;

    signal rst_h            : std_logic;
begin
    rxd_async_s(0) <= rxd_i;
    rst_h  <= not rst_n;

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

    sample_cnt_i0 : entity work.sample_cnt
        port map(
            clk             => clk,
            rst_n           => rst_n,
            reload_i        => edge_s,
            enable_i        => enable_sample_s,
            sample_o        => sample_s
        );

    idle_detect_i0 : entity work.idle_detect
        port map(
            clk             => clk,
            rst_n           => rst_n,
            frame_end_i     => '0',
            edge_i          => edge_s,
            enable_o        => enable_sample_s
        );

    destuffing_i0 : entity work.destuffing
        port map(
            clk             => clk,
            rst_n           => rst_n,
            data_i          => rxd_sync_s(0),
            sample_i        => sample_s,
            bus_active_i    => enable_sample_s,
            stuff_bit_o     => stuff_bit_s,
            error_o         => bit_stuff_error
        );



end architecture;