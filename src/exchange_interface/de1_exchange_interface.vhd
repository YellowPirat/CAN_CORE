library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity de1_exchange_interface is
    port (
        -- Global clock and reset
        clk           : in std_logic;
        rst_n         : in std_logic;
        
        -- AXI slave interface (from master)
        axi_awaddr  : in  std_logic_vector(20 downto 0);
        axi_awvalid : in  std_logic;
        axi_awready : out std_logic;
    
        axi_wdata   : in  std_logic_vector(31 downto 0);
        axi_wvalid  : in  std_logic;
        axi_wready  : out std_logic;
    
        axi_bresp   : out std_logic_vector(1 downto 0);
        axi_bvalid  : out std_logic;
        axi_bready  : in  std_logic;
    
        axi_araddr  : in  std_logic_vector(20 downto 0);
        axi_arvalid : in  std_logic;
        axi_arready : out std_logic;
    
        axi_rdata   : out std_logic_vector(31 downto 0);
        axi_rresp   : out std_logic_vector(1 downto 0);
        axi_rvalid  : out std_logic;
        axi_rready  : in  std_logic;

        -- SHIT SIGNALS

        axi_awid    : in  std_logic_vector(11 downto 0) := (others => '0');
        axi_bid     : out std_logic_vector(11 downto 0) := (others => '0');
        axi_rid     : out std_logic_vector(11 downto 0) := (others => '0');
        axi_arid    : in  std_logic_vector(11 downto 0) := (others => '0');
        axi_rlast   : out std_logic := '0'
    );
end de1_exchange_interface;

architecture rtl of de1_exchange_interface is

    -- S1 INTERCONNECT OUT
    signal m1_axi_awaddr    : std_logic_vector(20 downto 0);
    signal m1_axi_awvalid   : std_logic;
    signal m1_axi_awready   : std_logic;
    
    signal m1_axi_wdata		: std_logic_vector(31 downto 0);
    signal m1_axi_wvalid		: std_logic;
    signal m1_axi_wready     : std_logic;
    
    signal m1_axi_bresp      : std_logic_vector(1 downto 0);
    signal m1_axi_bvalid     : std_logic;
    signal m1_axi_bready     : std_logic;
    
    signal m1_axi_araddr		: std_logic_vector(20 downto 0);
    signal m1_axi_arvalid    : std_logic;
    signal m1_axi_arready    : std_logic;
    
    signal m1_axi_rdata      : std_logic_vector(31 downto 0);
    signal m1_axi_rresp		: std_logic_vector(1 downto 0);
    signal m1_axi_rvalid     : std_logic;
    signal m1_axi_rready     : std_logic;
    
    -- S2 INTERCONNECT OUT
    signal m2_axi_awaddr		: std_logic_vector(20 downto 0);
    signal m2_axi_awvalid    : std_logic;
    signal m2_axi_awready    : std_logic;
    
    signal m2_axi_wdata		: std_logic_vector(31 downto 0);
    signal m2_axi_wvalid		: std_logic;
    signal m2_axi_wready     : std_logic;
    
    signal m2_axi_bresp      : std_logic_vector(1 downto 0);
    signal m2_axi_bvalid     : std_logic;
    signal m2_axi_bready     : std_logic;
    
    signal m2_axi_araddr		: std_logic_vector(20 downto 0);
    signal m2_axi_arvalid    : std_logic;
    signal m2_axi_arready    : std_logic;
    
    signal m2_axi_rdata      : std_logic_vector(31 downto 0);
    signal m2_axi_rresp		: std_logic_vector(1 downto 0);
    signal m2_axi_rvalid     : std_logic;
    signal m2_axi_rready     : std_logic;

begin

    intercon : entity work.axi_interconnect
    generic map(
        C_S_AXI_DATA_WIDTH                      => 32,
        C_S_AXI_ADDR_WIDTH                      => 21
    )
	port map(
        -- MASTER INTERFACE
        S_AXI_ACLK								=> clk,
        S_AXI_ARESETN							=> rst_n,
        
        S_AXI_AWADDR							=> axi_awaddr,
        S_AXI_AWVALID							=> axi_awvalid,
        S_AXI_AWREADY							=> axi_awready,
        
        S_AXI_WDATA								=> axi_wdata,
        S_AXI_WVALID							=> axi_wvalid,
        S_AXI_WREADY							=> axi_wready,
        
        S_AXI_BRESP								=> axi_bresp,
        S_AXI_BVALID							=> axi_bvalid,
        S_AXI_BREADY							=> axi_bready,
        
        S_AXI_ARADDR							=> axi_araddr,
        S_AXI_ARVALID							=> axi_arvalid,
        S_AXI_ARREADY							=> axi_arready,
        
        S_AXI_RDATA								=> axi_rdata,
        S_AXI_RRESP								=> axi_rresp,
        S_AXI_RVALID							=> axi_rvalid,
        S_AXI_RREADY							=> axi_rready,

        -- Shit
        S_AXI_AWID                              => axi_awid,
        S_AXI_BID                               => axi_bid,
        S_AXI_RID                               => axi_rid,
        S_AXI_ARID                              => axi_arid,
        S_AXI_RLAST                             => axi_rlast,
		
        -- SLAVE INTERFACE 1
        M1_AXI_AWADDR							=> m1_axi_awaddr,
        M1_AXI_AWVALID							=> m1_axi_awvalid,
        M1_AXI_AWREADY							=> m1_axi_awready,

        M1_AXI_WDATA 							=> m1_axi_wdata,
        M1_AXI_WVALID							=> m1_axi_wvalid,
        M1_AXI_WREADY							=> m1_axi_wready,

        M1_AXI_BRESP							=> m1_axi_bresp,
        M1_AXI_BVALID							=> m1_axi_bvalid,
        M1_AXI_BREADY							=> m1_axi_bready,

        M1_AXI_ARADDR							=> m1_axi_araddr,
        M1_AXI_ARVALID 							=> m1_axi_arvalid,
        M1_AXI_ARREADY 							=> m1_axi_arready,

        M1_AXI_RDATA  							=> m1_axi_rdata,
        M1_AXI_RRESP  							=> m1_axi_rresp,
        M1_AXI_RVALID 							=> m1_axi_rvalid,
        M1_AXI_RREADY 							=> m1_axi_rready,
	 
		-- SLAVE INTERFACE 2
        M2_AXI_AWADDR							=> m2_axi_awaddr,
        M2_AXI_AWVALID							=> m2_axi_awvalid,
        M2_AXI_AWREADY							=> m2_axi_awready,

        M2_AXI_WDATA 							=> m2_axi_wdata,
        M2_AXI_WVALID							=> m2_axi_wvalid,
        M2_AXI_WREADY							=> m2_axi_wready,

        M2_AXI_BRESP							=> m2_axi_bresp,
        M2_AXI_BVALID							=> m2_axi_bvalid,
        M2_AXI_BREADY							=> m2_axi_bready,

        M2_AXI_ARADDR							=> m2_axi_araddr,
        M2_AXI_ARVALID 							=> m2_axi_arvalid,
        M2_AXI_ARREADY 							=> m2_axi_arready,
        
        M2_AXI_RDATA  							=> m2_axi_rdata,
        M2_AXI_RRESP  							=> m2_axi_rresp,
        M2_AXI_RVALID 							=> m2_axi_rvalid,
        M2_AXI_RREADY 							=> m2_axi_rready
	);

    axireg_inst_i0: entity work.axireg
    port map(
       clk => clk,
       rst_n => rst_n,
 
       axi_slave_awaddr    => m1_axi_awaddr,
       axi_slave_awvalid   => m1_axi_awvalid,
       axi_slave_awready   => m1_axi_awready,
   
       axi_slave_wdata     => m1_axi_wdata,
       axi_slave_wvalid    => m1_axi_wvalid,
       axi_slave_wready    => m1_axi_wready,
   
       axi_slave_bresp     => m1_axi_bresp,
       axi_slave_bvalid    => m1_axi_bvalid,
       axi_slave_bready    => m1_axi_bready,
   
       axi_slave_araddr    => m1_axi_araddr,
       axi_slave_arvalid   => m1_axi_arvalid,
       axi_slave_arready   => m1_axi_arready,
   
       axi_slave_rdata     => m1_axi_rdata,
       axi_slave_rvalid    => m1_axi_rvalid,
       axi_slave_rready    => m1_axi_rready,
       axi_slave_rresp     => m1_axi_rresp
   );

end rtl;

