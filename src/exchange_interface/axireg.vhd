library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_core_intf.all;

--library olo;

entity axireg is
generic(
	FifoFrameWidth_g    : positive := 160;
	CanDataLengh_g      : positive := 64;
	TimeStampLengh_g    : positive := 48;
	AddrSpaceStartPos_g	: std_logic_vector(20 downto 0) := "000000000000000000000";
	FifoDepth_g         : positive := 6
);
port(
	clk               : in   std_logic;
	rst_n             : in   std_logic;

	-- AXI-Out
	axi_slave_awaddr  : in   std_logic_vector(20 downto 0);
	axi_slave_awvalid : in   std_logic;
	axi_slave_awready : out  std_logic;

	axi_slave_wdata   : in   std_logic_vector(31 downto 0);
	axi_slave_wvalid  : in   std_logic;
	axi_slave_wready  : out  std_logic;

	axi_slave_bresp   : out  std_logic_vector(1 downto 0);
	axi_slave_bvalid  : out  std_logic;
	axi_slave_bready  : in   std_logic;

	axi_slave_araddr  : in   std_logic_vector(20 downto 0);
	axi_slave_arvalid : in   std_logic;
	axi_slave_arready : out  std_logic;

	axi_slave_rdata   : out  std_logic_vector(31 downto 0);
	axi_slave_rvalid  : out  std_logic;
	axi_slave_rready  : in   std_logic;
	axi_slave_rresp   : out  std_logic_vector(1 downto 0);

	-- CAN-INPUT
	timestamp		  : in  std_logic_vector(TimeStampLengh_g - 1 downto 0);
	can_id            : in  std_logic_vector(28 downto 0);
	rtr               : in  std_logic;
	eff               : in  std_logic;
	err               : in  std_logic;
	dlc               : in  std_logic_vector(3 downto 0);
	data              : in  std_logic_vector(CanDataLengh_g -1 downto 0);
	core_error        : in  std_logic_vector(3 downto 0);
	
	-- DATA-CNTR-INPUT
	input_fifo_valid  : in  std_logic;
	input_fifo_ready  : out std_logic;
	
	-- ERROR
	fifo_full         : out std_logic


);
end entity axireg;

architecture rtl of axireg is
	-- USER-AXI-Interface
	signal rb_addr : 	std_logic_vector(20 downto 0);
	signal rb_wr	:	std_logic;
	signal rb_byte_ena : std_logic_vector(3 downto 0);
	signal rb_wr_data : std_logic_vector(31 downto 0);
	signal rd_rd : std_logic;
	signal rb_rd_data : std_logic_vector(31 downto 0);
	signal rb_rd_valid : std_logic;
	
	-- Register
	signal axi_slave_wstrb   :  std_logic_vector(3 downto 0);

	-- FIFO
	signal output_data_s     : std_logic_vector(FifoFrameWidth_g - 1 downto 0);
	signal output_valid_s    : std_logic;
	signal output_ready_s    : std_logic;

	signal fifo_empty_s      : std_logic;
	signal fifo_full_s       : std_logic;
	signal depth_s           : std_logic_vector(4 downto 0);

	signal input_fifo_data   : std_logic_vector(FifoFrameWidth_g - 1 downto 0);

	-- FIFO OUTPUT CNTR
	type state_output_t is (idle_s, read_s, store_s, error_s, start_s);
	signal current_state_output, next_state_output : state_output_t;

	-- RESET
	signal rst_h : std_logic;

	-- FSM CNTR
	signal en_s, err_s       	: std_logic;

	-- AXI REG
	signal axireg_s				: std_logic_vector(FifoFrameWidth_g - 1 downto 0);

	-- Intf
	signal can_core_intf_fifo_input_s  		: can_core_intf_t;
	signal can_core_intf_fifo_axireg_s		: can_core_intf_t;
	signal can_core_intf_axireg_input_s		: can_core_intf_t;
	signal error_code_s						: std_logic_vector(4 downto 0);

begin


	-- SHIT INTERFACE
	axi_slave_rresp <= "00";
	rst_h <= not rst_n;


	-- Input Mapping
	error_code_s(3 downto 0)								<= core_error;
	error_code_s(4) 										<= '0';									
	can_core_intf_fifo_input_s.error_codes					<= error_code_s;
	can_core_intf_fifo_input_s.frame_type					<= "00";
	can_core_intf_fifo_input_s.buffer_usage					<= "00000";
	can_core_intf_fifo_input_s.timestamp					<= timestamp;
	can_core_intf_fifo_input_s.can_dlc						<= dlc;
	can_core_intf_fifo_input_s.can_id						<= can_id;
	can_core_intf_fifo_input_s.rtr							<= rtr;
	can_core_intf_fifo_input_s.eff							<= eff;
	can_core_intf_fifo_input_s.err							<= err;
	can_core_intf_fifo_input_s.data						<= data;

	input_fifo_data <= std_logic_vector(to_can_core_vector(can_core_intf_fifo_input_s));



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
			
			S_AxiLite_ArAddr		=>	axi_slave_araddr,
			S_AxiLite_ArValid		=>	axi_slave_arvalid,
			S_AxiLite_ArReady		=> 	axi_slave_arready,
			
			S_AxiLite_AwAddr		=> axi_slave_awaddr,
			S_AxiLite_AwValid		=> axi_slave_awvalid,
			S_AxiLite_AwReady		=> axi_slave_awready,
			
			S_AxiLite_WData			=> axi_slave_wdata,
			S_AxiLite_WStrb			=> axi_slave_wstrb,
			S_AxiLite_WValid		=> axi_slave_wvalid,
			S_AxiLite_WReady		=> axi_slave_wready,
			
			S_AxiLite_BResp			=> axi_slave_bresp,
			S_AxiLite_BValid		=> axi_slave_bvalid,
			S_AxiLite_BReady		=> axi_slave_bready,
			
			S_AxiLite_RData			=> axi_slave_rdata,
			S_AxiLite_RValid		=> axi_slave_rvalid,
			S_AxiLite_RReady		=> axi_slave_rready,
			
			Rb_Addr					=> rb_addr,
			Rb_Wr					=> rb_wr,
			Rb_ByteEna				=> rb_byte_ena,
			Rb_WrData				=> rb_wr_data,
			Rb_Rd					=> rd_rd,
			Rb_RdData				=> rb_rd_data,
			Rb_RdValid				=> rb_rd_valid
		);


	--- FIFO OUTPUT CNTR 
	o_p : process(current_state_output, output_valid_s, rd_rd, Rb_Addr)
	begin 
		next_state_output <= current_state_output;
		output_ready_s <= '0';
		en_s <= '0';
		err_s <= '0';

		case current_state_output is
			when idle_s => 
				if rd_rd = '1' and unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 16 and unsigned(depth_s) > 0 then
					next_state_output <= read_s;
				elsif rd_rd = '1' and unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 16 and unsigned(depth_s) = 0 then
					next_state_output <= error_s;
				else 
					next_state_output <= idle_s;
				end if;

			when read_s =>
				if output_valid_s = '1' then 
					next_state_output <= store_s;
				end if;
				
			when store_s =>
				next_state_output <= idle_s;
				en_s <= '1';
				output_ready_s <= '1';

			when error_s =>
				next_state_output <= idle_s;
				err_s <= '1';
				en_s <= '1';

			when start_s =>
				next_state_output <= read_s;


			when others => 
				next_state_output <= idle_s;	
		end case;
	end process o_p;

	current_state_output <= start_s when rst_n = '0' else next_state_output when rising_edge(clk);

	

	-- FIFO
	fifo_i0 : entity work.olo_base_fifo_sync
		generic map(
			Width_g		=> FifoFrameWidth_g,
			Depth_g		=> FifoDepth_g
		)

		port map(
			Clk 		=> clk,
			Rst			=> rst_h,

			In_Data		=> input_fifo_data,
			In_Valid	=> input_fifo_valid,
			In_Ready    => input_fifo_ready,

			Out_Data    => output_data_s,
			Out_Valid	=> output_valid_s,
			Out_Ready	=> output_ready_s,

			Full		=> fifo_full,
			Out_Level	=> depth_s
		);





	can_core_intf_fifo_axireg_s <= get_empty_can_core_intf when rst_n = '0' else can_core_intf_axireg_input_s when rising_edge(clk);

	can_core_intf_axireg_input_s.error_codes(3 downto 0) 	<= to_can_core_intf(can_core_vector_t(output_data_s)).error_codes(3 downto 0) 		when en_s = '1' 				else can_core_intf_fifo_axireg_s.error_codes(3 downto 0);
	can_core_intf_axireg_input_s.error_codes(4) 			<= '1' 																				when err_s = '1' and en_s = '1' else can_core_intf_fifo_axireg_s.error_codes(4);
	can_core_intf_axireg_input_s.frame_type 				<= to_can_core_intf(can_core_vector_t(output_data_s)).frame_type 					when en_s = '1' 				else can_core_intf_fifo_axireg_s.frame_type;
	can_core_intf_axireg_input_s.buffer_usage 				<= depth_s;
	can_core_intf_axireg_input_s.timestamp					<= to_can_core_intf(can_core_vector_t(output_data_s)).timestamp						when en_s = '1'					else can_core_intf_fifo_axireg_s.timestamp;
	can_core_intf_axireg_input_s.can_dlc					<= to_can_core_intf(can_core_vector_t(output_data_s)).can_dlc						when en_s = '1'					else can_core_intf_fifo_axireg_s.can_dlc;
	can_core_intf_axireg_input_s.can_id						<= to_can_core_intf(can_core_vector_t(output_data_s)).can_id						when en_s = '1'					else can_core_intf_fifo_axireg_s.can_id;
	can_core_intf_axireg_input_s.rtr						<= to_can_core_intf(can_core_vector_t(output_data_s)).rtr							when en_s = '1'					else can_core_intf_fifo_axireg_s.rtr;
	can_core_intf_axireg_input_s.eff						<= to_can_core_intf(can_core_vector_t(output_data_s)).eff							when en_s = '1'					else can_core_intf_fifo_axireg_s.eff;
	can_core_intf_axireg_input_s.err						<= to_can_core_intf(can_core_vector_t(output_data_s)).err							when en_s = '1' 				else can_core_intf_fifo_axireg_s.err;
	can_core_intf_axireg_input_s.data						<= to_can_core_intf(can_core_vector_t(output_data_s)).data							when en_s = '1'					else can_core_intf_fifo_axireg_s.data;


	p_rb : process(clk)
	begin
		if rising_edge(clk) then
			rb_rd_valid <= '0';
			if rd_rd = '1' then
				if unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) then 
					rb_rd_data <= to_can_core_vector(can_core_intf_fifo_axireg_s)(31 downto 0);
				elsif unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 4 then 
					rb_rd_data <= to_can_core_vector(can_core_intf_fifo_axireg_s)(63 downto 32);
				elsif unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 8 then
					rb_rd_data <= to_can_core_vector(can_core_intf_fifo_axireg_s)(95 downto 64);
				elsif unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 12 then 
					rb_rd_data <= to_can_core_vector(can_core_intf_fifo_axireg_s)(127 downto 96);
				elsif unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 16 then
					rb_rd_data <= to_can_core_vector(can_core_intf_fifo_axireg_s)(159 downto 128);
 				else
					rb_rd_data(31 downto 0) <= (others => '0');
				end if;

				rb_rd_valid <= '1';
			end if;
		end if;
	end process;
	
		
end;
