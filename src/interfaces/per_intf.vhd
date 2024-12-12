library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package peripheral_intf is
    type per_intf_t is record
        buffer_usage            : std_logic_vector(9 downto 0);
        peripheral_error        : std_logic_vector(15 downto 0);

        missed_frames           : unsigned(23 downto 0);
        missed_frames_overflow  : std_logic;
    end record;

    subtype per_vector_t    is std_logic_vector(95 downto 0);
    subtype per_word_t is std_logic_vector(31 downto 0);

    function to_per_vector(per_intf : per_intf_t) return per_vector_t;
    function to_per_intf(per_vector : per_vector_t) return per_intf_t;
    function get_word_from_per_intf_vector(per_intf_vector : per_vector_t; pos : integer) return per_word_t;
    function get_emtpy return per_intf_t;

end package peripheral_intf;

package body peripheral_intf is

    function to_per_vector(per_intf : per_intf_t) return per_vector_t is
        variable ret : per_vector_t;
    begin
        -- BUFFER USAGE
        ret(9 downto 0)         := per_intf.buffer_usage;
        ret(31 downto 10)       := (others => '0');
        -- PERIPHERAL ERROR
        ret(47 downto 32)       := per_intf.peripheral_error;
        ret(63 downto 48)       := (others => '0');
        -- MISSED FRAME
        ret(87 downto 64)       := std_logic_vector(per_intf.missed_frames);
        ret(88)                 := per_intf.missed_frames_overflow;
        ret(95 downto 89)       := (others => '0');

        return ret;
    end function;

    function to_per_intf(per_vector : per_vector_t) return per_intf_t is
        variable ret : per_intf_t;
    begin
        ret.buffer_usage                := per_vector(9 downto 0);
        ret.peripheral_error            := per_vector(47 downto 32);
        ret.missed_frames               := unsigned(per_vector(87 downto 64));
        ret.missed_frames_overflow      := per_vector(88);

        return ret;
    end function;

    function get_word_from_per_intf_vector(per_intf_vector : per_vector_t; pos : integer) return per_word_t is
        variable ret : per_word_t := (others => '0');
    begin 
        ret := per_intf_vector(31 + (32 * pos) downto (32 * pos));
        return ret;
    end function;

    function get_emtpy return per_intf_t is 
        variable ret : per_intf_t;
    begin
        ret.buffer_usage                := (others => '0');
        ret.peripheral_error            := (others => '0');
        ret.missed_frames               := to_unsigned(0, ret.missed_frames'length);
        ret.missed_frames_overflow      := '0';
        return ret;
    end function;

end package body peripheral_intf;
