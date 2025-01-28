library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.olo_base_pkg_math.all;

entity buffer_usage_cntr is
    generic(
        memory_depth_g      : positive                                                                  := 10
    );
    port (
        clk                 : in    std_logic                                                           := '0';
        rst_n               : in    std_logic                                                           := '1';
        inc_i               : in    std_logic                                                           := '0';
        dec_i               : in    std_logic                                                           := '0';
        cnt_o               : out   std_logic_vector(log2ceil(memory_depth_g + 1) - 1 downto 0)         := (others => '0');
        clr_i               : in    std_logic                                                           := '0'
    );
end entity;

architecture rtl of buffer_usage_cntr is

    signal valid_edge_s     : std_logic                                                                 := '0';

begin

    buffer_usage_cnt_i0 : entity work.buffer_usage_cnt
        generic map(
            memory_depth_g              => memory_depth_g
        )
        port map(
            clk                         => clk,
            rst_n                       => rst_n,

            inc_i                       => valid_edge_s,
            dec_i                       => dec_i,

            cnt_o                       => cnt_o,

            clr_i                       => clr_i
        );
    
    valid_edge_det_i0 : entity work.valid_edge_det
        port map(
            clk                         => clk,
            rst_n                       => rst_n,

            valid_i                     => inc_i,

            edge_o                      => valid_edge_s
        );

end rtl;