library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sample_cnt is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;
        reload_i            : in    std_logic;
        enable_i            : in    std_logic;
        sample_o            : out   std_logic
    );
end entity;

architecture rtl of sample_cnt is

    signal q, d     : unsigned(5 downto 0);

begin

    q <= to_unsigned(50, q'length) when rst_n = '0' else d when rising_edge(clk);
    d <=    q when enable_i = '0' else
            to_unsigned(50, d'length) when reload_i = '1' else
            to_unsigned(50, d'length) when q = 0 else
            q - 1;

    
    sample_o <= '1' when q = 25 else '0';    


end architecture;