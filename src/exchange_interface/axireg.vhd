library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_core_intf.all;
use work.axi_lite_intf.all;

--library olo;

entity axireg is
	port(
		clk               : in   std_logic;
		rst_n             : in   std_logic;

		axi_intf_o		  : out axi_lite_input_intf_t;
		axi_intf_i		  : in 	axi_lite_output_intf_t;


		can_intf		  : inout can_core_comb_intf_t;
		can_valid_i		  : in 	std_logic;
		can_ready_o		  : out std_logic
	);
end entity axireg;

architecture rtl of axireg is

	signal axi_input_s			: axi_lite_input_intf_t;
	signal axi_ouput_s			: axi_lite_output_intf_t;


	signal can_vector_s			: can_core_vector_t;

	signal rst_h				: std_logic;

	-- USER-AXI-Interface
	signal rb_addr 				: std_logic_vector(20 downto 0);
	signal rb_wr				: std_logic;
	signal rb_byte_ena 			: std_logic_vector(3 downto 0);
	signal rb_wr_data 			: std_logic_vector(31 downto 0);
	signal rd_rd 				: std_logic;
	signal rb_rd_data 			: std_logic_vector(31 downto 0);
	signal rb_rd_valid 			: std_logic;

	-- AXI-FIFO-Signals
	signal load_new_s			: std_logic;
	signal store_s				: std_logic;
	signal store_err_s			: std_logic;

	-- FIFO
	signal fifo_in_data_s		: can_core_vector_t;
	signal fifo_in_valid_s		: std_logic;
	signal fifo_in_ready_s		: std_logic;
	signal fifo_out_data_s		: can_core_vector_t;
	signal fifo_out_valid_s		: std_logic;
	signal fifo_out_ready_s		: std_logic;
	signal buffer_usage_s		: std_logic_vector(4 downto 0);

begin

	axi_intf_o <= axi_input_s;
	axi_ouput_s <= axi_intf_i;

	can_vector_s		<= to_can_core_vector(get_can_core_out_intf(can_intf));
	fifo_in_valid_s 	<= can_valid_i;
	can_ready_o			<= fifo_in_ready_s;

	rst_h				<= not rst_n;


	-- AXI LITE INTERFACE
	slave_i0 : entity work.olo_axi_lite_slave
		generic map(
			AxiAddrWidth_g			=> 21,
			AxiDataWidth_g			=> 32,
			ReadTimeoutClks_g		=> 100
		)

		port map(
			Clk						=>	clk,
			Rst						=>  rst_h,
			
			S_AxiLite_ArAddr		=> axi_ouput_s.axi_araddr,
			S_AxiLite_ArValid		=> axi_ouput_s.axi_arvalid,
			S_AxiLite_ArReady		=> axi_input_s.axi_arready,
			
			S_AxiLite_AwAddr		=> axi_ouput_s.axi_awaddr,
			S_AxiLite_AwValid		=> axi_ouput_s.axi_awvalid,
			S_AxiLite_AwReady		=> axi_input_s.axi_awready,
			
			S_AxiLite_WData			=> axi_ouput_s.axi_wdata,
			S_AxiLite_WStrb			=> axi_ouput_s.axi_wstrb,
			S_AxiLite_WValid		=> axi_ouput_s.axi_wvalid,
			S_AxiLite_WReady		=> axi_input_s.axi_wready,
			
			S_AxiLite_BResp			=> axi_input_s.axi_bresp,
			S_AxiLite_BValid		=> axi_input_s.axi_bvalid,
			S_AxiLite_BReady		=> axi_ouput_s.axi_bready,
			
			S_AxiLite_RData			=> axi_input_s.axi_rdata,
			S_AxiLite_RValid		=> axi_input_s.axi_rvalid,
			S_AxiLite_RReady		=> axi_ouput_s.axi_rready,
			
			Rb_Addr					=> rb_addr,
			Rb_Wr					=> rb_wr,
			Rb_ByteEna				=> rb_byte_ena,
			Rb_WrData				=> rb_wr_data,
			Rb_Rd					=> rd_rd,
			Rb_RdData				=> rb_rd_data,
			Rb_RdValid				=> rb_rd_valid
		);

	-- FIFO
	fifo_i0 : entity work.olo_base_fifo_sync
		generic map(
			Width_g		=> 224,
			Depth_g		=> 31
		)

		port map(
			Clk 		=> clk,
			Rst			=> rst_h,

			In_Data		=> can_vector_s,
			In_Valid	=> fifo_in_valid_s,
			In_Ready    => fifo_in_ready_s,

			Out_Data    => fifo_out_data_s,
			Out_Valid	=> fifo_out_valid_s,
			Out_Ready	=> fifo_out_ready_s,

			Out_Level 	=> buffer_usage_s
		);

	-- AXI-FIFO-CNTR
	axi_fifo_cntr_i0 : entity work.axi_fifo_cntr
		port map(
			clk						=> clk,
			rst_n					=> rst_n,

			load_new_i				=> load_new_s,
			valid_i					=> fifo_out_valid_s,

			ready_o					=> fifo_out_ready_s,
			store_o					=> store_s,
			store_err_o				=> store_err_s
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

			buffer_usage_i			=> buffer_usage_s,

			can_frame_i				=> fifo_out_data_s,
			load_new_o				=> load_new_s,
			store_i					=> store_s
		);

	
		
end;
