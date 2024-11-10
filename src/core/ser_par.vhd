library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ser_par is
    generic(
        DataWidth_g         : positive      := 8
    ); 
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        data_i              : in    std_logic;
        enable_i            : in    std_logic;
        reload_i            : in    std_logic;

        data_o              : out   std_logic_vector(DataWidth_g - 1 downto 0)
    );

end entity;

architecture rtl of ser_par is
    signal q, d      : std_logic_vector(DataWidth_g - 1 downto 0);
begin

    d(DataWidth_g - 1 downto 1) <= q(DataWidth_g - 2 downto 0);
    d(0) <= data_i;

    sp_p : process(clk)
    begin
        if rising_edge(clk) then

            if enable_i = '1' then
                q <= d;
            end if;

            if rst_n = '0' or reload_i = '1' then 
                q <= (others => '0');
            end if;
        end if;
    end process sp_p;

    data_o <= q;

end architecture;