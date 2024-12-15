library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use work.can_core_intf.all;
use work.peripheral_intf.all;

use work.olo_base_pkg_math.all;

entity frames is
    generic (
        count_g     :   positive := 10
    );
    port (
        pos_i       : in    std_logic_vector(log2ceil(count_g + 1) - 1 downto 0);
        frame_o     : out   can_core_out_intf_t
    );
end entity;

architecture rtl of frames is
    --FRAMES
    signal frame1 : can_core_out_intf_t;
    signal frame2 : can_core_out_intf_t;



    signal frame_s : can_core_out_intf_t;
begin 

    frame_o <= frame_s;


    frame1.error_codes      <= (others => '0');
    frame1.frame_type       <= (others => '0');
    frame1.timestamp        <= (others => '0');
    frame1.crc              <= "101010101010101";
    frame1.can_dlc          <= "1000";
    frame1.can_id           <= "10101001111010100111101010011";
    frame1.rtr              <= '0';
    frame1.eff              <= '1';
    frame1.err              <= '0';
    frame1.data             <= x"00000000deadaffe";

    frame2.error_codes      <= (others => '0');
    frame2.frame_type       <= (others => '0');
    frame2.timestamp        <= (others => '0');
    frame2.crc              <= "101011101010111";
    frame2.can_dlc          <= "1000";
    frame2.can_id           <= "10101111111010100111101010011";
    frame2.rtr              <= '0';
    frame2.eff              <= '1';
    frame2.err              <= '0';
    frame2.data             <= x"00000000deadbeef";


    p : process(pos_i)
    begin 
        if to_integer(unsigned(pos_i)) = 0 then
            frame_s <= frame1;
        elsif to_integer(unsigned(pos_i)) = 1 then
            frame_s <= frame2;
        end if;
    end process p;

end rtl;