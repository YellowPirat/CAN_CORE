library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axi_lite_intf is

    type axi_lite_input_intf_t is record
        -- Address Write
        axi_awready         : std_logic;
        -- Write
        axi_wready          : std_logic;
        -- Write Response
        axi_bresp           : std_logic_vector(1 downto 0);
        axi_bvalid          : std_logic;
        -- Read Address
        axi_arready         : std_logic;
        -- Read Data
        axi_rdata           : std_logic_vector(31 downto 0);
        axi_rresp           : std_logic_vector(1 downto 0);
        axi_rvalid          : std_logic;
    end record;

    type axi_lite_output_intf_t is record
        -- Address Write
        axi_awaddr          : std_logic_vector(20 downto 0);
        axi_awvalid         : std_logic;
        -- Write Data
        axi_wdata           : std_logic_vector(31 downto 0);
        axi_wvalid          : std_logic;
        axi_wstrb           : std_logic_vector(3 downto 0);
        -- Write Response
        axi_bready          : std_logic;
        -- Read Address
        axi_araddr          : std_logic_vector(20 downto 0);
        axi_arvalid         : std_logic;
        -- Read Data
        axi_rready          : std_logic;
    end record;

    type axi_lite_comb_intf_t is record
        output               : axi_lite_output_intf_t;
        input                : axi_lite_input_intf_t;
    end record;

    type axi_lite_intf_t is record
        -- Address Write
        axi_awaddr          : std_logic_vector(20 downto 0);
        axi_awvalid         : std_logic;
        axi_awready         : std_logic;
        -- Write Data
        axi_wdata           : std_logic_vector(31 downto 0);
        axi_wstrb           : std_logic_vector(3 downto 0);
        axi_wvalid          : std_logic;
        axi_wready          : std_logic;
        -- B
        axi_bresp           : std_logic_vector(1 downto 0);
        axi_bvalid          : std_logic;
        axi_bready          : std_logic;
        -- Address Read
        axi_araddr          : std_logic_vector(20 downto 0);
        axi_arvalid         : std_logic;
        axi_arready         : std_logic;
        -- Read Data
        axi_rdata           : std_logic_vector(31 downto 0);
        axi_rresp           : std_logic_vector(1 downto 0);
        axi_rvalid          : std_logic;
        axi_rready          : std_logic;
    end record;

    function get_axi_lite_intf(axi_lite_comp_intf : axi_lite_comb_intf_t) return axi_lite_intf_t;
    function get_axi_comp_intf(axi_lite_intf : axi_lite_intf_t) return axi_lite_comb_intf_t;

end package axi_lite_intf;

package body axi_lite_intf is

    function get_axi_lite_intf(axi_lite_comp_intf : axi_lite_comb_intf_t) return axi_lite_intf_t is 
        variable ret : axi_lite_intf_t;
    begin 
        ret.axi_awaddr      := axi_lite_comp_intf.output.axi_awaddr;
        ret.axi_awvalid     := axi_lite_comp_intf.output.axi_awvalid;
        ret.axi_awready     := axi_lite_comp_intf.input.axi_awready;

        ret.axi_wdata       := axi_lite_comp_intf.output.axi_wdata;
        ret.axi_wstrb       := axi_lite_comp_intf.output.axi_wstrb;
        ret.axi_wvalid      := axi_lite_comp_intf.output.axi_wvalid;
        ret.axi_wready      := axi_lite_comp_intf.input.axi_wready;

        ret.axi_bresp       := axi_lite_comp_intf.input.axi_bresp;
        ret.axi_bvalid      := axi_lite_comp_intf.input.axi_bvalid;
        ret.axi_bready      := axi_lite_comp_intf.output.axi_bready;

        ret.axi_araddr      := axi_lite_comp_intf.output.axi_araddr;
        ret.axi_arvalid     := axi_lite_comp_intf.output.axi_arvalid;
        ret.axi_arready     := axi_lite_comp_intf.input.axi_arready;

        ret.axi_rdata       := axi_lite_comp_intf.input.axi_rdata;
        ret.axi_rresp       := axi_lite_comp_intf.input.axi_rresp;
        ret.axi_rvalid      := axi_lite_comp_intf.input.axi_rvalid;
        ret.axi_rready      := axi_lite_comp_intf.output.axi_rready;

        return ret;

    end function;

    function get_axi_comp_intf(axi_lite_intf : axi_lite_intf_t) return axi_lite_comb_intf_t is
        variable ret : axi_lite_comb_intf_t;
    begin 
        ret.output.axi_awaddr       := axi_lite_intf.axi_awaddr;
        ret.output.axi_awvalid      := axi_lite_intf.axi_awvalid;
        ret.input.axi_awready       := axi_lite_intf.axi_awready;

        ret.output.axi_wdata        := axi_lite_intf.axi_wdata;
        ret.output.axi_wstrb        := axi_lite_intf.axi_wstrb;
        ret.output.axi_wvalid       := axi_lite_intf.axi_wvalid;
        ret.input.axi_wready        := axi_lite_intf.axi_wready;

        ret.input.axi_bresp         := axi_lite_intf.axi_bresp;
        ret.input.axi_bvalid        := axi_lite_intf.axi_bvalid;
        ret.output.axi_bready       := axi_lite_intf.axi_bready;

        ret.output.axi_araddr       := axi_lite_intf.axi_araddr;
        ret.output.axi_arvalid      := axi_lite_intf.axi_arvalid;
        ret.input.axi_arready       := axi_lite_intf.axi_arready;

        ret.input.axi_rdata         := axi_lite_intf.axi_rdata;
        ret.input.axi_rresp         := axi_lite_intf.axi_rresp;
        ret.input.axi_rvalid        := axi_lite_intf.axi_rvalid;
        ret.output.axi_rready       := axi_lite_intf.axi_rready;

        return ret;
    end function;


        

end package body axi_lite_intf;