library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity socketcan_mapper is
    port (
        data_i              : in    std_logic_vector(63 downto 0);
        dlc_i               : in    std_logic_vector(3 downto 0);

        data_o              : out   std_logic_vector(63 downto 0)
    );
end entity;

architecture rtl of socketcan_mapper is

    signal data_s           : std_logic_vector(63 downto 0);

begin

    data_o      <= data_s;

    process(data_i, dlc_i)
        variable dlc_val : integer;
    begin
        -- Konvertiere dlc_i in einen Integer-Wert
        dlc_val := to_integer(unsigned(dlc_i));
        
        -- Initialisiere data_s mit Nullen
        data_s <= (others => '0');
        
        if (dlc_val <= 8) then
            -- Weise Daten basierend auf dlc_val zu
            if dlc_val > 0 then
                data_s(31 downto 24) <= data_i(7 + 8 * (dlc_val - 1) downto 8 * (dlc_val - 1));
            end if;
            if dlc_val > 1 then
                data_s(23 downto 16)<= data_i(7 + 8 * (dlc_val - 2) downto 8 * (dlc_val - 2));
            end if;
            if dlc_val > 2 then
                data_s(15 downto 8) <= data_i(7 + 8 * (dlc_val - 3) downto 8 * (dlc_val - 3));
            end if;
            if dlc_val > 3 then
                data_s(7 downto 0) <= data_i(7 + 8 * (dlc_val - 4) downto 8 * (dlc_val - 4));
            end if;


            if dlc_val > 4 then
                data_s(63 downto 56)   <= data_i(7 + 8 * (dlc_val - 5) downto 8 * (dlc_val - 5));
            end if;
            if dlc_val > 5 then
                data_s(55 downto 48)  <= data_i(7 + 8 * (dlc_val - 6) downto 8 * (dlc_val - 6));
            end if;
            if dlc_val > 6 then
                data_s(47 downto 40)  <= data_i(7 + 8 * (dlc_val - 7) downto 8 * (dlc_val - 7));
            end if;
            if dlc_val > 7 then
                data_s(39 downto 32)   <= data_i(7 + 8 * (dlc_val - 8) downto 8 * (dlc_val - 8));
            end if;
        end if;
    end process;

end rtl;