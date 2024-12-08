library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

entity uni_reg is
    generic(
        startCnt_g              : positive
    );
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        reload_i                : in    std_logic;
        rxd_i                   : in    std_logic;
        store_i                 : in    std_logic;
        pos_i                   : in    std_logic_vector(log2ceil(startCnt_g + 1) - 1 downto 0);

        
        data_o                  : out   std_logic_vector(startCnt_g - 1 downto 0)
    ); 
end entity;

architecture rtl of uni_reg is

    signal reg_s                : std_logic_vector(startCnt_g - 1 downto 0);
    

begin

    data_o <= reg_s;

    reg_p : process(clk)
    begin
        if rising_edge(clk) then
            if store_i = '1' then
                reg_s(to_integer(unsigned(pos_i))) <= rxd_i;
            end if;

            if reload_i = '1' then
                reg_s <= (others => '0');
            end if;

            if rst_n = '0' then
                reg_s <= (others => '0');
            end if;
        end if;
    end process;

end rtl ; -- rtl