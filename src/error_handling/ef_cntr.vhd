library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ef_cntr is
    port(
        clk             : in    std_logic;
        rst_n           : in    std_logic;

        rxd_i           : in    std_logic;
        sample_i        : in    std_logic;
        enable_i        : in    std_logic;

        eof_detect_o    : out    std_logic
    );
end entity;

architecture rtl of ef_cntr is

    signal pe_dec_s             : std_logic;
    signal pe_cnt_done_s        : std_logic;
    signal pe_cnt_s             : unsigned(2 downto 0);

    signal ae_dec_s             : std_logic;
    signal ae_cnt_done_s        : std_logic;
    signal ae_cnt_s             : unsigned(2 downto 0);

    signal ed_dec_s             : std_logic;
    signal ed_cnt_done_s        : std_logic;

    signal reload_s             : std_logic;

begin 

    pe_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 5
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => reload_s,
            dec_i               => pe_dec_s,
            store_i             => '0',
            data_i              => rxd_i,

            done_o              => pe_cnt_done_s,
            cnt_o               => pe_cnt_s
        );

    ae_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 5
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => reload_s,
            dec_i               => ae_dec_s,
            store_i             => '0',
            data_i              => rxd_i,

            done_o              => ae_cnt_done_s,
            cnt_o               => ae_cnt_s
        );

    ed_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 7
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => reload_s,
            dec_i               => ed_dec_s,
            store_i             => '0',
            data_i              => rxd_i,

            done_o              => ed_cnt_done_s
        );

    ef_cntr_i0 : entity work.ef_detect
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            rxd_i               => rxd_i,
            sample_i            => sample_i,
            enable_i            => enable_i,

            pe_dec_o            => pe_dec_s,
            pe_cnt_done_i       => pe_cnt_done_s,
            pe_cnt_i            => pe_cnt_s,

            ae_dec_o            => ae_dec_s,
            ae_cnt_done_i       => ae_cnt_done_s,
            ae_cnt_i            => ae_cnt_s,

            ed_dec_o            => ed_dec_s,
            ed_cnt_done_i       => ed_cnt_done_s,

            eof_detect_o        => eof_detect_o,
            reload_o            => reload_s
        );


end rtl;