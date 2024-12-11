library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.axi_lite_intf.all;
use work.can_core_intf.all;

entity de1_exchange_interface is
    port (
        -- Global clock and reset
        clk           : in std_logic;
        rst_n         : in std_logic;
        

        axi_intf_o    : out axi_lite_input_intf_t;
        axi_intf_i    : in  axi_lite_output_intf_t;

        -- SHIT SIGNALS

        axi_awid    : in  std_logic_vector(11 downto 0) := (others => '0');
        axi_bid     : out std_logic_vector(11 downto 0) := (others => '0');
        axi_rid     : out std_logic_vector(11 downto 0) := (others => '0');
        axi_arid    : in  std_logic_vector(11 downto 0) := (others => '0');
        axi_rlast   : out std_logic := '0'
    );
end de1_exchange_interface;

architecture rtl of de1_exchange_interface is
    signal can_intf_s           : can_core_comb_intf_t;
    signal can_valid_s          : std_logic;
    signal can_ready_s          : std_logic;
    

    signal s1_axi_s               : axi_lite_comb_intf_t;
    signal s2_axi_s               : axi_lite_comb_intf_t;
    signal m_axi_intf_s           : axi_lite_comb_intf_t;

begin



    intercon_i0 : entity work.axi_interconnect
        port map(
            -- MASTER -> SLAVE
            m_axi_intf              => m_axi_intf_s,

            -- SLAVE -> MASTER
            s1_axi_intf             => s1_axi_s,
            s2_axi_intf             => s2_axi_s,

            -- Shit
            S_AXI_AWID              => axi_awid,
            S_AXI_BID               => axi_bid,
            S_AXI_RID               => axi_rid,
            S_AXI_ARID              => axi_arid,
            S_AXI_RLAST             => axi_rlast
        );


    axiret_i0 : entity work.axireg
        port map(
            clk                     => clk,
            rst_n                   => rst_n,
        
            axi_intf_i              => axi_intf_i,
            axi_intf_o              => axi_intf_o,

            bus_active_i            => '1',

            can_intf                => can_intf_s,
            can_valid_i             => can_valid_s,
            can_ready_o             => can_ready_s
        );

    can_core_sim_i0 : entity work.exchange_testbench
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            can_core_intf           => can_intf_s,
            output_fifo_valid       => can_valid_s,
            output_fifo_ready       => can_ready_s
        );

    

end rtl;

