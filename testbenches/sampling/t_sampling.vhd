library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.textio.all;

entity sampling is
end entity;

architecture sim of sampling is

    signal clk, rst_n: std_logic := '0';
    signal simstop : boolean := false;
    signal rxd_s : std_logic;


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
    wait for 20 ns;
    rst_n <= '1';
    wait;
  end process rst_p;

    simstop_p : process
    begin
    wait for 500 us;
        simstop <= true;
        wait;
    end process simstop_p;

    cangen_i0 : entity work.cangen
        port map(
            rst_n => rst_n,
            rxd_o => rxd_s,
            simstop => simstop
        );

    sampling_i0 : entity work.de1_sampling
        port map(
            clk     => clk,
            rst_n   => rst_n,
            rxd_i   => rxd_s
        );

end architecture;