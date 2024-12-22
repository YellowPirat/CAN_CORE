library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cyclone_axi_slave_extend is
	port (
		S_AXI_AWID    : in   std_logic_vector(11 downto 0);
		S_AXI_BID     : out  std_logic_vector(11 downto 0);
		S_AXI_RID     : out  std_logic_vector(11 downto 0);
		S_AXI_ARID    : in   std_logic_vector(11 downto 0);
		S_AXI_RLAST   : out  std_logic
	);
end cyclone_axi_slave_extend;

architecture rlt of cyclone_axi_slave_extend is

begin

  -- Shit
  S_AXI_RLAST <= '1';
  S_AXI_BID <= S_AXI_AWID;
  S_AXI_RID <= S_AXI_ARID;

end rtl;