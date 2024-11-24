library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity core is
end entity;

architecture sim of core is

    signal clk, rst_n: std_logic := '0';
    signal simstop : boolean := false;

    signal rxd_async_s              : std_logic;
    signal frame_finished_s         : std_logic;
    signal rxd_sync_s               : std_logic;
    signal sample_s                 : std_logic;
    signal stuff_bit_s              : std_logic;
    signal bus_active_detect_s      : std_logic;

    signal data_s                   : std_logic_vector(63 downto 0);
    signal data_valid_s             : std_logic;
    signal uart_rx_s                : std_logic;
    signal uart_tx_s                : std_logic;

begin

  -- Clock generation
    clk_p : process
    begin
        clk <= '0';
        wait for 10 ns; 
        clk <= '1'; 
        wait for 10 ns;
        if simstop then
            wait;
        end if;
    end process clk_p;

  -- Reset generation
    rst_p : process
    begin
        rst_n <= '0';
        wait for 100 ns;
        rst_n <= '1';
        wait;
    end process rst_p;

    simstop_p : process
    begin
        wait for 2000 us;
        simstop <= true;
        wait;
    end process simstop_p;

    cangen_i0 : entity work.cangen
        port map(
            rst_n => rst_n,
            rxd_o => rxd_async_s,
            simstop => simstop
        );

    sampling_i0 : entity work.de1_sampling
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            rxd_i                   => rxd_async_s,
            frame_finished_i        => frame_finished_s,

            rxd_sync_o              => rxd_sync_s,
            sample_o                => sample_s,
            stuff_bit_o             => stuff_bit_s,
            bus_active_detect_o     => bus_active_detect_s
        );

    core_i0 : entity work.de1_core
    port map(
        clk                         => clk,
        rst_n                       => rst_n,

        rxd_sync_i                  => rxd_sync_s,
        sample_i                    => sample_s,
        stuff_bit_i                 => stuff_bit_s,
        bus_active_detect_i         => bus_active_detect_s,

        data_o                      => data_s,
        valid_o                     => data_valid_s,

        frame_finished_o            => frame_finished_s
    );

    debug_i0 : entity work.de1_debug
        generic map(
            widght_g                => 64
        )
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            data_i                  => data_s,
            valid_i                 => data_valid_s,

            rxd_i                   => uart_rx_s,
            txd_o                   => uart_tx_s
        );

end architecture;