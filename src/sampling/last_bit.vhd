library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity last_bit is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        data_i              : in    std_logic;
        sample_i            : in    std_logic;

        last_bit_o          : out   std_logic
    );
end entity;

architecture rtl of last_bit is

    signal last_bit_s   : std_logic;

begin

    last_bit_o      <= last_bit_s;

    last_bit_p : process(clk)
    begin
        if rising_edge(clk) then
            last_bit_s  <= last_bit_s;

            if sample_i = '1' then 
                last_bit_s <= data_i;
            end if;

            if rst_n = '0' then
                last_bit_s      <= '1';
            end if;
        end if;
    end process;

end rtl ; -- rtl

