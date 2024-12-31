library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.olo_base_pkg_math.all;

entity buffer_usage_cnt is
    generic(
        memory_depth_g      : positive := 10
    );
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        inc_i               : in    std_logic;
        dec_i               : in    std_logic;

        cnt_o               : out   std_logic_vector(log2ceil(memory_depth_g + 1) - 1 downto 0);

        clr_i               : in    std_logic
    );
end entity;

architecture rtl of buffer_usage_cnt is

    signal cnt_s            : unsigned(log2ceil(memory_depth_g + 1) - 1 downto 0);

begin

    cnt_o                       <= std_logic_vector(cnt_s);

    p : process(clk)
    begin 
        if rising_edge(clk) then
            cnt_s       <= cnt_s;


            if inc_i = '1' and dec_i = '0' then
                cnt_s           <= cnt_s + 1;
            elsif inc_i = '0' and dec_i = '1' and cnt_s > 0 then
                cnt_s           <= cnt_s - 1;
            end if;

            if clr_i = '1' then
                cnt_s           <= to_unsigned(0, cnt_s'length);
            end if;


            if rst_n = '0' then
                cnt_s           <= to_unsigned(0, cnt_s'length);
            end if;
        end if;
    end process p;

end rtl;