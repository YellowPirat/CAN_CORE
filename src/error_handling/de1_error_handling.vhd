library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_error_handling is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_i                   : in    std_logic;
        sample_i                : in    std_logic;

        frame_finished_i        : in    std_logic;
        
    )