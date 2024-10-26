library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package can_core_intf is

    type can_core_intf_t is record
        error_codes             : std_logic_vector(4 downto 0);
        frame_type              : std_logic_vector(1 downto 0);
        buffer_usage            : std_logic_vector(4 downto 0);
        timestamp               : std_logic_vector(47 downto 0);
        can_dlc                 : std_logic_vector(3 downto 0);
        can_id                  : std_logic_vector(28 downto 0);
        rtr                     : std_logic;
        eff                     : std_logic;
        err                     : std_logic;
        data                    : std_logic_vector(63 downto 0);
    end record;

    subtype can_core_vector_t is std_logic_vector(159 downto 0);

    function to_can_core_vector(input_intf : can_core_intf_t) return can_core_vector_t;
    function to_can_core_intf(input_vec : can_core_vector_t) return can_core_intf_t;
    function get_empty_can_core_intf return can_core_intf_t;
    

end package can_core_intf;

package body can_core_intf is

    function to_can_core_vector(input_intf : can_core_intf_t) return can_core_vector_t is
        variable ret : can_core_vector_t;
    begin
        ret(4 downto 0)     := input_intf.error_codes;
        ret(6 downto 5)     := input_intf.frame_type;
        ret(11 downto 7)    := input_intf.buffer_usage;
        ret(59 downto 12)   := input_intf.timestamp;
        ret(63 downto 60)   := input_intf.can_dlc;
        ret(92 downto 64)   := input_intf.can_id;
        ret(93)             := input_intf.rtr;
        ret(94)             := input_intf.eff;
        ret(95)             := input_intf.err;
        ret(159 downto 96)  := input_intf.data;
        return ret;
    end function;

    function to_can_core_intf(input_vec : can_core_vector_t) return can_core_intf_t is
        variable ret : can_core_intf_t;
    begin
        ret.error_codes     := input_vec(4 downto 0);
        ret.frame_type      := input_vec(6 downto 5);
        ret.buffer_usage    := input_vec(11 downto 7);
        ret.timestamp       := input_vec(59 downto 12);
        ret.can_dlc         := input_vec(63 downto 60);
        ret.can_id          := input_vec(92 downto 64);
        ret.rtr             := input_vec(93);
        ret.eff             := input_vec(94);
        ret.err             := input_vec(95);
        ret.data            := input_vec(159 downto 96);
        return ret;         
    end function;

    function get_empty_can_core_intf return can_core_intf_t is
        variable ret : can_core_intf_t;
    begin
        ret.error_codes     := (others => '0');
        ret.frame_type      := (others => '0');
        ret.buffer_usage    := (others => '0');
        ret.timestamp       := (others => '0');
        ret.can_dlc         := (others => '0');
        ret.can_id          := (others => '0');
        ret.rtr             := '0';
        ret.eff             := '0';
        ret.err             := '0';
        ret.data            := (others => '0');
        return ret;         
    end function;



end package body can_core_intf;
