library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bit_reg is
    port(
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        data_i                  : in    std_logic;
        sample_i                : in    std_logic;
        reload_i                : in    std_logic;

        data_o                  : out   std_logic
    );
end entity;

architecture rtl of bit_reg is

    signal data_s               : std_logic;

begin

    data_o                  <= data_s;

    bit_reg_p : process(clk)
    begin 
        if rising_edge(clk) then
            data_s          <= data_s;

            if sample_i = '1' then
                data_s      <= data_i;
            end if;

            if reload_i = '1' then
                data_s      <= '0';
            end if;

            if rst_n = '0' then
                data_s      <= '0';
            end if;
        end if;
    end process;

end rtl ; -- rtl