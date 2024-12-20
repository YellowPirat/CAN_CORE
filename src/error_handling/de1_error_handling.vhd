library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_error_handling is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_i                   : in    std_logic;
        sample_i                : in    std_logic;

        new_frame_started_i     : in    std_logic;

        stuff_error_i           : in    std_logic;
        decode_error_i          : in    std_logic;
        sample_error_i          : in    std_logic;
        crc_error_i             : in    std_logic;

        reset_core_o            : out   std_logic;
        reset_destuffing_o      : out   std_logic;

        error_o                 : out   std_logic;
        error_code_o            : out   std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of de1_error_handling is


    signal eof_detect_s         : std_logic;
    signal enable_eof_detect_s  : std_logic;

begin

    error_code_o(15 downto 4) <= (others => '0');

    stuff_error_reg_i0 : entity work.bit_reg
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            data_i              => stuff_error_i,
            sample_i            => stuff_error_i,
            reload_i            => new_frame_started_i,

            data_o              => error_code_o(0)
        );

    decode_error_reg_i0 : entity work.bit_reg
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            data_i              => decode_error_i,
            sample_i            => decode_error_i,
            reload_i            => new_frame_started_i,

            data_o              => error_code_o(1)
        );

    sample_error_reg_i0 : entity work.bit_reg
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            data_i              => sample_error_i,
            sample_i            => sample_error_i,
            reload_i            => new_frame_started_i,

            data_o              => error_code_o(2)
        );

    crc_error_reg_i0 : entity work.bit_reg
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            data_i              => crc_error_i,
            sample_i            => crc_error_i,
            reload_i            => new_frame_started_i,

            data_o              => error_code_o(3)
        );

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

    eof_detect_i0 : entity work.ef_cntr
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            rxd_i               => rxd_i,
            sample_i            => sample_i,
            enable_i            => enable_eof_detect_s,

            eof_detect_o        => eof_detect_s
        );

    

    error_o <= eof_detect_s;

end rtl ; -- rtl