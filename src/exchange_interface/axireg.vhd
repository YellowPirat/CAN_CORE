
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
				case Rb_Addr is 
					when "000000000000000000000" =>
						rb_rd_data <= x"11111111";
					when "000000000000000000100" =>
						rb_rd_data <= x"22222222";
					when "000000000000000001000" =>
						rb_rd_data <= x"33333333";
					when others =>
						rb_rd_data <= (others => '0');
				end case;
				rb_rd_valid <= '1';
				
			end if;
	
			-- Reset and other logic omitted
		end if;
	end process;
	
		
end;
