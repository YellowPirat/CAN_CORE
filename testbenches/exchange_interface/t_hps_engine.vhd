library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity t_hps_engine is 
    port (
        clk            : in std_logic;
        rst_n          : in std_logic;

        axi_awaddr     : out std_logic_vector(20 downto 0);
        axi_awvalid    : out std_logic := '0';
        axi_awready    : in std_logic;
      
        axi_wdata      : out std_logic_vector(31 downto 0) := (others => '0');
        axi_wvalid     : out std_logic := '0';
        axi_wready     : in std_logic;
      
        axi_bresp      : in std_logic_vector(1 downto 0);
        axi_bvalid     : in std_logic;
        axi_bready     : out std_logic := '0';
      
        axi_araddr     : out std_logic_vector(20 downto 0) := (others => '0');
        axi_arvalid    : out std_logic := '0';
        axi_arready    : in std_logic;
      
        axi_rdata      : in std_logic_vector(31 downto 0);
        axi_rresp      : in std_logic_vector(1 downto 0);
        axi_rvalid     : in std_logic;
        axi_rready     : out std_logic := '0'
    );
end entity;

architecture tbench of t_hps_engine is
    type can_frame_addresses_t is array (0 to 4) of std_logic_vector(20 downto 0);

    signal can_frame_addresses : can_frame_addresses_t := (
        0 => "000000000000000000000", 
        1 => "000000000000000000100",
        2 => "000000000000000001000",
        3 => "000000000000000001100",
        4 => "000000000000000010000"
    );
begin


  hps_engine: process
  begin
    wait for 50 ns;

    -- Write operation
    
    --axi_awaddr <= s1_base_addr(20 downto 0);  -- Address
    --axi_awvalid <= '1';       -- Valid write address
    --wait until clk = '1' and clk'event;
    --wait until axi_awready = '1';  -- Wait for ready signal
    --axi_awvalid <= '0';       -- Deassert valid

    --axi_wdata <= x"DEADBEEF"; -- Data to write
    --axi_wvalid <= '1';        -- Valid write data
    --wait until clk = '1' and clk'event;
    --wait until axi_wready = '1';   -- Wait for ready signal


    --axi_bready <= '1';        -- Ready for response
    --wait until axi_bvalid = '1';
    --wait until clk = '1' and clk'event;
    --axi_bready <= '0';        -- Deassert ready
    --axi_wvalid <= '0';        -- Deassert valid
    

    -- Read operation
    for k in 0 to 19 loop
        for i in 0 to 4 loop
            axi_araddr <= can_frame_addresses(i);
            axi_arvalid <= '1';       -- Valid read address
            wait until clk = '1' and clk'event;
            wait until axi_arready = '1';  -- Wait for ready signal
            axi_arvalid <= '0';       -- Deassert valid

            axi_rready <= '1';        -- Ready to accept read data
            wait until axi_rvalid = '1';
            wait until clk = '1' and clk'event;
            axi_rready <= '0';        -- Deassert ready

            --wait for 50 ns;
        end loop;
    end loop;

    wait;
  end process hps_engine;

end tbench ; -- tbench
