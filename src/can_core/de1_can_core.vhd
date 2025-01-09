library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_core_intf.all;
use work.peripheral_intf.all;

entity de1_can_core is
    generic(
        width_g                 : natural
    );
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_async_i             : in    std_logic;

        can_frame_o             : out   can_core_out_intf_t;
        can_frame_valid_o       : out   std_logic;

        uart_debug_tx_o         : out   std_logic;

        peripheral_status_o     : out   per_intf_t;

        sync_seg_i              : in    unsigned(width_g - 1 downto 0);
        prob_seg_i              : in    unsigned(width_g - 1 downto 0);
        phase_seg1_i            : in    unsigned(width_g - 1 downto 0);
        phase_seg2_i            : in    unsigned(width_g - 1 downto 0);
        prescaler_i             : in    unsigned(width_g - 1 downto 0)
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

    signal error_s                  : std_logic;
    signal sof_state_s              : std_logic;
    signal new_frame_started_s      : std_logic;

    signal error_codes_s            : std_logic_vector(15 downto 0);

    signal timestamp_s              : std_logic_vector(63 downto 0);

    signal warm_rxd_sync_s          : std_logic;
begin

    peripheral_status_o.buffer_usage            <= (others => '0');
    peripheral_status_o.peripheral_error        <= (others => '0');
    peripheral_status_o.missed_frames           <= to_unsigned(0, peripheral_status_o.missed_frames'length);
    peripheral_status_o.missed_frames_overflow  <= '0';

    warm_start_i0 : entity work.de1_warm_start
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            rxd_sync_i              => rxd_sync_s,
            sample_i                => sample_s,

            rxd_sync_o              => warm_rxd_sync_s
        );

    sampling_i0 : entity work.de1_sampling
        generic map(
            width_g                 => width_g
        )
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
            stuff_error_o           => stuff_error_s,

            sync_seg_i              => sync_seg_i,
            prob_seg_i              => prob_seg_i,
            phase_seg1_i            => phase_seg1_i,
            phase_seg2_i            => phase_seg2_i,
            prescaler_i             => prescaler_i
       );

    error_handling_i0 : entity work.de1_error_handling
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            rxd_i                   => rxd_sync_s,
            sample_i                => sample_s,

            new_frame_started_i     => new_frame_started_s,

            stuff_error_i           => stuff_error_s,
            decode_error_i          => decode_error_s,
            sample_error_i          => '0',
            crc_error_i             => error_crc_s,

            reset_core_o            => reset_core_s,
            reset_destuffing_o      => reset_destuffing_s,

            error_o                 => error_s,
            error_code_o            => error_codes_s
        );

    timestamp_i0 : entity work.de1_timestamp
        generic map(
            timer_width_g           => 64,
            sample_cnt_g            => 50
        )
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            sample_i                => new_frame_started_s,

            cnt_o                   => timestamp_s
        );

    frame_valid_i0 : entity work.de1_frame_valid
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            can_frame_valid_i       => data_valid_s,
            error_frame_valid_i     => error_s,
            sof_state_i             => sof_state_s,

            frame_valid_o           => can_frame_valid_o
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
            enable_destuffing_o         => enable_destuffing_s,

            sof_state_o                 => sof_state_s,
            new_frame_started_o         => new_frame_started_s
        );

    can_frame_s.error_codes                 <= error_codes_s;
    can_frame_s.frame_type                  <= (others => '0');
    can_frame_s.timestamp                   <= timestamp_s;
    can_frame_s.crc                         <= crc_s;
    can_frame_s.can_dlc                     <= dlc_s;
    can_frame_s.can_id                      <= id_s;
    can_frame_s.rtr                         <= rtr_s;
    can_frame_s.eff                         <= eff_s;
    can_frame_s.err                         <= err_s;
    can_frame_s.data                        <= data_s;
    can_frame_o                             <= can_frame_s;

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