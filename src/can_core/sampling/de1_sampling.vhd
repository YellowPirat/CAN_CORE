library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.baud_intf.all;

entity de1_sampling is
    port (
        clk                     : in    std_logic                               := '0';
        rst_n                   : in    std_logic                               := '1';
        rxd_sync_i              : in    std_logic                               := '1';
        frame_finished_i        : in    std_logic                               := '0';
        enable_destuffing_i     : in    std_logic                               := '0';
        reset_destuffing_i      : in    std_logic                               := '0';
        hard_reload_i           : in    std_logic                               := '0';
        sample_o                : out   std_logic                               := '0';
        edge_o                  : out   std_logic                               := '0';
        baud_config_i           : in    baud_intf_t                             := baud_intf_default
    );
end entity;

architecture rtl of de1_sampling is
    signal edge_s               : std_logic                                     := '0';
    signal sample_s             : std_logic                                     := '0';
    signal sync_enable_s        : std_logic                                     := '0';
    signal rst_h                : std_logic                                     := '0';
begin

    rst_h                       <= not rst_n;
    sample_o                    <= sample_s;
    edge_o                      <= edge_s;


    edge_detect_i0 : entity work.edge_detect
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            data_i              => rxd_sync_i,
            edge_detect_o       => edge_s
        );

    sample_i0 : entity work.sample
        port map(
            clk                 => clk, 
            rst_n               => rst_n,
            edge_i              => edge_s,
            hard_reload_i       => hard_reload_i,
            sync_enable_i       => sync_enable_s,
            baud_config_i       => baud_config_i,
            sample_o            => sample_s
        );

    resync_validator_i0 : entity work.sample_validator
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            data_i              => rxd_sync_i,
            sample_i            => sample_s,
            edge_i              => edge_s,
            resync_valid_o      => sync_enable_s
        );

end architecture;