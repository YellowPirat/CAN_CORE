library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity bench_finisher is 
    port(
        clk             : in    std_logic;
        rst_n           : in    std_logic;

        en_i            : in    std_logic;

        done_o          : out   std_logic
    );
end entity;

architecture rtl of bench_finisher is

    signal cnt_s        : unsigned(5 downto 0);

begin

    done_o <= '0' when cnt_s = 10 else '1';

    p : process(clk)
    begin 
        if rising_edge(clk) then
            cnt_s <= cnt_s;
            if en_i = '1' and cnt_s < 10 then
                cnt_s <= cnt_s + 1;
            end if;

            if rst_n = '0' then
                cnt_s <= to_unsigned(0, cnt_s'length);
            end if;
        end if;
    end process p;


end rtl;