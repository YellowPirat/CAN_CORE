library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.olo_base_pkg_math.all;

entity de1_timestamp is
    generic(
        timer_width_g               : positive                                                  := 64;
        sample_cnt_g                : positive                                                  := 50
    );
    port (
        clk                         : in    std_logic                                           := '0';
        rst_n                       : in    std_logic                                           := '1';
        sample_i                    : in    std_logic                                           := '0';
        cnt_o                       : out   std_logic_vector(timer_width_g - 1 downto 0)        := (others => '0')
    );
end entity;

architecture rtl of de1_timestamp is

    signal cnt_s                    : std_logic_vector(timer_width_g - 1 downto 0)              := (others => '0');
    signal en_s                     : std_logic                                                 := '0';

begin

    sample_cnt_i0 : entity work.uni_cnt
        generic map(
            timer_width_g           => timer_width_g,
            overflow_point_g        => std_logic_vector(to_unsigned(sample_cnt_g, 64))
        )
        port map(
            clk                     => clk,
            rst_n                   => rst_n,
            en_i                    => '1',
            en_o                    => en_s
        );

    timestamp_cnt_i0 : entity work.uni_cnt
        generic map(
            timer_width_g           => timer_width_g,
            overflow_point_g        => (others => '1')
        )
        port map(
            clk                     => clk,
            rst_n                   => rst_n,
            en_i                    => en_s,
            cnt_o                   => cnt_s
        );

    timestamp_sampler_i0 : entity work.timestamp_sampler
        generic map(
            timer_width_g           => timer_width_g
        )
        port map(
            clk                     => clk,
            rst_n                   => rst_n,
            cnt_i                   => cnt_s,
            sample_i                => sample_i,
            cnt_o                   => cnt_o
        );

    

end rtl;