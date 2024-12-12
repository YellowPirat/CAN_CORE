library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.can_core_intf.all;
use work.peripheral_intf.all;

entity axi_addr_cntr is
    generic(
        AddrSpaceStartPos_g	: std_logic_vector(20 downto 0) := "000000000000000000000"
    );
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        olo_axi_rb_addr_i       : in    std_logic_vector(20 downto 0);
        olo_axi_rb_wr_i         : in    std_logic;
        olo_axi_rb_byte_ena_i   : in    std_logic_vector(3 downto 0);
        olo_axi_rb_wr_data_i    : in    std_logic_vector(31 downto 0);
        olo_axi_rb_rd_i         : in    std_logic;
        olo_axi_rb_rd_data_o    : out   std_logic_vector(31 downto 0);
        olo_axi_rb_rd_valid_o   : out   std_logic;

        per_intf_i              : in    per_intf_t;
        can_frame_i             : in    can_core_out_intf_t;
        
        load_new_o              : out   std_logic;
        store_i                 : in    std_logic
    );

end entity axi_addr_cntr;

architecture rtl of axi_addr_cntr is

    signal load_new_s               : std_logic;
    signal can_frame_s              : can_core_vector_t;
    signal olo_axi_rb_rd_data_s     : std_logic_vector(31 downto 0);
    signal olo_axi_rb_rd_valid_s    : std_logic;
    signal per_intf_vector_s        : per_vector_t;

begin

    olo_axi_rb_rd_data_o    <= olo_axi_rb_rd_data_s;
    
    olo_axi_rb_rd_valid_o   <= olo_axi_rb_rd_valid_s;

    load_new_o              <= load_new_s;

    per_intf_vector_s       <= to_per_vector(per_intf_i);

    store_p : process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                can_frame_s <= (others => '0');
            else
                if store_i = '1' then
                    can_frame_s <= to_can_core_vector(can_frame_i);
                end if;
            end if;
        end if;
    end process;
                

	p_rb : process(clk)
	begin
		if rising_edge(clk) then
			olo_axi_rb_rd_valid_s   <= '0';
            load_new_s              <= '0';

			if olo_axi_rb_rd_i = '1' then
				if unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 0 then 
                    olo_axi_rb_rd_data_s <= get_word_from_per_intf_vector(per_intf_vector_s, 0);
				elsif unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 4 then 
                    olo_axi_rb_rd_data_s <= get_word_from_per_intf_vector(per_intf_vector_s, 1);
				elsif unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 8 then
					olo_axi_rb_rd_data_s <= get_word_from_per_intf_vector(per_intf_vector_s, 2);
                    
				elsif unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 12 then 
                    olo_axi_rb_rd_data_s <= get_word_from_can_core_vector(can_frame_s, 0);
				elsif unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 16 then
					olo_axi_rb_rd_data_s <= get_word_from_can_core_vector(can_frame_s, 1);
                elsif unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 20 then
                    olo_axi_rb_rd_data_s <= get_word_from_can_core_vector(can_frame_s, 2);
                elsif unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 24 then
                    olo_axi_rb_rd_data_s <= get_word_from_can_core_vector(can_frame_s, 3);
                elsif unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 28 then
                    olo_axi_rb_rd_data_s <= get_word_from_can_core_vector(can_frame_s, 4);
                elsif unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 32 then
                    olo_axi_rb_rd_data_s <= get_word_from_can_core_vector(can_frame_s, 5);
                elsif unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 36 then
                    olo_axi_rb_rd_data_s <= get_word_from_can_core_vector(can_frame_s, 6);
                elsif unsigned(olo_axi_rb_addr_i) = unsigned(AddrSpaceStartPos_g) + 40 then
                    olo_axi_rb_rd_data_s <= get_word_from_can_core_vector(can_frame_s, 7);
                    load_new_s <= '1';
 				else
                    olo_axi_rb_rd_data_s(31 downto 0) <= (others => '0');
				end if;

				olo_axi_rb_rd_valid_s <= '1';
			end if;
		end if;
	end process;





end rtl;