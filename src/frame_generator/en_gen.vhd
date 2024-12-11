library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.olo_base_pkg_math.all;

entity en_gen is
    generic (
        count_g             : positive := 100;
        start_valid_g       : positive := 60;
        end_valid_g         : positive := 100
    );
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        glob_en_i           : in    std_logic;

        en_o                : out   std_logic;
        valid_o             : out   std_logic
    );
end entity;

architecture rtl of en_gen is

    signal cnt_s            : unsigned(log2ceil(count_g + 1) - 1 downto 0);

begin 

    en_o <= '1' when cnt_s = count_g - 1 else '0';

    valid_o <= '1' when cnt_s >= start_valid_g - 1 and cnt_s <= end_valid_g - 1 else '0';

    en_gen_p : process(clk)
    begin 
        if rising_edge(clk) then
            cnt_s     <= cnt_s;
            
            if cnt_s < count_g - 1 and glob_en_i = '1' then
                cnt_s <= cnt_s + 1;
            else
                cnt_s <= to_unsigned(0, cnt_s'length);
            end if;

            if rst_n = '0' then
                cnt_s <= to_unsigned(0, cnt_s'length);
            end if;
        end if;
    end process en_gen_p;

end rtl;