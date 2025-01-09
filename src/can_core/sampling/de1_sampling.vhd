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

        rxd_sync_i              : in    std_logic;
        frame_finished_i        : in    std_logic;
        enable_destuffing_i     : in    std_logic;
        reset_destuffing_i      : in    std_logic;
        hard_reload_i           : in    std_logic;


        sample_o                : out   std_logic;
        edge_o                  : out   std_logic;


        sync_seg_i              : in    unsigned(width_g - 1 downto 0);
        prob_seg_i              : in    unsigned(width_g - 1 downto 0);
        phase_seg1_i            : in    unsigned(width_g - 1 downto 0);
        phase_seg2_i            : in    unsigned(width_g - 1 downto 0);
        prescaler_i             : in    unsigned(width_g - 1 downto 0)
    );
end entity;

architecture rtl of de1_sampling is



    signal edge_s           : std_logic;
    signal sample_s         : std_logic;




    signal sync_enable_s    : std_logic;

    signal rst_h            : std_logic;
begin

    rst_h                   <= not rst_n;
    sample_o                <= sample_s;

    edge_o                  <= edge_s;


    edge_detect_i0 : entity work.edge_detect
        port map(
            clk             => clk,
            rst_n           => rst_n,

            data_i          => rxd_sync_i,

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
            hard_reload_i   => hard_reload_i,
            sync_enable_i   => sync_enable_s,
            
            sync_seg_i      => sync_seg_i,
            prob_seg_i      => prob_seg_i,
            phase_seg1_i    => phase_seg1_i,
            phase_seg2_i    => phase_seg2_i,
            prescaler_i     => prescaler_i,

            sample_o        => sample_s
        );





    resync_validator_i0 : entity work.sample_validator
        port map(
            clk             => clk,
            rst_n           => rst_n,

            data_i          => rxd_sync_i,
            sample_i        => sample_s,
            edge_i          => edge_s,

            resync_valid_o  => sync_enable_s
        );



end architecture;