library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_core is
    port(
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_sync_i              : in    std_logic;
        sample_i                : in    std_logic;
        stuff_bit_i             : in    std_logic;
        bus_active_detect_i     : in    std_logic;

        frame_finished_o        : out   std_logic
    );
end entity;

architecture rtl of de1_core is

    -- ID
    signal id_dec_s             : std_logic;
    signal id_cnt_done_s        : std_logic;
    signal id_sample_s          : std_logic;
    -- EID
    signal eid_dec_s            : std_logic;
    signal eid_cnt_done_s       : std_logic;
    signal eid_sample_s         : std_logic;
    -- DLC
    signal dlc_dec_s            : std_logic;
    signal dlc_cnt_done_s       : std_logic;
    signal dlc_sample_s         : std_logic;

    
begin
    frame_finished_o <= '0';


    id_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 11
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => '0',
            dec_i               => id_dec_s,
            store_i             => id_sample_s,
            data_i              => rxd_sync_i,

            done_o              => id_cnt_done_s
        );

    eid_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 18
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => '0',
            dec_i               => eid_dec_s,
            store_i             => eid_sample_s,
            data_i              => rxd_sync_i,

            done_o              => eid_cnt_done_s
        );

    dlc_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 4
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => '0',
            dec_i               => dlc_dec_s,
            store_i             => dlc_sample_s,
            data_i              => rxd_sync_i,

            done_o              => dlc_cnt_done_s
        );


    frame_detect_i0 : entity work.frame_detect
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            rxd_i               => rxd_sync_i,
            sample_i            => sample_i,
            stuff_bit_i         => stuff_bit_i,
            bus_active_i        => bus_active_detect_i,

            -- ID
            id_dec_o            => id_dec_s,
            id_cnt_done_i       => id_cnt_done_s,
            id_sample_o         => id_sample_s,

            -- EID
            eid_dec_o           => eid_dec_s,
            eid_cnt_done_i      => eid_cnt_done_s,
            eid_sample_o        => eid_sample_s,

            -- DLC
            dlc_dec_o           => dlc_dec_s,
            dlc_cnt_done_i      => dlc_cnt_done_s,
            dlc_sample_o        => dlc_sample_s
        );

end rtl ;