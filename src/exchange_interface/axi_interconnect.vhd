library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity axi_interconnect is
  generic (
    C_S_AXI_DATA_WIDTH : integer := 32;
    C_S_AXI_ADDR_WIDTH : integer := 32
  );
  port (
    -- Global clock and reset
    S_AXI_ACLK    : in std_logic;
    S_AXI_ARESETN : in std_logic;
    
    -- AXI slave interface (from master)
    S_AXI_AWADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID : in std_logic;
    S_AXI_AWREADY : out std_logic;

    S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WVALID  : in std_logic;
    S_AXI_WREADY  : out std_logic;

    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in std_logic;

    S_AXI_ARADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID : in std_logic;
    S_AXI_ARREADY : out std_logic;

    S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in std_logic;
    
    -- AXI master interfaces (to slaves)
    -- Slave 1
    M1_AXI_AWADDR  : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    M1_AXI_AWVALID : out std_logic;
    M1_AXI_AWREADY : in std_logic;

    M1_AXI_WDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    M1_AXI_WVALID  : out std_logic;
    M1_AXI_WREADY  : in std_logic;

    M1_AXI_BRESP   : in std_logic_vector(1 downto 0);
    M1_AXI_BVALID  : in std_logic;
    M1_AXI_BREADY  : out std_logic;

    M1_AXI_ARADDR  : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    M1_AXI_ARVALID : out std_logic;
    M1_AXI_ARREADY : in std_logic;

    M1_AXI_RDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    M1_AXI_RRESP   : in std_logic_vector(1 downto 0);
    M1_AXI_RVALID  : in std_logic;
    M1_AXI_RREADY  : out std_logic;
    
    -- Slave 2  
    M2_AXI_AWADDR  : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    M2_AXI_AWVALID : out std_logic;
    M2_AXI_AWREADY : in std_logic;

    M2_AXI_WDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    M2_AXI_WVALID  : out std_logic;
    M2_AXI_WREADY  : in std_logic;

    M2_AXI_BRESP   : in std_logic_vector(1 downto 0);
    M2_AXI_BVALID  : in std_logic;
    M2_AXI_BREADY  : out std_logic;

    M2_AXI_ARADDR  : out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    M2_AXI_ARVALID : out std_logic;
    M2_AXI_ARREADY : in std_logic;

    M2_AXI_RDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    M2_AXI_RRESP   : in std_logic_vector(1 downto 0);
    M2_AXI_RVALID  : in std_logic;
    M2_AXI_RREADY  : out std_logic;

    -- Shit Signals
  	S_AXI_AWID    : in   std_logic_vector(11 downto 0);
	  S_AXI_BID     : out  std_logic_vector(11 downto 0);
	  S_AXI_RID     : out  std_logic_vector(11 downto 0);
  	S_AXI_ARID    : in   std_logic_vector(11 downto 0);
	  S_AXI_RLAST   : out  std_logic

  );
end axi_interconnect;

architecture rtl of axi_interconnect is

  -- Address ranges for slaves
  constant SLAVE1_BASE_ADDR : std_logic_vector(31 downto 0) := x"ff200000";
  constant SLAVE1_HIGH_ADDR : std_logic_vector(31 downto 0) := x"ff200020";
  constant SLAVE2_BASE_ADDR : std_logic_vector(31 downto 0) := x"ff200021";
  constant SLAVE2_HIGH_ADDR : std_logic_vector(31 downto 0) := x"ff200040";

  constant SLAVE1_BASE_ADDR_a : std_logic_vector(20 downto 0) := SLAVE1_BASE_ADDR(20 downto 0);
  constant SLAVE1_HIGH_ADDR_a : std_logic_vector(20 downto 0) := SLAVE1_HIGH_ADDR(20 downto 0);
  constant SLAVE2_BASE_ADDR_a : std_logic_vector(20 downto 0) := SLAVE2_BASE_ADDR(20 downto 0);
  constant SLAVE2_HIGH_ADDR_a : std_logic_vector(20 downto 0) := SLAVE2_HIGH_ADDR(20 downto 0);

  -- Signals for address decoding
  signal slave_sel : integer range 0 to 2 := 0;

begin
  -- Shit
  S_AXI_RLAST <= '1';
  S_AXI_BID <= S_AXI_AWID;
  S_AXI_RID <= S_AXI_ARID;


  -- Address decoding process
  address_decode: process(S_AXI_AWADDR, S_AXI_ARADDR)
  begin
    if (unsigned(S_AXI_AWADDR) >= unsigned(SLAVE1_BASE_ADDR_a) and 
        unsigned(S_AXI_AWADDR) <= unsigned(SLAVE1_HIGH_ADDR_a)) or
       (unsigned(S_AXI_ARADDR) >= unsigned(SLAVE1_BASE_ADDR_a) and
        unsigned(S_AXI_ARADDR) <= unsigned(SLAVE1_HIGH_ADDR_a)) then
      slave_sel <= 1;
    elsif (unsigned(S_AXI_AWADDR) >= unsigned(SLAVE2_BASE_ADDR_a) and
           unsigned(S_AXI_AWADDR) <= unsigned(SLAVE2_HIGH_ADDR_a)) or
          (unsigned(S_AXI_ARADDR) >= unsigned(SLAVE2_BASE_ADDR_a) and
           unsigned(S_AXI_ARADDR) <= unsigned(SLAVE2_HIGH_ADDR_a)) then
      slave_sel <= 2;
    else
      slave_sel <= 0; -- No slave selected
    end if;
  end process;

  -- Multiplexing logic for write address channel
  M1_AXI_AWADDR  <= S_AXI_AWADDR when slave_sel = 1 else (others => '0');
  M1_AXI_AWVALID <= S_AXI_AWVALID when slave_sel = 1 else '0';
  M2_AXI_AWADDR  <= S_AXI_AWADDR when slave_sel = 2 else (others => '0');
  M2_AXI_AWVALID <= S_AXI_AWVALID when slave_sel = 2 else '0';

  -- Multiplexing logic for write data channel
  M1_AXI_WDATA   <= S_AXI_WDATA when slave_sel = 1 else (others => '0');
  M1_AXI_WVALID  <= S_AXI_WVALID when slave_sel = 1 else '0';
  M2_AXI_WDATA   <= S_AXI_WDATA when slave_sel = 2 else (others => '0');
  M2_AXI_WVALID  <= S_AXI_WVALID when slave_sel = 2 else '0';

  -- Multiplexing logic for read address channel
  M1_AXI_ARADDR  <= S_AXI_ARADDR when slave_sel = 1 else (others => '0');
  M1_AXI_ARVALID <= S_AXI_ARVALID when slave_sel = 1 else '0';
  M2_AXI_ARADDR  <= S_AXI_ARADDR when slave_sel = 2 else (others => '0');
  M2_AXI_ARVALID <= S_AXI_ARVALID when slave_sel = 2 else '0';

  -- Multiplexing logic for response channels
  S_AXI_AWREADY <= M1_AXI_AWREADY when slave_sel = 1 else
                   M2_AXI_AWREADY when slave_sel = 2 else
                   '0';
  S_AXI_WREADY  <= M1_AXI_WREADY when slave_sel = 1 else
                   M2_AXI_WREADY when slave_sel = 2 else
                   '0';
  S_AXI_BRESP   <= M1_AXI_BRESP when slave_sel = 1 else
                   M2_AXI_BRESP when slave_sel = 2 else
                   "00";
  S_AXI_BVALID  <= M1_AXI_BVALID when slave_sel = 1 else
                   M2_AXI_BVALID when slave_sel = 2 else
                   '0';
  S_AXI_ARREADY <= M1_AXI_ARREADY when slave_sel = 1 else
                   M2_AXI_ARREADY when slave_sel = 2 else
                   '0';
  S_AXI_RDATA   <= M1_AXI_RDATA when slave_sel = 1 else
                   M2_AXI_RDATA when slave_sel = 2 else
                   (others => '0');
  S_AXI_RRESP   <= M1_AXI_RRESP when slave_sel = 1 else
                   M2_AXI_RRESP when slave_sel = 2 else
                   "00";
  S_AXI_RVALID  <= M1_AXI_RVALID when slave_sel = 1 else
                   M2_AXI_RVALID when slave_sel = 2 else
                   '0';

  -- Connect BREADY and RREADY signals
  M1_AXI_BREADY <= S_AXI_BREADY;
  M2_AXI_BREADY <= S_AXI_BREADY;
  M1_AXI_RREADY <= S_AXI_RREADY;
  M2_AXI_RREADY <= S_AXI_RREADY;

end rtl;
