library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_core_intf.all;

entity de1_can_core is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_async_i             : in    std_logic;

        can_frame_o             : out   can_core_out_intf_t;
        can_frame_valid_o       : out   std_logic;

        uart_debug_tx_o         : out   std_logic
    );
end entity;

architecture rtl of de1_can_core is

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

    signal can_frame_s              : can_core_out_intf_t;


    signal uart_rx_s                : std_logic;
    signal uart_tx_s                : std_logic;
    signal uart_data_s              : std_logic_vector(127 downto 0);

    signal reset_core_s             : std_logic;
    signal reset_destuffing_s       : std_logic;

    signal decode_error_s           : std_logic;
    signal stuff_error_s            : std_logic;

    signal enable_destuffing_s      : std_logic; 

    signal enable_crc_s             : std_logic;
    signal reset_crc_s              : std_logic;
    signal error_crc_s              : std_logic;

begin

    can_frame_valid_o               <= data_valid_s;

    sampling_i0 : entity work.de1_sampling
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            rxd_i                   => rxd_async_i,
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

    crc_i0 : entity work.de1_crc 
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            sample_i                => sample_s,
            stuff_bit_i             => stuff_bit_s,
            rxd_sync_i              => rxd_sync_s,

            crc_i                   => crc_s,
            crc_valid_i             => '0',

            enable_i                => enable_crc_s,
            reset_i                 => reset_crc_s,

            crc_error_o             => error_crc_s
        );

    core_i0 : entity work.de1_input_stream
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

    can_frame_s.error_codes         <= (others => '0');
    can_frame_s.frame_type          <= "00";
    can_frame_s.timestamp           <= (others => '0');
    can_frame_s.crc                 <= crc_s;
    can_frame_s.can_dlc             <= dlc_s;
    can_frame_s.can_id              <= id_s;
    can_frame_s.rtr                 <= rtr_s;
    can_frame_s.eff                 <= eff_s;
    can_frame_s.err                 <= err_s;
    can_frame_s.data                <= data_s;
    can_frame_o                     <= can_frame_s;

    -- DEBUG MAPPING
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
            txd_o                   => uart_debug_tx_o
        );

end rtl ; -- rtl