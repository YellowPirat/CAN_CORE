library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crc_calculation is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        sample_i                : in    std_logic; -- sample pulse which signals when to sample the rxd signal
        stuff_bit_i             : in    std_logic; -- bit signaling if the rxd bit is a stuffed bit or not
        rxd_sync_i              : in    std_logic; -- bit stream of the frame

        crc_i                   : in    std_logic_vector(14 downto 0); -- CRC from the sent frame
        crc_valid_i             : in    std_logic; -- valid signal for the frame CRC, which signals that the frame CRC is valid to compare to

        enable_i                : in    std_logic; -- enable signal for CRC calculation
        reset_i                 : in    std_logic; -- synchronous reset signal for CRC calculation

        crc_error_o             : out   std_logic -- single bit signaling if the both CRCs are the same or not: "1" if crc_i != calculated CRC
    ); --                                                                                                       "0" if crc_i == calculated CRC
end entity;

architecture rtl of crc_calculation is

    type state_t is (idle_s, calculate_crc_s);
    signal current_state, new_state : state_t;
    signal crc_registers, next_crc_registers : std_logic_vector(14 downto 0);

begin

    crc_calculation_p : process(current_state, rxd_sync_i, sample_i, stuff_bit_i, enable_i, reset_i, crc_registers)
    begin
        new_state <= current_state;
        next_crc_registers <= crc_registers;
        crc_error_o <= '0';

        case current_state is
            when idle_s =>
                if enable_i = '1' then
                    new_state <= calculate_crc_s;
                else
                    new_state <= idle_s;
                end if;
                if reset_i = '1' then
                    new_state <= idle_s;
                    next_crc_registers <= (others => '0');
                end if;

            when calculate_crc_s =>
                if enable_i = '1' then
                    new_state <= calculate_crc_s;
                    if sample_i = '1' and stuff_bit_i = '0' and reset_i = '0' then
                        next_crc_registers(0)            <= rxd_sync_i xor crc_registers(14);
                        next_crc_registers(2 downto 1)   <= crc_registers(1 downto 0);
                        next_crc_registers(3)            <= crc_registers(2) xor crc_registers(14);
                        next_crc_registers(4)            <= crc_registers(3) xor crc_registers(14);
                        next_crc_registers(6 downto 5)   <= crc_registers(5 downto 4);
                        next_crc_registers(7)            <= crc_registers(6) xor crc_registers(14);
                        next_crc_registers(8)            <= crc_registers(7) xor crc_registers(14);
                        next_crc_registers(9)            <= crc_registers(8);
                        next_crc_registers(10)           <= crc_registers(9) xor crc_registers(14);
                        next_crc_registers(13 downto 11) <= crc_registers(12 downto 10);
                        next_crc_registers(14)           <= crc_registers(13) xor crc_registers(14);
                    end if;
                else
                        new_state <= idle_s;
                end if;
                if reset_i = '1' or crc_error_o = '1' then
                    new_state <= idle_s;
                    next_crc_registers <= (others => '0');
                end if;

            when others =>
                new_state <= idle_s;
        end case;
    end process crc_calculation_p;

    crc_error_o <= '1' when (crc_registers /= crc_i) and crc_valid_i = '1' else '0';

    p : process(clk)
    begin 
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then 
                current_state <= idle_s;
                crc_registers <= (others => '0');
            else
                crc_registers <= next_crc_registers;
            end if;
        end if;
    end process p;

end rtl ; -- rtl