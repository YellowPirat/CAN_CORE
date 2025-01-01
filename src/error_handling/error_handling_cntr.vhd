library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity error_handling_cntr is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        stuff_error_i           : in    std_logic;
        decode_error_i          : in    std_logic;
        sample_error_i          : in    std_logic;
        crc_error_i             : in    std_logic;

        eof_detect_i            : in    std_logic;

        reset_core_o            : out   std_logic;
        reset_destuffing_o      : out   std_logic;

        enable_eof_detect_o     : out   std_logic
    );
end entity;

architecture rtl of error_handling_cntr is

    type state_t is(
        idle_s,
        wait_eof_s
    );

    signal current_state, new_state     : state_t;

    signal reset_core_s                 : std_logic;
    signal reset_destuffing_s           : std_logic;
    signal enable_eof_detect_s          : std_logic;

begin

    reset_core_o            <= reset_core_s;
    reset_destuffing_o      <= reset_destuffing_s;
    enable_eof_detect_o     <= enable_eof_detect_s;

    error_handling_cntr_p : process(current_state, stuff_error_i, decode_error_i, sample_error_i, crc_error_i, eof_detect_i)
    begin 
        new_state           <= current_state;
        reset_core_s        <= '0';
        reset_destuffing_s  <= '0';
        enable_eof_detect_s <= '0';

        case current_state is
            when idle_s =>
                if stuff_error_i = '1' or decode_error_i = '1' or sample_error_i = '1' or crc_error_i = '1' then
                    new_state               <= wait_eof_s;
                    enable_eof_detect_s     <= '1';
                    reset_core_s            <= '1';
                    reset_destuffing_s      <= '1';
                end if;

            when wait_eof_s =>
                enable_eof_detect_s     <= '1';
                reset_core_s            <= '1';
                reset_destuffing_s      <= '1';

                if  eof_detect_i = '1' then 
                    new_state           <= idle_s;
                    enable_eof_detect_s     <= '0';
                    reset_core_s            <= '0';
                    reset_destuffing_s      <= '0';
                end if;

            when others =>
                new_state <= idle_s;
        end case;
    end process error_handling_cntr_p;

    p : process(clk)
    begin
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then
                current_state <= idle_s;
            end if;
        end if;
    end process p;

end rtl ; -- rtl