library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;

entity de1_debug is
    generic (
        widght_g            : positive := 8
    );
    port(
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        data_i              : in    std_logic_vector(widght_g - 1 downto 0);
        valid_i             : in    std_logic;

        rxd_i               : in    std_logic;
        txd_o               : out   std_logic;
		  
		  GPIO_1 : inout std_logic_vector(35 downto 0)
    );  
end entity;



architecture rtl of de1_debug is

    signal reload_s             : std_logic;
    signal en_s                 : std_logic;
    signal done_s               : std_logic;

    signal rst_h                : std_logic;

    signal tx_valid_s           : std_logic;
    signal tx_ready_s           : std_logic;
    signal tx_data_s            : std_logic_vector(7 downto 0);

    signal cnt_s                : std_logic_vector(log2ceil(widght_g / 4 + 1) - 1 downto 0);

    signal data_splice_s        : std_logic_vector(3 downto 0);



begin

	GPIO_1(2) <= tx_ready_s;
	GPIO_1(3) <= tx_valid_s;
	GPIO_1(4) <= valid_i;

    rst_h                       <= not rst_n;



    asci_mapper_i0 : entity work.asci_mapper
        port map(
            data_i              => data_splice_s,
            data_o              => tx_data_s
        );


    splice_cnt_i0 : entity work.splice_cnt
        generic map(
            start_cnt_g         => widght_g / 4
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            reload_i            => reload_s,
            en_i                => en_s,

            done_o              => done_s,
            cnt_o               => cnt_s
        );

    splicer_i0 : entity work.splicer
        generic map(
            widght_g            => widght_g
        )
        port map(
            data_i              => data_i,
            cnt_i               => cnt_s,

            data_o              => data_splice_s
        );

    uart_i0 : entity work.olo_intf_uart
        generic map(
            ClkFreq_g           => real(50000000)
        )
        port map(
            Clk                 => clk,
            Rst                 => rst_h,

            Tx_Valid            => tx_valid_s,
            Tx_Ready            => tx_ready_s,
            Tx_Data             => tx_data_s,

            Uart_Tx             => txd_o,
            Uart_Rx             => rxd_i
        );

    uart_cntr_i0 : entity work.uart_cntr
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            data_valid_i        => valid_i,
            uart_ready_i        => tx_ready_s,
            done_i              => done_s,

            uart_valid_o        => tx_valid_s,
            cnt_en_o            => en_s,
            reload_o            => reload_s
        );

end rtl ; -- rtl