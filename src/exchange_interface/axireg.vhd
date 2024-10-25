library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
	
	--input_fifo_data   : in  std_logic_vector(FifoFrameWidth_g - 1 downto 0);
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
	signal depth_s           : std_logic_vector(2 downto 0);

	signal input_fifo_data   : std_logic_vector(FifoFrameWidth_g - 1 downto 0);

	-- FIFO OUTPUT CNTR
	type state_output_t is (idle_s, read_s, next_s);
	signal current_state_output, next_state_output : state_output_t;

	-- RESET
	signal rst_h : std_logic;

	constant AddrSpaceStartPosPlus4_g : std_logic_vector(20 downto 0) := std_logic_vector(unsigned(AddrSpaceStartPos_g) + 4);


begin


	-- SHIT INTERFACE
	axi_slave_rresp <= "00";
	rst_h <= not rst_n;

	-- Input Mapping

	input_fifo_data(TimeStampLengh_g - 1 downto 0) <= timestamp;
	input_fifo_data(TimeStampLengh_g + 29 - 1 downto TimeStampLengh_g) <= can_id;
	input_fifo_data(TimeStampLengh_g + 29) <= rtr;
	input_fifo_data(TimeStampLengh_g + 30) <= eff;
	input_fifo_data(TimeStampLengh_g + 31) <= err;
	input_fifo_data(TimeStampLengh_g + 36 - 1 downto TimeStampLengh_g + 32) <= dlc;
	input_fifo_data(TimeStampLengh_g + CanDataLengh_g + 36 - 1 downto TimeStampLengh_g + 36) <= data;
	input_fifo_data(TimeStampLengh_g + CanDataLengh_g + 40 - 1 downto TimeStampLengh_g + CanDataLengh_g + 36) <= core_error;
	input_fifo_data(FifoFrameWidth_g - 1 downto TimeStampLengh_g + CanDataLengh_g + 40) <= (others => '0');

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

		case current_state_output is
			when idle_s => 
				if output_valid_s = '1' then
					next_state_output <= read_s;
				end if;

			when read_s =>
				if rd_rd = '1' and unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 16 then
					next_state_output <= next_s;
				end if;
				
			when next_s =>
				if output_valid_s = '1' then 
					next_state_output <= read_s;
				else 
					next_state_output <= idle_s;
				end if;
				output_ready_s <= '1';

			when others => 
				next_state_output <= idle_s;	
		end case;
	end process o_p;

	current_state_output <= idle_s when rst_n = '0' else next_state_output when rising_edge(clk);



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


	
	p_rb : process(clk)
	begin
		if rising_edge(clk) then
			rb_rd_valid <= '0';
			if rd_rd = '1' then
				if unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) then 
					-- error-codes
					rb_rd_data(3 downto 0) <= output_data_s(TimeStampLengh_g + CanDataLengh_g + 40 - 1 downto TimeStampLengh_g + CanDataLengh_g + 36);
					rb_rd_data(4) <= '1';
					-- frame-type
					rb_rd_data(6 downto 5) <= "00"; --Normal CAN-Frame
					-- buffer-usage
					rb_rd_data(9 downto 7) <= depth_s;
					rb_rd_data(11 downto 10) <= "00";
					-- timestamp
					rb_rd_data(31 downto 12) <= output_data_s(19 downto 0);
				elsif unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 4 then 
					-- timestamp
					rb_rd_data(27 downto 0) <= output_data_s(47 downto 20);
					-- can-dlc
					rb_rd_data(31 downto 28) <= output_data_s(TimeStampLengh_g + 36 - 1 downto TimeStampLengh_g + 32);
				elsif unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 8 then
					-- can_id
					rb_rd_data(28 downto 0) <= output_data_s(TimeStampLengh_g + 29 - 1 downto TimeStampLengh_g);
					--rtr eff err
					rb_rd_data(29) <= output_data_s(TimeStampLengh_g + 29);
					rb_rd_data(30) <= output_data_s(TimeStampLengh_g + 30);
					rb_rd_data(31) <= output_data_s(TimeStampLengh_g + 31);
				elsif unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 12 then 
					rb_rd_data <= input_fifo_data( (CanDataLengh_g / 2) + TimeStampLengh_g + 36 - 1 downto TimeStampLengh_g + 36);
				elsif unsigned(rb_addr) = unsigned(AddrSpaceStartPos_g) + 16 then
					rb_rd_data <= input_fifo_data( CanDataLengh_g + TimeStampLengh_g + 36 - 1 downto (CanDataLengh_g / 2) + TimeStampLengh_g + 36);
 				else
					rb_rd_data(31 downto 0) <= (others => '0');
				end if;

				rb_rd_valid <= '1';
			end if;
		end if;
	end process;
	
		
end;
