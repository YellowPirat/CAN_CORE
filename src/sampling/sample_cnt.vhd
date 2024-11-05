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

    signal q, d     : unsigned(6 downto 0);

begin
    
    cnt_p : process(clk)
    begin
        if rising_edge(clk) then
            if enable_i = '1' then
                if reload_i = '1' or q = 0 then
                    q <= to_unsigned(100, d'length);
                else
                    q <= q - 1;
                end if;
            end if;

            if rst_n = '0' then
                q <= to_unsigned(100, d'length);
            end if;
        end if;
    end process cnt_p;

    
    sample_o <= '1' when q = 50 else '0';    


end architecture;