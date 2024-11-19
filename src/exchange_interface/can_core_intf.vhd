library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package can_core_intf is

    type can_core_out_intf_t is record
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

    subtype can_core_vector_t is std_logic_vector(191 downto 0);
    subtype axi_lite_vector_t is std_logic_vector(31 downto 0);

    function to_can_core_vector(input_intf : can_core_out_intf_t) return can_core_vector_t;
    function to_can_core_intf(input_vec : can_core_vector_t) return can_core_out_intf_t;
    function get_empty_can_core_intf return can_core_out_intf_t;
    function get_can_core_out_intf(input_can_core : can_core_comb_intf_t) return can_core_out_intf_t;
    function get_word_from_can_core_vector(can_core_vector : can_core_vector_t; pos : integer) return axi_lite_vector_t;

end package can_core_intf;

package body can_core_intf is

    function to_can_core_vector(input_intf : can_core_out_intf_t) return can_core_vector_t is
        variable ret : can_core_vector_t;
    begin

        ret(9 downto 0)         := input_intf.error_codes;
        ret(11 downto 10)       := input_intf.frame_type;
        ret(59 downto 12)       := input_intf.timestamp;
        ret(63 downto 60)       := input_intf.can_dlc;
        ret(92 downto 64)       := input_intf.can_id;
        ret(93)                 := input_intf.rtr;
        ret(94)                 := input_intf.eff;
        ret(95)                 := input_intf.err;
        ret(110 downto 96)      := input_intf.crc;
        ret(111)                := input_intf.crc_delimiter;
        ret(127 downto 112)     := (others => '0');
        ret(191 downto 128)     := input_intf.data;
        return ret;
    end function;



    function to_can_core_intf(input_vec : can_core_vector_t) return can_core_out_intf_t is
        variable ret : can_core_out_intf_t;
    begin

        ret.error_codes         := input_vec(9 downto 0);
        ret.frame_type          := input_vec(11 downto 10);
        ret.timestamp           := input_vec(59 downto 12);
        ret.can_dlc             := input_vec(63 downto 60);
        ret.can_id              := input_vec(92 downto 64);
        ret.rtr                 := input_vec(93);
        ret.eff                 := input_vec(94);
        ret.err                 := input_vec(95);
        ret.crc                 := input_vec(110 downto 96);
        ret.crc_delimiter       := input_vec(111);
        ret.data                := input_vec(191 downto 128);

        return ret;         
    end function;

    function get_empty_can_core_intf return can_core_out_intf_t is
        variable ret : can_core_out_intf_t;
    begin
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

    function get_word_from_can_core_vector(can_core_vector : can_core_vector_t; pos : integer) return axi_lite_vector_t is
        variable ret : axi_lite_vector_t  := (others => '0');
    begin 
        ret := can_core_vector(31 + (32 * pos) downto 0 + (32 * pos));
        return ret;
    end function;

    function get_can_core_out_intf(input_can_core : can_core_comb_intf_t) return can_core_out_intf_t is 
        variable ret : can_core_out_intf_t;
    begin
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
