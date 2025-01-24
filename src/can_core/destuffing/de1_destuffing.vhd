library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_destuffing is
    port (
        clk                         : in    std_logic                   := '0';
        rst_n                       : in    std_logic                   := '1';
        data_i                      : in    std_logic                   := '1';
        sample_i                    : in    std_logic                   := '0';
        reset_i                     : in    std_logic                   := '0';
        enable_i                    : in    std_logic                   := '0';
        stuff_bit_o                 : out   std_logic                   := '0';
        stuff_error_o               : out   std_logic                   := '0'
    );
end entity;

architecture rtl of de1_destuffing is

    signal last_bit_s               : std_logic                         := '0';

begin

    last_bit_i0 : entity work.last_bit
        port map(
            clk                     => clk,
            rst_n                   => rst_n,
            data_i                  => data_i,
            sample_i                => sample_i,
            last_bit_o              => last_bit_s
        );

    destuffing_logic_i0 : entity work.destuffing_logic
        port map(
            clk                     => clk,
            rst_n                   => rst_n,
            data_i                  => data_i,
            sample_i                => sample_i,
            reset_i                 => reset_i,
            enable_i                => enable_i,
            last_bit_i              => last_bit_s,
            stuff_bit_o             => stuff_bit_o,
            stuff_error_o           => stuff_error_o
        );

end rtl ; -- rtl
