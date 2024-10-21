
-- #############################################################################
-- AXI3 simple slave peripheral register
-- #############################################################################

-- Missing and ToDO
--  * does not handle bursts
--  * does not handle unaligned writes/reads
--  * does not handle non 32-Bit writes
--  * Statemachines are not Medwedew, therefore AXI signals not from registers
--  * Does not check address. This will accept all transactions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library olo;

entity axireg is
port(
	clk               : in   std_logic;
	rst_n             : in   std_logic;

	-- Used
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
	axi_slave_rresp   : out  std_logic_vector(1 downto 0)
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

	-- Fifo Signals
	signal input_data_s      : std_logic_vector(127 downto 0);
	signal input_valid_s     : std_logic;
	signal input_ready_s     : std_logic;

	signal output_data_s     : std_logic_vector(127 downto 0);
	signal output_valid_s    : std_logic;
	signal output_ready_s    : std_logic;

	signal fifo_empty_s      : std_logic;
	signal fifo_full_s       : std_logic;

	-- Default Input Data
	signal q, d				: unsigned(127 downto 0);
	signal en_s             : std_logic;
	type state_input_t is (idle_s, write_s, wait_s);
	signal current_state_input, next_state_input  : state_input_t;
	type state_output_t is (idle_s, read_s, next_s);
	signal current_state_output, next_state_output : state_output_t;
	signal output_buffer_s : std_logic_vector(31 downto 0);
	signal load_new_val_s  : std_logic;

	-- Reset
	signal rst_h : std_logic;

begin



	axi_slave_rresp <= "00";
	rst_h <= not rst_n;

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
		
		Rb_Addr					=>	rb_addr,
		Rb_Wr						=>	rb_wr,
		Rb_ByteEna				=> rb_byte_ena,
		Rb_WrData				=>	rb_wr_data,
		Rb_Rd						=> rd_rd,
		Rb_RdData				=>	rb_rd_data,
		Rb_RdValid				=> rb_rd_valid
	);

	q <= to_unsigned(1000, q'length) when rst_n = '0' else d when rising_edge(clk);
	d <= q when en_s = '0' else q + to_unsigned(100000000, q'length);

	i_p : process(current_state_input, fifo_full_s, input_ready_s)
	begin 
		next_state_input <= current_state_input;
		en_s <= '0';
		input_valid_s <= '0';
		input_data_s <= std_logic_vector(q);

		case current_state_input is
			when idle_s =>
				if fifo_full_s = '0' then
					next_state_input <= write_s;
				end if;

			when write_s =>
				if input_ready_s = '1' then
					next_state_input <= wait_s;
				end if;

				input_valid_s <= '1';

			when wait_s =>
				if input_ready_s = '1' then
					next_state_input <= write_s;
				else
					next_state_input <= idle_s;
				end if;

				en_s <= '1';
			
			when others => 
				next_state_input <= idle_s;
				


		end case;
	end process i_p;

	current_state_input <= idle_s when rst_n = '0' else next_state_input when rising_edge(clk);

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
				if rd_rd = '1' and rb_addr = "000000000000000001100" then
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
			Width_g		=> 128,
			Depth_g		=> 6
		)

		port map(
			Clk 		=> clk,
			Rst			=> rst_h,

			In_Data		=> input_data_s,
			In_Valid	=> input_valid_s,
			In_Ready    => input_ready_s,

			Out_Data    => output_data_s,
			Out_Valid	=> output_valid_s,
			Out_Ready	=> output_ready_s,

			Empty       => fifo_empty_s,
			Full		=> fifo_full_s
		);


	
	p_rb : process(clk)
	begin
		if rising_edge(clk) then
		
			-- *** Write ***
			--if rb_wr = '1' then
			--	reg(0) <= rb_wr_data;
			--end if;
			
			-- *** Read ***
			rb_rd_valid <= '0'; -- Defuault value   
			if rd_rd = '1' then
				case rb_addr is 
					when "000000000000000000000" =>
						rb_rd_data(7 downto 0) <= output_data_s(7 downto 0);
						rb_rd_data(31 downto 8) <= (others => '0');
					when "000000000000000000100" =>
						rb_rd_data(7 downto 0) <=  output_data_s(15 downto 8);
						rb_rd_data(31 downto 8) <= (others => '0');
					when "000000000000000001000" =>
						rb_rd_data(7 downto 0) <= output_data_s(23 downto 16);
						rb_rd_data(31 downto 8) <= (others => '0');
					when "000000000000000001100" =>
						rb_rd_data(7 downto 0) <= output_data_s(31 downto 24);
						rb_rd_data(31 downto 8) <= (others => '0');
					when others =>
						rb_rd_data <= (others => '0');
				end case;
				rb_rd_valid <= '1';
				
			end if;
	
			-- Reset and other logic omitted
		end if;
	end process;
	
		
end;
