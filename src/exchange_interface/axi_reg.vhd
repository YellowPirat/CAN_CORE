library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_lite_intf.all;
use work.can_core_intf.all;
use work.peripheral_intf.all;

entity axi_reg is 
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

		axi_intf_i		        : in    axi_lite_output_intf_t;
		axi_intf_o		        : out 	axi_lite_input_intf_t;

        can_frame_i             : in    can_core_out_intf_t;
        peripheral_status_i     : in    per_intf_t;

        ready_o                 : out   std_logic;
        valid_i                 : in    std_logic;

        load_new_o              : out   std_logic
    );
end entity axi_reg;

architecture rtl of axi_reg is

	-- USER-AXI-Interface
	signal rb_addr 				: std_logic_vector(20 downto 0);
	signal rb_wr				: std_logic;
	signal rb_byte_ena 			: std_logic_vector(3 downto 0);
	signal rb_wr_data 			: std_logic_vector(31 downto 0);
	signal rd_rd 				: std_logic;
	signal rb_rd_data 			: std_logic_vector(31 downto 0);
	signal rb_rd_valid 			: std_logic;
    -- RESET
    signal rst_h                : std_logic;

    signal load_new_s           : std_logic;
    signal store_s              : std_logic;

begin

    load_new_o          <= load_new_s;

    rst_h               <= not rst_n;

	axi_fifo_cntr_i0 : entity work.axi_fifo_cntr
		port map(
			clk						=> clk,
			rst_n					=> rst_n,

			load_new_i				=> load_new_s,
			valid_i					=> valid_i,

			ready_o					=> ready_o,
			store_o					=> store_s
		);

	-- OUTPUT CNTR
	axi_addr_cntr_i0 : entity work.axi_addr_cntr
		port map(
			clk						=> clk,
			rst_n					=> rst_n,

			olo_axi_rb_addr_i		=> rb_addr,
			olo_axi_rb_wr_i			=> rb_wr,
			olo_axi_rb_byte_ena_i	=> rb_byte_ena,
			olo_axi_rb_wr_data_i	=> rb_wr_data,
			olo_axi_rb_rd_i			=> rd_rd,
			olo_axi_rb_rd_data_o	=> rb_rd_data,
			olo_axi_rb_rd_valid_o	=> rb_rd_valid,

			per_intf_i				=> peripheral_status_i,
			can_frame_i				=> can_frame_i,
    
			load_new_o				=> load_new_s,
			store_i					=> store_s
		);

    slave_i0 : entity work.olo_axi_lite_slave
        generic map(
            AxiAddrWidth_g			=> 21,
            AxiDataWidth_g			=> 32,
            ReadTimeoutClks_g		=> 100
        )
        port map(
            Clk						=>	clk,
            Rst						=>  rst_h,
            
            S_AxiLite_ArAddr		=> axi_intf_i.axi_araddr,
            S_AxiLite_ArValid		=> axi_intf_i.axi_arvalid,
            S_AxiLite_ArReady		=> axi_intf_o.axi_arready,
            
            S_AxiLite_AwAddr		=> axi_intf_i.axi_awaddr,
            S_AxiLite_AwValid		=> axi_intf_i.axi_awvalid,
            S_AxiLite_AwReady		=> axi_intf_o.axi_awready,
            
            S_AxiLite_WData			=> axi_intf_i.axi_wdata,
            S_AxiLite_WStrb			=> axi_intf_i.axi_wstrb,
            S_AxiLite_WValid		=> axi_intf_i.axi_wvalid,
            S_AxiLite_WReady		=> axi_intf_o.axi_wready,
            
            S_AxiLite_BResp			=> axi_intf_o.axi_bresp,
            S_AxiLite_BValid		=> axi_intf_o.axi_bvalid,
            S_AxiLite_BReady		=> axi_intf_i.axi_bready,
            
            S_AxiLite_RData			=> axi_intf_o.axi_rdata,
            S_AxiLite_RValid		=> axi_intf_o.axi_rvalid,
            S_AxiLite_RReady		=> axi_intf_i.axi_rready,
            
            Rb_Addr					=> rb_addr,
            Rb_Wr					=> rb_wr,
            Rb_ByteEna				=> rb_byte_ena,
            Rb_WrData				=> rb_wr_data,
            Rb_Rd					=> rd_rd,
            Rb_RdData				=> rb_rd_data,
            Rb_RdValid				=> rb_rd_valid
        );



end rtl;