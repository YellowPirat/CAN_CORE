library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.axi_lite_intf.all;
use work.can_core_intf.all;
use work.peripheral_intf.all;
use work.baud_intf.all;

entity de1_core is
    generic (
        can_core_count_g        : positive := 1
    );
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        rxd_async_i         : in    std_logic_vector(can_core_count_g - 1 downto 0);

        uart_debug_o        : out   std_logic_vector(can_core_count_g - 1 downto 0);

        debug_o             : out   std_logic_vector(can_core_count_g - 1 downto 0);

        axi_intf_i          : in    axi_lite_output_intf_t;
        axi_intf_o          : out   axi_lite_input_intf_t
    );
end entity;

architecture rtl of de1_core is

    signal can_frame_s          : can_frame_vec_t(can_core_count_g - 1 downto 0);
    signal can_frame_valid_s    : std_logic_vector(can_core_count_g - 1 downto 0);

    signal axi_awaddr_s         : axi_addr_vec_t(can_core_count_g - 1 downto 0);
    signal axi_awvalid_s        : axi_sig_vec_t(can_core_count_g - 1 downto 0);
    signal axi_awready_s        : axi_sig_vec_t(can_core_count_g - 1 downto 0);

    signal axi_wdata_s          : axi_data_vec_t(can_core_count_g - 1 downto 0);
    signal axi_wvalid_s         : axi_sig_vec_t(can_core_count_g - 1 downto 0);
    signal axi_wready_s         : axi_sig_vec_t(can_core_count_g - 1 downto 0);

    signal axi_bresp_s          : axi_resp_vec_t(can_core_count_g - 1 downto 0);
    signal axi_bvalid_s         : axi_sig_vec_t(can_core_count_g - 1 downto 0);
    signal axi_bready_s         : axi_sig_vec_t(can_core_count_g - 1 downto 0);

    signal axi_araddr_s         : axi_addr_vec_t(can_core_count_g - 1 downto 0);
    signal axi_arvalid_s        : axi_sig_vec_t(can_core_count_g - 1 downto 0);
    signal axi_arready_s        : axi_sig_vec_t(can_core_count_g - 1 downto 0);

    signal axi_rdata_s          : axi_data_vec_t(can_core_count_g - 1 downto 0);
    signal axi_rresp_s          : axi_resp_vec_t(can_core_count_g - 1 downto 0);
    signal axi_rvalid_s         : axi_sig_vec_t(can_core_count_g - 1 downto 0);
    signal axi_rready_s         : axi_sig_vec_t(can_core_count_g - 1 downto 0);


    signal baud_config_s        : baud_intf_vec_t(can_core_count_g - 1 downto 0);

    signal driver_reset_vec_s   : std_logic_vector(can_core_count_g - 1 downto 0);
    signal reset_sync_s         : std_logic_vector(can_core_count_g - 1 downto 0);

begin 

    axi_smmm_i0 : entity work.axi_smmmm
        generic map(
            slave_count_g           => can_core_count_g,
            start_addr_g            => to_unsigned(0, 21),
            offset_addr_g           => to_unsigned(4096, 21)
        )
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            m_axi_awaddr            => axi_intf_i.axi_awaddr,
            m_axi_awvalid           => axi_intf_i.axi_awvalid,
            m_axi_awready           => axi_intf_o.axi_awready,

            m_axi_wdata             => axi_intf_i.axi_wdata,
            m_axi_wvalid            => axi_intf_i.axi_wvalid,
            m_axi_wready            => axi_intf_o.axi_wready,

            m_axi_bresp             => axi_intf_o.axi_bresp,
            m_axi_bvalid            => axi_intf_o.axi_bvalid,
            m_axi_bready            => axi_intf_i.axi_bready,

            m_axi_araddr            => axi_intf_i.axi_araddr,
            m_axi_arvalid           => axi_intf_i.axi_arvalid,
            m_axi_arready           => axi_intf_o.axi_arready,

            m_axi_rdata             => axi_intf_o.axi_rdata,
            m_axi_rresp             => axi_intf_o.axi_rresp,
            m_axi_rvalid            => axi_intf_o.axi_rvalid,
            m_axi_rready            => axi_intf_i.axi_rready,


            s_axi_awaddr            => axi_awaddr_s,
            s_axi_awvalid           => axi_awvalid_s,
            s_axi_awready           => axi_awready_s,

            s_axi_wdata             => axi_wdata_s,
            s_axi_wvalid            => axi_wvalid_s,
            s_axi_wready            => axi_wready_s,

            s_axi_bresp             => axi_bresp_s,
            s_axi_bvalid            => axi_bvalid_s,
            s_axi_bready            => axi_bready_s,

            s_axi_araddr            => axi_araddr_s,
            s_axi_arvalid           => axi_arvalid_s,
            s_axi_arready           => axi_arready_s,

            s_axi_rdata             => axi_rdata_s,
            s_axi_rresp             => axi_rresp_s,
            s_axi_rvalid            => axi_rvalid_s,
            s_axi_rready            => axi_rready_s
        );


    can_core_gen : for i in 0 to can_core_count_g - 1 generate


        exchange_interface_i0 : entity work.de1_exchange_interface
            generic map(
                memory_depth_g          => 256,
                width_g                 => 32,
                offset_g                => std_logic_vector(to_unsigned(i * 4096, 21))
            )
            port map(
                clk                     => clk,
                rst_n                   => rst_n,

                axi_intf_o.axi_awready  => axi_awready_s(i),

                axi_intf_o.axi_wready   => axi_wready_s(i),

                axi_intf_o.axi_bresp    => axi_bresp_s(i),
                axi_intf_o.axi_bvalid   => axi_bvalid_s(i),

                axi_intf_o.axi_arready  => axi_arready_s(i),

                axi_intf_o.axi_rdata    => axi_rdata_s(i),
                axi_intf_o.axi_rresp    => axi_rresp_s(i),
                axi_intf_o.axi_rvalid   => axi_rvalid_s(i),
                

                axi_intf_i.axi_awaddr   => axi_awaddr_s(i),
                axi_intf_i.axi_awvalid  => axi_awvalid_s(i),

                axi_intf_i.axi_wdata    => axi_wdata_s(i),
                axi_intf_i.axi_wvalid   => axi_wvalid_s(i),
                axi_intf_i.axi_wstrb    => (others => '0'),

                axi_intf_i.axi_bready   => axi_bready_s(i),

                axi_intf_i.axi_araddr   => axi_araddr_s(i),
                axi_intf_i.axi_arvalid  => axi_arvalid_s(i),

                axi_intf_i.axi_rready   => axi_rready_s(i),


                driver_reset_o          => driver_reset_vec_s(i),

                can_frame_i             => can_frame_s(i),
                can_frame_valid_i       => can_frame_valid_s(i),

                baud_config_o           => baud_config_s(i)
            );

        reset_sync_s(i)                 <= rst_n and (not driver_reset_vec_s(i));
        debug_o(i)                      <= reset_sync_s(i);

        de1_can_core_i0 : entity work.de1_can_core
            generic map(
                width_g                 => 32
            )
            port map(
                clk                     => clk,
                rst_n                   => reset_sync_s(i),

                rxd_async_i(0)          => rxd_async_i(i),

                can_frame_o             => can_frame_s(i),
                can_frame_valid_o       => can_frame_valid_s(i),

                baud_config_i           => baud_config_s(i)
            );

            debug_i0 : entity work.de1_debug
            generic map(
                widght_g                => 128
            )
            port map(
                clk                     => clk,
                rst_n                   => reset_sync_s(i),
    
                can_frame_i             => can_frame_s(i),
                valid_i                 => can_frame_valid_s(i),

                txd_o                   => uart_debug_o(i)
            );
    end generate can_core_gen;


end rtl;