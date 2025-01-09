library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity de1_warm_start is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        rxd_sync_i          : in    std_logic;
        sample_i            : in    std_logic;

        rxd_sync_o          : out   std_logic
    );
end entity;

architecture rtl of de1_warm_start is

begin

    warm_start_i0 : entity work.warm_start
        port map(
            clk             => clk,
            rst_n           => rst_n,

            rxd_sync_i      => rxd_sync_i,
            sample_i        => sample_i,

            rxd_sync_o      => rxd_sync_o
        );


end rtl;