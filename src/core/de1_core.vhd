library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_core is
    port(
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        rxd_sync_i          : in    std_logic;
        sample_i            : in    std_logic;
        stuff_bit_i         : in    std_logic
    );
end entity;

architecture rtl of de1_core is

    

begin

end rtl ;