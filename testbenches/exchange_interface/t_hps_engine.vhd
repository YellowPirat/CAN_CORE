library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

use work.can_core_intf.all;

entity t_hps_engine is
    generic (
        can_core_count_g    : natural := 1
    );
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
        can_frame_valid_o   : out   std_logic_vector(can_core_count_g - 1 downto 0)
    );
end entity;

architecture tbench of t_hps_engine is
    type can_frame_addresses_t is array (0 to 16) of std_logic_vector(20 downto 0);
    type core_settings_t is array(0 to 5) of std_logic_vector(31 downto 0);

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
        10 => "000000000000000101000",
        
        11 => "000000000000000101100",
        12 => "000000000000000110000",
        13 => "000000000000000110100",
        14 => "000000000000000111000",
        15 => "000000000000000111100",
        16 => "000000000000001000000"
    );

    -- 500 kBaud
    --signal core_setting : core_settings_t := (
    --    0 => X"00000001",
    --    1 => X"00000005",
    --    2 => X"00000007",
    --    3 => X"00000007",
    --    4 => X"00000004",
    --    5 => X"00000001"
    --);

    signal core_setting : core_settings_t := (
        0 => X"00000001",
        1 => X"00000002",
        2 => X"00000004",
        3 => X"00000003",
        4 => X"00000004",
        5 => X"00000000"
    );

    signal fifo_empty_s         : std_logic_vector(can_core_count_g - 1 downto 0) := (others => '0');
    signal start_sequence_s     : std_logic_vector(can_core_count_g - 1 downto 0) := (others => '1');

    signal can_frame_s          : can_core_vector_t;
    signal axi_frame_s          : axi_lite_vector_t;
    signal can_frame_valid_s    : std_logic_vector(can_core_count_g - 1 downto 0);

begin

  can_frame_o           <= can_frame_s;
  can_frame_valid_o     <= can_frame_valid_s;

  driver_engine : process
  begin
    wait for 2 us;

    for k in 0 to can_core_count_g - 1 loop
        for i in 11 to 16 loop
            axi_awaddr <= std_logic_vector(unsigned(can_frame_addresses(i)) + to_unsigned(k * 4096, 21));
            axi_awvalid <= '1';
            wait until clk = '1' and clk'event;
            wait until axi_awready = '1';
            wait until clk = '1' and clk'event;
            axi_awvalid <= '0';
        
            axi_wdata <= core_setting(i - 11);
            axi_wvalid <= '1';
            wait until clk = '1' and clk'event;

            axi_bready <= '1';
            wait until axi_bvalid = '1';
            wait until clk = '1' and clk'event;
            axi_bready <= '0';
            axi_wvalid <= '0';
        end loop;
    end loop;

    wait for 800 us;

  end process driver_engine;

  hps_engine: process
  begin

    wait for 100 us;

    for k in 0 to can_core_count_g - 1 loop

        if fifo_empty_s(k) = '1' or start_sequence_s(k) = '1' then
            can_frame_valid_s(k)   <= '0';
            wait for 200 us;
            start_sequence_s(k) <= '0';
        end if;

        for i in 0 to 10 loop
            axi_araddr <= std_logic_vector(unsigned(can_frame_addresses(i)) + to_unsigned(k * 4096, 21));
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
                fifo_empty_s(k)    <= '1';
            elsif i = 0 and unsigned(axi_rdata) > to_unsigned(0, axi_rdata'length) then
                fifo_empty_s(k)    <= '0';
            end if;

            if i = 10 then
                can_frame_valid_s(k)   <= '1';
            else
                can_frame_valid_s(k)   <= '0';
            end if;
            
        end loop;
    end loop;

    wait for 500 us;

  end process hps_engine;

end tbench ; -- tbench
