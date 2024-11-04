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
    signal sample_data_s    : std_logic;
    signal p_s              : std_logic;

    signal rst_h            : std_logic;
begin
    rxd_async_s(0) <= rxd_i;
    rst_h  <= not rst_n;

    sync_stage_i0 : entity work.olo_intf_sync
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
            enable_i        => '1',
            sample_o        => sample_s
        );

    sample_data_s <= '0' when rst_n = '0' else p_s when rising_edge(clk);
    p_s <= sample_data_s when sample_s = '0' else rxd_sync_s(0);

end architecture;