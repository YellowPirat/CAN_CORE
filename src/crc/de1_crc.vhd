library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_crc is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        sample_i                : in    std_logic;
        stuff_bit_i             : in    std_logic;
        rxd_sync_i              : in    std_logic;

        crc_i                   : in    std_logic_vector(14 downto 0);
        crc_valid_i             : in    std_logic;

        enable_i                : in    std_logic;
        reset_i                 : in    std_logic;

        crc_error_o             : out   std_logic
    );
end de1_crc;

architecture rtl of de1_crc is

begin

    crc_calculation_i0 : entity work.crc_calculation
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            sample_i            => sample_i,
            stuff_bit_i         => stuff_bit_i,
            rxd_sync_i          => rxd_sync_i,

            crc_i               => crc_i,
            crc_valid_i         => crc_valid_i,

            enable_i            => enable_i,
            reset_i             => reset_i,

            crc_error_o         => crc_error_o
        );

end rtl ; -- rtl