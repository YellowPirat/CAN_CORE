library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

entity quantum_prescaler is
    generic (
        width_g               : natural   := 1
    );
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        prescaler_i         : in    unsigned(width_g - 1 downto 0);

        en_o                : out   std_logic
    );
end entity;

architecture rtl of quantum_prescaler is

    signal  cnt_s           : unsigned(width_g - 1 downto 0);

begin

    en_o <= '1' when cnt_s = 0 else '0';

    cnt_p : process(clk)
    begin 
        if rising_edge(clk) then
            if cnt_s < prescaler_i then
                cnt_s       <= cnt_s + 1;
            else
                cnt_s       <= to_unsigned(0, cnt_s'length);
            end if;

            if rst_n = '0' then
                cnt_s       <= to_unsigned(0, cnt_s'length);
            end if;
        end if;
    end process cnt_p;

end rtl ; -- rtl