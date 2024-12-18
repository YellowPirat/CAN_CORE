library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

use work.can_core_intf.all;

entity t_hps_engine is 
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        axi_awaddr          : out   std_logic_vector(20 downto 0);
        axi_awvalid         : out   std_logic := '0';
        axi_awready         : in    std_logic;
      
        axi_wdata           : out   std_logic_vector(31 downto 0) := (others => '0');
        axi_wvalid          : out   std_logic := '0';
        axi_wready          : in    std_logic;
      
        axi_bresp           : in    std_logic_vector(1 downto 0);
        axi_bvalid          : in    std_logic;
        axi_bready          : out   std_logic := '0';
      
        axi_araddr          : out   std_logic_vector(20 downto 0) := (others => '0');
        axi_arvalid         : out   std_logic := '0';
        axi_arready         : in    std_logic;
      
        axi_rdata           : in    std_logic_vector(31 downto 0);
        axi_rresp           : in    std_logic_vector(1 downto 0);
        axi_rvalid          : in    std_logic;
        axi_rready          : out   std_logic := '0';

        can_frame_o         : out   can_core_vector_t;
        can_frame_valid_o   : out   std_logic
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

    signal can_frame_s          : can_core_vector_t;
    signal axi_frame_s          : axi_lite_vector_t;
    signal can_frame_valid_s    : std_logic;

begin

  can_frame_o           <= can_frame_s;
  can_frame_valid_o     <= can_frame_valid_s;

  hps_engine: process
  begin

    if fifo_empty_s = true or start_sequence_s = true then
        can_frame_valid_s   <= '0';
        wait for 200 us;
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

        if i > 2 then
            can_frame_s <= set_axi_frame_into_can_vector(can_frame_s, i - 3, axi_rdata);
        end if;

        if i = 0 and unsigned(axi_rdata) = to_unsigned(0, axi_rdata'length) then
            fifo_empty_s    <= true;
        elsif i = 0 and unsigned(axi_rdata) > to_unsigned(0, axi_rdata'length) then
            fifo_empty_s    <= false;
        end if;

        if i = 10 then
            can_frame_valid_s   <= '1';
        else
            can_frame_valid_s   <= '0';
        end if;
        
    end loop;

  end process hps_engine;

end tbench ; -- tbench
