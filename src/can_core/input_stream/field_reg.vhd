library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

entity field_reg is 
    generic(
        startCnt_g              : positive
    );
    port(
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        reload_i                : in    std_logic;
        dec_i                   : in    std_logic;
        store_i                 : in    std_logic;
        data_i                  : in    std_logic;

        done_o                  : out   std_logic;
        data_o                  : out   std_logic_vector(startCnt_g - 1 downto 0);
        cnt_o                   : out   unsigned(log2ceil(startCnt_g + 1) - 1 downto 0)
    );
end entity;

architecture rtl of field_reg is

    signal cnt_s                : std_logic_vector(log2ceil(startCnt_g + 1) - 1 downto 0);

begin

    cnt_o                       <= unsigned(cnt_s);

    cnt_i0 : entity work.uni_dec_cnt
        generic map(
            startCnt_g          => startCnt_g
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            reload_i            => reload_i,
            dec_i               => dec_i,

            cnt_o               => cnt_s,
            done_o              => done_o
        );

    reg_i0 : entity work.uni_reg
        generic map(
            startCnt_g          => startCnt_g
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            reload_i            => reload_i,
            rxd_i               => data_i,
            store_i             => store_i,
            pos_i               => cnt_s,

            data_o              => data_o
        );

end rtl ; -- rtl