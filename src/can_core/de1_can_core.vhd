library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.can_core_intf.all;
    use work.baud_intf.all;

entity de1_can_core is
    port (
        clk                         : in    std_logic                           := '0';
        rst_n                       : in    std_logic                           := '1';
        rxd_async_i                 : in    std_logic_vector(0 downto 0)        := (others => '1');
        baud_config_i               : in    baud_intf_t                         := baud_intf_default;
        can_frame_o                 : out   can_core_out_intf_t                 := can_core_intf_default;
        can_frame_valid_o           : out   std_logic                           := '0'
    );
end entity;

architecture rtl of de1_can_core is
    signal rxd_sync_s               : std_logic_vector(0 downto 0)              := (others => '0');
    signal rxd_s                    : std_logic                                 := '0';
    signal rst_h                    : std_logic                                 := '0';
    signal edge_s                   : std_logic                                 := '0';
    signal hard_reload_s            : std_logic                                 := '0';
    signal frame_finished_s         : std_logic                                 := '0';
    signal sample_s                 : std_logic                                 := '0';
    signal stuff_bit_s              : std_logic                                 := '0';
    signal bus_active_detect_s      : std_logic                                 := '0';
    signal data_valid_s             : std_logic                                 := '0';
    signal can_frame_s              : can_core_out_intf_t;
    signal reset_core_s             : std_logic                                 := '0';
    signal reset_destuffing_s       : std_logic                                 := '0';
    signal decode_error_s           : std_logic                                 := '0';
    signal stuff_error_s            : std_logic                                 := '0';
    signal enable_destuffing_s      : std_logic                                 := '0';     
    signal enable_crc_s             : std_logic                                 := '0';
    signal reset_crc_s              : std_logic                                 := '0';
    signal error_crc_s              : std_logic                                 := '0';
    signal error_s                  : std_logic                                 := '0';
    signal sof_state_s              : std_logic                                 := '0';
    signal new_frame_started_s      : std_logic                                 := '0';
    signal valid_crc_s              : std_logic                                 := '0';

    signal error_codes_s            : std_logic_vector(15 downto 0)             := (others => '0');
    signal timestamp_s              : std_logic_vector(63 downto 0)             := (others => '0');
begin

    rst_h                           <= not rst_n;

    can_frame_o.error_codes         <= error_codes_s;
    can_frame_o.frame_type          <= can_frame_s.frame_type;
    can_frame_o.timestamp           <= timestamp_s;
    can_frame_o.can_id              <= can_frame_s.can_id;
    can_frame_o.rtr                 <= can_frame_s.rtr;
    can_frame_o.eff                 <= can_frame_s.eff;
    can_frame_o.err                 <= can_frame_s.err;
    can_frame_o.can_dlc             <= can_frame_s.can_dlc;
    can_frame_o.crc                 <= can_frame_s.crc;
    can_frame_o.data                <= can_frame_s.data;




    sync_stage_i0 : entity work.olo_intf_sync
        generic map(
            RstLevel_g              => '1'
        )
        port map(
            Clk                     => clk,
            Rst                     => rst_h,
            DataAsync               => rxd_async_i,
            DataSync                => rxd_sync_s
        );


    warm_start_i0 : entity work.de1_warm_start
        port map(
            clk                     => clk,
            rst_n                   => rst_n,
            rxd_sync_i              => rxd_sync_s(0),
            sample_i                => sample_s,
            rxd_sync_o              => rxd_s
        );

    sampling_i0 : entity work.de1_sampling

        port map(
            clk                     => clk,
            rst_n                   => rst_n,
            rxd_sync_i              => rxd_s,
            frame_finished_i        => frame_finished_s,
            enable_destuffing_i     => enable_destuffing_s,
            reset_destuffing_i      => '0',
            hard_reload_i           => hard_reload_s,
            sample_o                => sample_s,
            edge_o                  => edge_s,
            baud_config_i           => baud_config_i
       );

    destuffing_i0 : entity work.de1_destuffing
       port map(
           clk                      => clk,
           rst_n                    => rst_n,
           data_i                   => rxd_s,
           sample_i                 => sample_s,
           enable_i                 => enable_destuffing_s,
           reset_i                  => reset_destuffing_s,
           stuff_bit_o              => stuff_bit_s,
           stuff_error_o            => stuff_error_s
       );

    idle_detect_i0 : entity work.idle_detect
       port map(
           clk                      => clk,
           rst_n                    => rst_n,
           frame_end_i              => frame_finished_s,
           edge_i                   => edge_s,
           hard_reload_o            => hard_reload_s, 
           bus_active_o             => bus_active_detect_s
       );

    error_handling_i0 : entity work.de1_error_handling
        port map(
            clk                     => clk,
            rst_n                   => rst_n,
            rxd_i                   => rxd_s,
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
            rxd_sync_i              => rxd_s,

            crc_i                   => can_frame_s.crc,
            crc_valid_i             => valid_crc_s,

            enable_i                => enable_crc_s,
            reset_i                 => reset_crc_s,
            crc_error_o             => error_crc_s
        );

    core_i0 : entity work.de1_input_stream
        port map(
            clk                     => clk,
            rst_n                   => rst_n,
            rxd_sync_i              => rxd_s,
            sample_i                => sample_s,
            stuff_bit_i             => stuff_bit_s,
            bus_active_detect_i     => bus_active_detect_s,
            can_frame_o             => can_frame_s,
            valid_o                 => data_valid_s,
            frame_finished_o        => frame_finished_s,
            reset_i                 => reset_core_s,
            decode_error_o          => decode_error_s,
            enable_destuffing_o     => enable_destuffing_s,
            sof_state_o             => sof_state_s,
            new_frame_started_o     => new_frame_started_s,
            enable_crc_o            => enable_crc_s,
            reset_crc_o             => reset_crc_s,
            valid_crc_o             => valid_crc_s
        );

end rtl ; -- rtl