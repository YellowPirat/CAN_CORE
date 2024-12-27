library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_crc is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        sample_i                : in    std_logic; -- sample puls which signals when to sample the rxd
        stuff_bit_i             : in    std_logic; -- bit signaling if the bit is a stuffed bit or not
        rxd_sync_i              : in    std_logic; -- bit stream of the frame

        crc_i                   : in    std_logic_vector(14 downto 0); -- already calculated frame CRC
        crc_valid_i             : in    std_logic; -- valid signal for the frame CRC

        enable_i                : in    std_logic; -- enable signal for CRC calculation -> starts the CRC calculation
        reset_i                 : in    std_logic; -- reset signal for CRC calculation -> resets the FFs in CRC calculation state

        crc_error_o             : out   std_logic -- single bit signaling if the both CRCs are the same or not: -> "1" if crc_i != calculated CRC
    ); --                                                                                                       -> "0" if crc_i == calculated CRC
end entity;

architecture rtl of de1_crc is

begin

    if sample_i = '1' and stuff_bit_i = '0' then
        rxd_sync_i
        -- code
      end if;
      

end rtl ; -- rtl