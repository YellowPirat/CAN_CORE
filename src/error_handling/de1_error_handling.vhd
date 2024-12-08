library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_error_handling is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_i                   : in    std_logic;
        sample_i                : in    std_logic;

        stuff_error_i           : in    std_logic;
        decode_error_i          : in    std_logic;
        sample_error_i          : in    std_logic;

        eof_detect_o            : out    std_logic
    );
end entity;

architecture rtl of de1_error_handling is

    signal extern_error_s       : std_logic;

begin

    extern_error_s  <= stuff_error_i or decode_error_i or sample_error_i;

    eof_detect_i0 : entity work.eof_detect
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            rxd_i               => rxd_i,
            sample_i            => sample_i,

            extern_error_i      => extern_error_s,

            eof_detect_o        => eof_detect_o
        );

end rtl ; -- rtl