library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity de1_frame_valid is
    port (
        clk                         : in    std_logic                   := '0';
        rst_n                       : in    std_logic                   := '1';
        can_frame_valid_i           : in    std_logic                   := '0';
        error_frame_valid_i         : in    std_logic                   := '0';
        sof_state_i                 : in    std_logic                   := '0';
        frame_valid_o               : out   std_logic                   := '0'
    );
end de1_frame_valid;

architecture rtl of de1_frame_valid is

begin 

    frame_valid_cntr_i0 : entity work.frame_valid_cntr
        port map(
            clk                     => clk,
            rst_n                   => rst_n,
            can_frame_valid_i       => can_frame_valid_i,
            error_i                 => error_frame_valid_i,
            sof_state_i             => sof_state_i,
            frame_valid_o           => frame_valid_o
        );

end rtl;