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

    signal id_dec_s             : std_logic;
    signal id_cnt_done_s        : std_logic;
    signal id_data_pos_s        : std_logic_vector(3 downto 0);
    signal id_sample_s          : std_logic;
    signal id_done_s            : std_logic;

    
begin

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


    frame_finished_o <= '0';

    frame_detect_i0 : entity work.frame_detect
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            rxd_i               => rxd_sync_i,
            sample_i            => sample_i,
            stuff_bit_i         => stuff_bit_i,
            bus_active_i        => bus_active_detect_i,

            id_dec_o            => id_dec_s,
            id_cnt_done_i       => id_cnt_done_s,
            id_sample_o         => id_sample_s,
            id_done_o           => id_done_s
        );

end rtl ;