library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package can_core_intf is

    type can_core_out_intf_t is record
        buffer_usage            : std_logic_vector(4 downto 0);
        error_codes             : std_logic_vector(9 downto 0);
        frame_type              : std_logic_vector(1 downto 0);
        timestamp               : std_logic_vector(47 downto 0);
        crc                     : std_logic_vector(14 downto 0);
        crc_delimiter           : std_logic;
        can_dlc                 : std_logic_vector(3 downto 0);
        can_id                  : std_logic_vector(28 downto 0);
        rtr                     : std_logic;
        eff                     : std_logic;
        err                     : std_logic;
        data                    : std_logic_vector(63 downto 0);
    end record;

    type can_core_in_intf_t is record
        baudrate                : std_logic_vector(9 downto 0);

    end record;

    type can_core_comb_intf_t is record
        output                  : can_core_out_intf_t;
        input                   : can_core_in_intf_t;
    end record;

    subtype can_core_vector_t is std_logic_vector(223 downto 0);

    function to_can_core_vector(input_intf : can_core_out_intf_t) return can_core_vector_t;
    function to_can_core_intf(input_vec : can_core_vector_t) return can_core_out_intf_t;
    function get_empty_can_core_intf return can_core_out_intf_t;
    function get_can_core_out_intf(input_can_core : can_core_comb_intf_t) return can_core_out_intf_t;

end package can_core_intf;

package body can_core_intf is

    function to_can_core_vector(input_intf : can_core_out_intf_t) return can_core_vector_t is
        variable ret : can_core_vector_t;
    begin
        ret(4 downto 0)         := input_intf.buffer_usage;
        ret(31 downto 5)        := (others => '0');
        ret(41 downto 32)       := input_intf.error_codes;
        ret(43 downto 42)       := input_intf.frame_type;
        ret(91 downto 44)       := input_intf.timestamp;
        ret(106 downto 92)      := input_intf.crc;
        ret(107)                := input_intf.crc_delimiter;
        ret(123 downto 108)     := (others => '0');
        ret(127 downto 124)     := input_intf.can_dlc;
        ret(156 downto 128)     := input_intf.can_id;
        ret(157)                := input_intf.rtr;
        ret(158)                := input_intf.eff;
        ret(159)                := input_intf.err;
        ret(223 downto 160)     := input_intf.data;
        return ret;
    end function;



    function to_can_core_intf(input_vec : can_core_vector_t) return can_core_out_intf_t is
        variable ret : can_core_out_intf_t;
    begin
        ret.buffer_usage        := input_vec(4 downto 0);
        --ret(31 downto 5)  => not used
        ret.error_codes         := input_vec(41 downto 32);
        ret.frame_type          := input_vec(43 downto 42);
        ret.timestamp           := input_vec(91 downto 44);
        ret.crc                 := input_vec(106 downto 92);
        ret.crc_delimiter       := input_vec(107);
        --ret(123 downto 108) => not used
        ret.can_dlc             := input_vec(127 downto 124);
        ret.can_id              := input_vec(156 downto 128);
        ret.rtr                 := input_vec(157);
        ret.eff                 := input_vec(158);
        ret.err                 := input_vec(159);
        ret.data                := input_vec(223 downto 160);
        return ret;         
    end function;

    function get_empty_can_core_intf return can_core_out_intf_t is
        variable ret : can_core_out_intf_t;
    begin
        ret.buffer_usage    := (others => '0');
        ret.error_codes     := (others => '0');
        ret.frame_type      := (others => '0');
        ret.timestamp       := (others => '0');
        ret.crc             := (others => '0');
        ret.crc_delimiter   := '0';
        ret.can_dlc         := (others => '0');
        ret.can_id          := (others => '0');
        ret.rtr             := '0';
        ret.eff             := '0';
        ret.err             := '0';
        ret.data            := (others => '0');
        return ret;         
    end function;

    function get_can_core_out_intf(input_can_core : can_core_comb_intf_t) return can_core_out_intf_t is 
        variable ret : can_core_out_intf_t;
    begin
        ret.buffer_usage    := input_can_core.output.buffer_usage;
        ret.error_codes     := input_can_core.output.error_codes;
        ret.frame_type      := input_can_core.output.frame_type;
        ret.timestamp       := input_can_core.output.timestamp;
        ret.crc             := input_can_core.output.crc;
        ret.crc_delimiter   := input_can_core.output.crc_delimiter;
        ret.can_dlc         := input_can_core.output.can_dlc;
        ret.can_id          := input_can_core.output.can_id;
        ret.rtr             := input_can_core.output.rtr;
        ret.eff             := input_can_core.output.eff;
        ret.err             := input_can_core.output.err;
        ret.data            := input_can_core.output.data;
        return ret;
    end function;


end package body can_core_intf;
