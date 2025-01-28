library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bit_reg is
    port(
        clk                     : in    std_logic                   := '0';
        rst_n                   : in    std_logic                   := '1';
        data_i                  : in    std_logic                   := '1';
        sample_i                : in    std_logic                   := '0';
        reload_i                : in    std_logic                   := '0';
        data_o                  : out   std_logic                   := '0'
    );
end entity;

architecture rtl of bit_reg is

    signal data_s               : std_logic                         := '0';

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