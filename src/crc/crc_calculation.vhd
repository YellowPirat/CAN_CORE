library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_crc is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        sample_i                : in    std_logic; -- sample pulse which signals when to sample the rxd signal
        stuff_bit_i             : in    std_logic; -- bit signaling if the rxd bit is a stuffed bit or not
        rxd_sync_i              : in    std_logic; -- bit stream of the frame

        crc_i                   : in    std_logic_vector(14 downto 0); -- already calculated frame CRC
        crc_valid_i             : in    std_logic; -- valid signal for the frame CRC, which signals that the frame CRC is valid to compare to

        enable_i                : in    std_logic; -- enable signal for CRC calculation -> starts the CRC calculation
        reset_i                 : in    std_logic; -- reset signal for CRC calculation -> resets the FFs in CRC calculation state

        crc_error_o             : out   std_logic -- single bit signaling if the both CRCs are the same or not: -> "1" if crc_i != calculated CRC
    ); --                                                                                                       -> "0" if crc_i == calculated CRC
end entity;

architecture rtl of de1_crc is

    type state_t is (idle_s, calculate_crc_s, error_s);
    signal current_state, new_state : state_t;
    signal crc_value : std_logic_vector(14 downto 0);
    constant crc_polynomial : std_logic_vector(15 downto 0) := "1100010110011001";

begin

    crc_calculation_p : process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_state <= idle_s;
        elsif rising_edge(clk) then
            if reset_i = '1' then
                -- code


    p : process(clk)
    begin 
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then 
                current_state <= idle_s;
            end if;
        end if;
    end process p;

    crc_error_o <= '1' when crc_value = crc_i and crc_valid_i = '1' else '0';

end rtl ; -- rtl