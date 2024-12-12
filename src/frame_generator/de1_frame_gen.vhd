library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.can_core_intf.all;
use work.peripheral_intf.all;

use work.olo_base_pkg_math.all;

entity de1_frame_gen is
    generic (
        count_g                 : positive := 2
    );
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        can_frame_o             : out   can_core_out_intf_t;
        can_frame_valid_o       : out   std_logic;

        peripheral_status_o     : out   per_intf_t
    );
end entity;

architecture rtl of de1_frame_gen is

    signal en_s                 : std_logic;
    signal pos_s                : std_logic_vector(log2ceil(count_g + 1) - 1 downto 0);
    signal glob_en_s            : std_logic;
    signal done_s               : std_logic;

begin
    frames_i0 : entity work.frames
        generic map(
            count_g             => count_g
        )
        port map(
            pos_i               => pos_s,
            frame_o             => can_frame_o
        );

    bench_finisher_i0 : entity work.bench_finisher 
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            en_i                => done_s,

            done_o              => glob_en_s
        );

    frame_cnt_i0 : entity work.frame_cnt
        generic map(
            count_g             => count_g
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            en_i                => en_s,
            glob_en_i           => glob_en_s,

            cnt_o               => pos_s,
            done_o              => done_s
        );

    en_gen_i0 : entity work.en_gen
        generic map(
            count_g             => 10,
            start_valid_g       => 8,
            end_valid_g         => 9
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            glob_en_i           => glob_en_s,

            en_o                => en_s,
            valid_o             => can_frame_valid_o
        );

end rtl;