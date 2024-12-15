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
end entity;

architecture rtl of de1_crc is

begin

    

end rtl ; -- rtl