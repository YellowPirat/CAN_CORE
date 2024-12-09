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

        reset_core_o            : out   std_logic;
        reset_destuffing_o      : out   std_logic
    );
end entity;

architecture rtl of de1_error_handling is


    signal eof_detect_s         : std_logic;
    signal enable_eof_detect_s  : std_logic;

begin

    error_handling_cntr_i0 : entity work.error_handling_cntr
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            stuff_error_i       => stuff_error_i,
            decode_error_i      => decode_error_i,
            sample_error_i      => sample_error_i,

            eof_detect_i        => eof_detect_s,

            reset_core_o        => reset_core_o,
            reset_destuffing_o  => reset_destuffing_o,

            enable_eof_detect_o => enable_eof_detect_s
        );

    eof_detect_i0 : entity work.eof_detect
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            rxd_i               => rxd_i,
            sample_i            => sample_i,

            enable_i            => enable_eof_detect_s,

            eof_detect_o        => eof_detect_s
        );

end rtl ; -- rtl