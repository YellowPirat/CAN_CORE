library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

use work.axi_lite_intf.all;

entity t_core is
end entity;

architecture tbench of t_core is

  signal clk, rst_n : std_logic := '0';
  signal simstop : boolean      := false;

  signal axi_intf_o             : axi_lite_output_intf_t;
  signal axi_intf_i             : axi_lite_input_intf_t;

  signal rxd_async_s            : std_logic_vector(0 downto 0);

begin
  
  -- Clock generation
  clk_p : process
  begin
    clk <= '0';
    wait for 10 ns; 
    clk <= '1'; 
    wait for 10 ns;
    if simstop then
      wait;
    end if;
  end process clk_p;

  -- Reset generation
  rst_p : process
  begin
    rst_n <= '0';
    wait for 20 ns;
    rst_n <= '1';
    wait;
  end process rst_p;

  simstop_p : process
  begin
    wait for 1000 us;
    simstop <= true;
    wait;
  end process simstop_p;


    hps_engine_i0 : entity work.t_hps_engine
        port map(
        clk                 => clk,
        rst_n               => rst_n,

        axi_awaddr        => axi_intf_o.axi_awaddr,
        axi_awvalid       => axi_intf_o.axi_awvalid,
        axi_awready       => axi_intf_i.axi_awready,

        axi_wdata         => axi_intf_o.axi_wdata,
        axi_wvalid        => axi_intf_o.axi_wvalid,
        axi_wready        => axi_intf_i.axi_wready,

        axi_bresp         => axi_intf_i.axi_bresp,
        axi_bvalid        => axi_intf_i.axi_bvalid,
        axi_bready        => axi_intf_o.axi_bready,

        axi_araddr        => axi_intf_o.axi_araddr,
        axi_arvalid       => axi_intf_o.axi_arvalid,
        axi_arready       => axi_intf_i.axi_arready,

        axi_rdata         => axi_intf_i.axi_rdata,
        axi_rresp         => axi_intf_i.axi_rresp,
        axi_rvalid        => axi_intf_i.axi_rvalid,
        axi_rready        => axi_intf_o.axi_rready          
        );


    cangen_i0 : entity work.cangen
        port map(
            rst_n                   => rst_n,
            rxd_o                   => rxd_async_s(0),
            simstop                 => simstop
        );


    -- DUT instantiation
    core_i0 : entity work.de1_core
    
        port map (
            clk                 => clk,
            rst_n               => rst_n,

            rxd_async_i         => rxd_async_s,

            axi_intf_i          => axi_intf_o,
            axi_intf_o          => axi_intf_i
        );



end architecture;
