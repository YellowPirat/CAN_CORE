library ieee;
use ieee.std_logic_1164.all; 

entity axi_shit_cntr is
    port (
        axi_awid    : in   std_logic_vector(11 downto 0);
        axi_bid     : out  std_logic_vector(11 downto 0);
        axi_rid     : out  std_logic_vector(11 downto 0);
        axi_arid    : in   std_logic_vector(11 downto 0);
        axi_rlast   : out  std_logic
    );
end entity;

architecture rtl of axi_shit_cntr is

begin

    axi_rlast <= '1';
    axi_bid <= axi_awid;
    axi_rid <= axi_arid;

end rtl;