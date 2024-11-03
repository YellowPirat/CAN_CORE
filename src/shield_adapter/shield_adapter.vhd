library ieee;
use ieee.std_logic_1164.all;

entity shield_adapter is
    port(
        gpio_b          : inout std_logic_vector(35 downto 0);
        dbg_led_i       : in   std_logic_vector(5 downto 0);
        stb_i           : in   std_logic_vector(5 downto 0);
        rxd_o           : out    std_logic_vector(5 downto 0);
        txd_i           : in   std_logic_vector(5 downto 0)  
    );
end entity shield_adapter;

architecture rtl of shield_adapter is

begin

    -- dbg_leds
    gpio_b(1) <= dbg_led_i(0);
    gpio_b(7) <= dbg_led_i(1);
    gpio_b(11) <= dbg_led_i(2);
    gpio_b(19) <= dbg_led_i(3);
    gpio_b(27) <= dbg_led_i(4);
    gpio_b(33) <= dbg_led_i(5);

    gpio_b(3) <= stb_i(0);
    gpio_b(9) <= stb_i(1);
    gpio_b(13) <= stb_i(2);
    gpio_b(21) <= stb_i(3);
    gpio_b(29) <= stb_i(4);
    gpio_b(35) <= stb_i(5);

    gpio_b(2) <= txd_i(0);
    gpio_b(8) <= txd_i(1);
    gpio_b(12) <= txd_i(2);
    gpio_b(20) <= txd_i(3);
    gpio_b(28) <= txd_i(4);
    gpio_b(34) <= txd_i(5);

    rxd_o(0) <= gpio_b(0);
    rxd_o(1) <= gpio_b(6);
    rxd_o(2) <= gpio_b(10);
    rxd_o(3) <= gpio_b(18);
    rxd_o(4) <= gpio_b(26);
    rxd_o(5) <= gpio_b(32);


end rtl ; -- rtl