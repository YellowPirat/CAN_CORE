library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

entity uni_dec_cnt is
    generic(
        startCnt_g              : positive
    );
    port (
        clk                     : in    std_logic                                                       := '0';
        rst_n                   : in    std_logic                                                       := '1';
        reload_i                : in    std_logic                                                       := '0';
        dec_i                   : in    std_logic                                                       := '0';
        cnt_o                   : out   std_logic_vector(log2ceil(startCnt_g + 1) - 1 downto 0)         := (others => '0');
        done_o                  : out   std_logic                                                       := '0'
    );
end entity;

architecture rtl of uni_dec_cnt is

    signal cnt_s                : unsigned(log2ceil(startCnt_g + 1) - 1 downto 0)                       := (others => '0');

begin

    cnt_o <= std_logic_vector(cnt_s);

    done_o <= '1' when cnt_s = 0 else '0';

    dec_cnt_p : process(clk)
    begin
        if rising_edge(clk) then

            if cnt_s = 0 then
                cnt_s <= cnt_s;
            elsif dec_i = '1' then
                cnt_s <= cnt_s - 1;
            end if;



            if reload_i = '1' then 
                cnt_s   <= to_unsigned(startCnt_g - 1, cnt_s'length);
            end if;

            if rst_n = '0' then
                cnt_s   <= to_unsigned(startCnt_g - 1, cnt_s'length);
            end if;
        end if;
    end process;


end rtl ; -- rtl