library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.olo_base_pkg_math.all;

entity frame_cnt is
    generic(
        count_g         : positive  := 10
    );
    port (
        clk             : in    std_logic;
        rst_n           : in    std_logic;

        en_i            : in    std_logic;
        glob_en_i       : in    std_logic;

        cnt_o           : out   std_logic_vector(log2ceil(count_g + 1) - 1 downto 0);
        done_o          : out   std_logic
    );
end entity;

architecture rtl of frame_cnt is

    signal cnt_s        : unsigned(log2ceil(count_g + 1) - 1 downto 0);
    signal done_s       : std_logic;

begin
    cnt_o           <= std_logic_vector(cnt_s);
    done_o          <= done_s;

    frame_cnt_p : process(clk)
    begin 
        if rising_edge(clk) then
            cnt_s     <= cnt_s;
            done_s    <= '0';
            if en_i = '1' then
                if cnt_s < count_g - 1 and en_i = '1' and glob_en_i = '1' then
                    cnt_s <= cnt_s + 1;
                else 
                    cnt_s   <= to_unsigned(0, cnt_s'length);
                    done_s  <= '1';
                end if;
            end if;

            if rst_n = '0' then
                cnt_s <= to_unsigned(0, cnt_s'length);
            end if;
        end if;
    end process frame_cnt_p;

end rtl;