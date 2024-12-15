library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity core is
end entity;

use work.can_core_intf.all;

architecture sim of core is

    signal clk, rst_n: std_logic := '0';
    signal simstop : boolean := false;

    signal rxd_async_s          :   std_logic;

    signal can_frame_s          :   can_core_out_intf_t;
    signal can_frame_valid_s    :   std_logic;

    signal uart_debug_tx_s      :   std_logic;

begin

  -- Clock generation
    clk_p : process
    begin
        clk <= '0';
        wait for 10 ns; 
        clk <= '1'; 
        wait for 10 ns;
        if simstop then
            wait;
        end if;
    end process clk_p;

  -- Reset generation
    rst_p : process
    begin
        rst_n <= '0';
        wait for 100 ns;
        rst_n <= '1';
        wait;
    end process rst_p;

    simstop_p : process
    begin
        wait for 4000 us;
        simstop <= true;
        wait;
    end process simstop_p;

    cangen_i0 : entity work.cangen
        port map(
            rst_n                   => rst_n,
            rxd_o                   => rxd_async_s,
            simstop                 => simstop
        );

    de1_can_core_i0 : entity work.de1_can_core
        port map(
            clk                     => clk,
            rst_n                   => rst_n,

            rxd_async_i             => rxd_async_s,

            can_frame_o             => can_frame_s,
            can_frame_valid_o       => can_frame_valid_s,

            uart_debug_tx_o         => uart_debug_tx_s
        );

end architecture;