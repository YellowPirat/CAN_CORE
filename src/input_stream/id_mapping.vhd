library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity id_mapping is
    port(
        eff_i           : in    std_logic;
        eid_i           : in    std_logic_vector(17 downto 0);
        id_i            : in    std_logic_vector(10 downto 0);

        id_o            : out   std_logic_vector(28 downto 0)
    );
end entity;

architecture rtl of id_mapping is

    signal id_s         : std_logic_vector(28 downto 0);

begin

    id_s(10 downto 0)   <= id_i when eff_i = '0' else eid_i(10 downto 0);
    id_s(17 downto 11)  <= (others => '0') when eff_i = '0' else eid_i(17 downto 11);
    id_s(28 downto 18)  <= (others => '0') when eff_i = '0' else id_i;

    id_o    <= id_s;

end rtl ; -- rtl