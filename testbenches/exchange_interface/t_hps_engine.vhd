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
    type can_frame_addresses_t is array (0 to 10) of std_logic_vector(20 downto 0);

    signal can_frame_addresses : can_frame_addresses_t := (
        0  => "000000000000000000000", 
        1  => "000000000000000000100",
        2  => "000000000000000001000",
        3  => "000000000000000001100",
        4  => "000000000000000010000",
        5  => "000000000000000010100",
        6  => "000000000000000011000",
        7  => "000000000000000011100",
        8  => "000000000000000100000",
        9  => "000000000000000100100",
        10 => "000000000000000101000"
    );

    signal fifo_empty_s         : boolean := false;
    signal start_sequence_s     : boolean := true;

begin



  hps_engine: process
  begin

    if fifo_empty_s = true or start_sequence_s = true then
        wait for 700 us;
        start_sequence_s <= false;
    end if;

    for i in 0 to 10 loop
        axi_araddr <= can_frame_addresses(i);
        axi_arvalid <= '1';
        wait until clk = '1' and clk'event;
        wait until axi_arready = '1';
        axi_arvalid <= '0';

        axi_rready <= '1';
        wait until axi_rvalid = '1';
        wait until clk = '1' and clk'event;
        axi_rready <= '0';

        if i = 0 and unsigned(axi_rdata) = to_unsigned(0, axi_rdata'length) then
            fifo_empty_s    <= true;
        end if;
        
    end loop;

  end process hps_engine;

end tbench ; -- tbench
