library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity t_exchange_interface is
end entity;

architecture tbench of t_exchange_interface is

  signal clk, rst_n : std_logic := '0';
  signal simstop : boolean := false;

  signal axi_awaddr_s     : std_logic_vector(20 downto 0);
  signal axi_awvalid_s    : std_logic := '0';
  signal axi_awready_s    : std_logic;

  signal axi_wdata_s      : std_logic_vector(31 downto 0) := (others => '0');
  signal axi_wvalid_s     : std_logic := '0';
  signal axi_wready_s     : std_logic;

  signal axi_bresp_s      : std_logic_vector(1 downto 0);
  signal axi_bvalid_s     : std_logic;
  signal axi_bready_s     : std_logic := '0';

  signal axi_araddr_s     : std_logic_vector(20 downto 0) := (others => '0');
  signal axi_arvalid_s    : std_logic := '0';
  signal axi_arready_s    : std_logic;

  signal axi_rdata_s      : std_logic_vector(31 downto 0);
  signal axi_rresp_s      : std_logic_vector(1 downto 0);
  signal axi_rvalid_s     : std_logic;
  signal axi_rready_s     : std_logic := '0';



begin
  
  -- Clock generation
  clk_p : process
  begin
    clk <= '0';
    wait for 10 ns; 
    clk <= '1'; 
    wait for 10 ns;
    if simstop then
      wait;
    end if;
  end process clk_p;

  -- Reset generation
  rst_p : process
  begin
    rst_n <= '0';
    wait for 20 ns;
    rst_n <= '1';
    wait;
  end process rst_p;

  simstop_p : process
  begin
    wait for 1 us;
    simstop <= true;
    wait;
  end process simstop_p;


  hps_engine_i0 : entity work.t_hps_engine
    port map(
      clk                 => clk,
      rst_n               => rst_n,

      axi_awaddr        => axi_awaddr_s,
      axi_awvalid       => axi_awvalid_s,
      axi_awready       => axi_awready_s,

      axi_wdata         => axi_wdata_s,
      axi_wvalid        => axi_wvalid_s,
      axi_wready        => axi_wready_s,

      axi_bresp         => axi_bresp_s,
      axi_bvalid        => axi_bvalid_s,
      axi_bready        => axi_bready_s,

      axi_araddr        => axi_araddr_s,
      axi_arvalid       => axi_arvalid_s,
      axi_arready       => axi_arready_s,

      axi_rdata         => axi_rdata_s,
      axi_rresp         => axi_rresp_s,
      axi_rvalid        => axi_rvalid_s,
      axi_rready        => axi_rready_s          
    );


  -- DUT instantiation
  exchange_interface_i0 : entity work.de1_exchange_interface
    port map (
        clk                 => clk,
        rst_n               => rst_n,

        axi_awaddr        => axi_awaddr_s,
        axi_awvalid       => axi_awvalid_s,
        axi_awready       => axi_awready_s,

        axi_wdata         => axi_wdata_s,
        axi_wvalid        => axi_wvalid_s,
        axi_wready        => axi_wready_s,

        axi_bresp         => axi_bresp_s,
        axi_bvalid        => axi_bvalid_s,
        axi_bready        => axi_bready_s,

        axi_araddr        => axi_araddr_s,
        axi_arvalid       => axi_arvalid_s,
        axi_arready       => axi_arready_s,

        axi_rdata         => axi_rdata_s,
        axi_rresp         => axi_rresp_s,
        axi_rvalid        => axi_rvalid_s,
        axi_rready        => axi_rready_s
    );



end architecture;
