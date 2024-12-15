library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eof_detect is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_i                   : in    std_logic;
        sample_i                : in    std_logic;
        enable_i                : in    std_logic;

        eof_detect_o            : out    std_logic
    );
end entity;

architecture rtl of eof_detect is

    type state_t is(
        idle_s,
        r0,
        r1,
        r2,
        r3,
        r4,
        r5,
        r6,
        r7
    );

    signal current_state, new_state : state_t;

    signal eof_detect_s             : std_logic;

begin

    eof_detect_o                <= eof_detect_s;

    eof_detect_p : process(current_state, rxd_i, sample_i, enable_i)
    begin
        new_state               <= current_state;
        eof_detect_s            <= '0';

        case current_state is
            when idle_s =>
                if rxd_i = '1' and sample_i = '1' and enable_i = '1' then
                    new_state   <= r0;
                end if;

            when r0 =>
                if rxd_i = '1' and sample_i = '1' then
                    new_state   <= r1;
                elsif rxd_i = '0' and sample_i = '1' then
                    new_state   <= idle_s;
                end if;

                if enable_i = '0' then
                    new_state   <= idle_s;
                end if;


            when r1 =>
                if rxd_i = '1' and sample_i = '1' then
                    new_state   <= r2;
                elsif rxd_i = '0' and sample_i = '1' then
                    new_state   <= idle_s;
                end if;

                if enable_i = '0' then
                    new_state   <= idle_s;
                end if;

            when r2 =>
                if rxd_i = '1' and sample_i = '1' then
                    new_state   <= r3;
                elsif rxd_i = '0' and sample_i = '1' then
                    new_state   <= idle_s;
                end if;

                if enable_i = '0' then
                    new_state   <= idle_s;
                end if;

            when r3 =>
                if rxd_i = '1' and sample_i = '1' then
                    new_state   <= r4;
                elsif rxd_i = '0' and sample_i = '1' then
                    new_state   <= idle_s;
                end if;

                if enable_i = '0' then
                    new_state   <= idle_s;
                end if;

            when r4 =>
                if rxd_i = '1' and sample_i = '1' then
                    new_state   <= r5;
                elsif rxd_i = '0' and sample_i = '1' then
                    new_state   <= idle_s;
                end if;

                if enable_i = '0' then
                    new_state   <= idle_s;
                end if;

            when r5 =>
                if rxd_i = '1' and sample_i = '1' then
                    new_state   <= r6;
                elsif rxd_i = '0' and sample_i = '1' then
                    new_state   <= idle_s;
                end if;

                if enable_i = '0' then
                    new_state   <= idle_s;
                end if;

            when r6 =>
                if rxd_i = '1' and sample_i = '1' then
                    new_state   <= r7;
                elsif rxd_i = '0' and sample_i = '1' then
                    new_state   <= idle_s;
                end if;

                if enable_i = '0' then
                    new_state   <= idle_s;
                end if;


            when r7 =>
                if rxd_i = '1' and sample_i = '1' then
                    new_state       <= idle_s;
                    eof_detect_s    <= '1';
                elsif rxd_i = '0' and sample_i = '1' then
                    new_state       <= idle_s;
                end if;

                if enable_i = '0' then
                    new_state   <= idle_s;
                end if;


            when others =>
                    new_state       <= idle_s;

        end case;
    end process eof_detect_p;

    p : process(clk)
    begin
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then
                current_state <= idle_s;
            end if;
        end if;
    end process p;

end rtl;