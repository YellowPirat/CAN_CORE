library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uni_cnt is
    generic(
        timer_width_g       : positive;
        overflow_point_g    : std_logic_vector(63 downto 0)
    );
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        en_i                : in    std_logic;

        en_o                : out   std_logic;
        cnt_o               : out   std_logic_vector(timer_width_g - 1 downto 0)
    );
end entity;

architecture rtl of uni_cnt is

    signal cnt_s            : unsigned(timer_width_g - 1 downto 0);
    signal en_s             : std_logic;

begin

    cnt_o   <= std_logic_vector(cnt_s);
    en_o    <= en_s;

    cnt_p : process(clk)
    begin 
        if rising_edge(clk) then
            cnt_s   <= cnt_s;
            en_s    <= '0';

            if en_i = '1' then
                cnt_s       <= cnt_s + 1;

                if cnt_s = unsigned(overflow_point_g) - 1 then
                    cnt_s   <= to_unsigned(0, cnt_s'length);
                    en_s    <= '1';
                end if;
            end if;

            if rst_n = '0' then
                cnt_s       <= to_unsigned(0, cnt_s'length);
            end if;
        end if;
    end process cnt_p;

end rtl;