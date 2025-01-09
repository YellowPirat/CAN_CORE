library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sample_validator is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        data_i              : in    std_logic;
        sample_i            : in    std_logic;
        edge_i              : in    std_logic;

        resync_valid_o      : out    std_logic
    );
end entity;

architecture rtl of sample_validator is

    signal sample_edge_s           : std_logic;
    signal resync_valid_s          : std_logic;

begin

    resync_valid_o <= resync_valid_s;

    sample_edge_detect_i0 : entity work.sample_edge_detect
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            data_i              => data_i,
            sample_i            => sample_i,

            edge_detect_o       => sample_edge_s
        );

    resync_cntr_i0 : entity work.resync_cntr
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            sample_edge_i       => sample_edge_s,
            raw_data_edge_i     => edge_i,

            resync_valid_o      => resync_valid_s
        );

    

end architecture;