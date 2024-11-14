library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package peripheral_intf is
    type per_intf_t is record
        buffer_usage            : std_logic_vector(9 downto 0);
        peripheral_error        : std_logic_vector(4 downto 0);
        core_active             : std_logic;
        missed_frames           : std_logic_vector(14 downto 0);
        missed_frames_overflow  : std_logic;
    end record;

    subtype per_vector_t    is std_logic_vector(31 downto 0);

    function to_per_vector(per_intf : per_intf_t) return per_vector_t;
    function to_per_intf(per_vector : per_vector_t) return per_intf_t;

end package peripheral_intf;

package body peripheral_intf is

    function to_per_vector(per_intf : per_intf_t) return per_vector_t is
        variable ret : per_vector_t;
    begin
        ret(9 downto 0)         := per_intf.buffer_usage;
        ret(14 downto 10)       := per_intf.peripheral_error;
        ret(15)                 := per_intf.core_active;
        ret(30 downto 16)       := per_intf.missed_frames;
        ret(31)                 := per_intf.missed_frames_overflow;
        return ret;
    end function;

    function to_per_intf(per_vector : per_vector_t) return per_intf_t is
        variable ret : per_intf_t;
    begin
        ret.buffer_usage                := per_vector(9 downto 0);
        ret.peripheral_error            := per_vector(14 downto 10);
        ret.core_active                 := per_vector(15);
        ret.missed_frames               := per_vector(30 downto 16);
        ret.missed_frames_overflow      := per_vector(31);
        return ret;
    end function;

end package body peripheral_intf;
