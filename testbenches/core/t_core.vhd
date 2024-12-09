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

    signal id_s                     : std_logic_vector(28 downto 0);
    signal rtr_s                    : std_logic;
    signal eff_s                    : std_logic;
    signal err_s                    : std_logic;
    signal dlc_s                    : std_logic_vector(3 downto 0);
    signal crc_s                    : std_logic_vector(14 downto 0);
    signal data_s                   : std_logic_vector(63 downto 0);
    signal data_valid_s             : std_logic;


    signal uart_rx_s                : std_logic;
    signal uart_tx_s                : std_logic;
    signal uart_data_s              : std_logic_vector(127 downto 0);

    signal reset_core_s             : std_logic;
    signal reset_destuffing_s       : std_logic;

    signal decode_error_s           : std_logic;
    signal stuff_error_s            : std_logic;

    signal enable_destuffing_s      : std_logic;

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
        wait for 4000 us;
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
            enable_destuffing_i     => enable_destuffing_s,
            reset_destuffing_i      => '0',

            rxd_sync_o              => rxd_sync_s,
            sample_o                => sample_s,
            stuff_bit_o             => stuff_bit_s,
            bus_active_detect_o     => bus_active_detect_s,
            stuff_error_o           => stuff_error_s
       );

    error_handling_i0 : entity work.de1_error_handling
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            rxd_i                   => rxd_sync_s,
            sample_i                => sample_s,

            stuff_error_i           => stuff_error_s,
            decode_error_i          => decode_error_s,
            sample_error_i          => '0',

            reset_core_o            => reset_core_s,
            reset_destuffing_o      => reset_destuffing_s
        );



    core_i0 : entity work.de1_core
    port map(
        clk                         => clk,
        rst_n                       => rst_n,

        rxd_sync_i                  => rxd_sync_s,
        sample_i                    => sample_s,
        stuff_bit_i                 => stuff_bit_s,
        bus_active_detect_i         => bus_active_detect_s,

        id_o                        => id_s,
        rtr_o                       => rtr_s,
        eff_o                       => eff_s,
        err_o                       => err_s,
        dlc_o                       => dlc_s,
        data_o                      => data_s,
        crc_o                       => crc_s,

        valid_o                     => data_valid_s,

        frame_finished_o            => frame_finished_s,

        reset_i                     => reset_core_s,
        decode_error_o              => decode_error_s,
        enable_destuffing_o         => enable_destuffing_s
    );

    -- ID
    uart_data_s(28 downto 0)        <= id_s;
    uart_data_s(31 downto 29)       <= (others => '0');
    -- FLAGS
    uart_data_s(32)                 <= rtr_s;
    uart_data_s(33)                 <= eff_s;
    uart_data_s(34)                 <= err_s;
    uart_data_s(39 downto 35)       <= (others => '0');
    -- DLC
    uart_data_s(43 downto 40)       <= dlc_s;
    uart_data_s(47 downto 44)       <= (others => '0');
    -- DATA
    uart_data_s(111 downto 48)      <= data_s;
    -- CRC
    uart_data_s(126 downto 112)     <= crc_s;
    uart_data_s(127)                <= '0';


    debug_i0 : entity work.de1_debug
        generic map(
            widght_g                => 128
        )
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            data_i                  => uart_data_s,
            valid_i                 => data_valid_s,

            rxd_i                   => uart_rx_s,
            txd_o                   => uart_tx_s
        );

end architecture;