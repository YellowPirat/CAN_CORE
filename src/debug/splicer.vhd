library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

entity splicer is
    generic(
        widght_g        : positive := 8
    );
    port(
        data_i          : in    std_logic_vector(widght_g - 1 downto 0);
        cnt_i           : in    std_logic_vector(log2ceil(widght_g / 4 + 1) - 1 downto 0);
        
        data_o          : out   std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of splicer is

begin

    data_o <= data_i(3 + to_integer(unsigned(cnt_i)) * 4 downto  to_integer(unsigned(cnt_i)) * 4);

end rtl ; -- rtl