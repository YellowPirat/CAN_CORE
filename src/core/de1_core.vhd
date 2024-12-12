library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.axi_lite_intf.all;
use work.can_core_intf.all;
use work.peripheral_intf.all;

entity de1_core is
    generic (
        can_core_count_g        : positive := 1
    );
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        rxd_async_i         : in    std_logic_vector(can_core_count_g - 1 downto 0);

        uart_debug_o        : out   std_logic_vector(can_core_count_g - 1 downto 0);

        axi_intf_i          : in    axi_lite_output_intf_t;
        axi_intf_o          : out   axi_lite_input_intf_t

    );
end entity;

architecture rtl of de1_core is

    signal can_frame_s          : can_core_out_intf_t;
    signal peripheral_status_s  : per_intf_t;
    signal can_frame_valid_s    : std_logic;

begin 


    exchange_interface_i0 : entity work.de1_exchange_interface
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            axi_intf_o              => axi_intf_o,
            axi_intf_i              => axi_intf_i,

            can_frame_i             => can_frame_s,
            can_frame_valid_i       => can_frame_valid_s,

            peripheral_status_i     => peripheral_status_s
        );

    frame_gen_i0 : entity work.de1_frame_gen
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            can_frame_o             => can_frame_s,
            can_frame_valid_o       => can_frame_valid_s,

            peripheral_status_o     => peripheral_status_s
        );


end rtl;