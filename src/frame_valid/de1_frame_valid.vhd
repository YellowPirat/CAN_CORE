library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity de1_frame_valid is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        can_frame_valid_i   : in    std_logic;
        error_frame_valid_i : in    std_logic;
        sof_state_i         : in    std_logic;

        frame_valid_o       : out   std_logic
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