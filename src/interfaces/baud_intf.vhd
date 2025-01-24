library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package baud_intf is 
    type baud_intf_t is record 
        sync_seg                : unsigned(31 downto 0);
        prob_seg                : unsigned(31 downto 0);
        phase_seg1              : unsigned(31 downto 0);
        phase_seg2              : unsigned(31 downto 0);
        prescaler               : unsigned(31 downto 0);
    end record;

    type baud_intf_vec_t is array (natural range <>) of baud_intf_t;

end package baud_intf;