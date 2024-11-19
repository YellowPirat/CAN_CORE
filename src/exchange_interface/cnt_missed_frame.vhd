library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cnt_missed_frame is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        en_cnt_i            : in    std_logic;

        cnt_o               : out   std_logic_vector(14 downto 0);
        overflow_o          : out   std_logic
    );
end entity cnt_missed_frame;

architecture rtl of cnt_missed_frame is

    signal cnt_s            : unsigned(14 downto 0);

    signal overflow_s       : std_logic;

begin

    cnt_p : process(clk)
    begin 
        if rising_edge(clk) then
            if en_cnt_i = '1' then
                if cnt_s = 32768 then
                    cnt_s <= to_unsigned(0, cnt_s'length);
                    overflow_s <= '1';
                else
                    overflow_s <= '0';
                    cnt_s <= cnt_s + 1;
                end if;
            end if;

            if rst_n = '0' then 
                cnt_s <= to_unsigned(0, cnt_s'length);
            end if;
        end if;
    end process cnt_p;

    cnt_o <= std_logic_vector(cnt_s);
    overflow_o <= overflow_s;

end rtl;