library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

entity seq_cnt is
    generic (
        width_g         : natural                                   := 32
    );
    port (
        clk             : in    std_logic                           := '0';
        rst_n           : in    std_logic                           := '1';
        en_i            : in    std_logic                           := '0';
        reload_i        : in    std_logic                           := '0';
        shift_val_i     : in    unsigned(width_g - 1 downto 0)      := (others => '0');
        start_i         : in    unsigned(width_g - 1 downto 0)      := (others => '0');
        done_o          : out   std_logic                           := '0';
        cnt_o           : out   unsigned(width_g - 1 downto 0)      := (others => '0')
    );
end entity;

architecture rtl of seq_cnt is

    signal cnt_s        : unsigned(width_g - 1 downto 0)            := to_unsigned(0, width_g);
    signal done_s       : std_logic                                 := '0';

begin
    cnt_o  <= cnt_s;

    done_o  <= done_s;
    done_s  <= '1' when cnt_s = 0 else '0';

    cnt_p : process(clk)
    begin
        if rising_edge(clk) then

            cnt_s <= cnt_s;

            if reload_i = '1' then
                cnt_s <= start_i - shift_val_i;
            end if;

            if en_i = '1' and done_s = '0' then
                cnt_s <= cnt_s - 1;
            end if;

            if rst_n = '0' then
                cnt_s <= start_i;
            end if;

        end if;
    end process cnt_p;

end rtl ; -- rtl