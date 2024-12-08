library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity destuffing_logic is
    port (
        clk                 : in    std_logic;
        rst_n               : in    std_logic;

        data_i              : in    std_logic;
        sample_i            : in    std_logic;
        enable_i            : in    std_logic;
        disable_destuffing_i : in   std_logic;
        eof_detect_i        : in    std_logic;

        last_bit_i          : in    std_logic;

        stuff_bit_o         : out   std_logic;
        stuff_error_o       : out    std_logic     
    );
end entity;

architecture rtl of destuffing_logic is

    type state_t is (
        idle_s,
        z0_s,
        z1_s,
        z2_s,
        z3_s,
        z4_s,
        bs_s,
        e0_s,
        e1_s,
        e2_s,
        e3_s,
        e4_s,
        err_s
    );

    signal current_state, new_state : state_t;

    signal stuff_bit_s, error_s : std_logic;

begin



    stuff_error_o <= error_s;
    stuff_bit_o <= stuff_bit_s;

    bit_destuff_p : process(current_state, data_i, sample_i, enable_i, last_bit_i, disable_destuffing_i, eof_detect_i)
    begin
        new_state <= current_state;
        stuff_bit_s <= '0';
        error_s <= '0';

        case current_state is
            when idle_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '0' then
                        new_state <= z0_s;
                    else
                        new_state <= e0_s;
                    end if;
                end if;
                
            
            when z0_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '0' then
                        new_state <= z1_s;
                    else
                        new_state <= e0_s;
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when z1_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '0' then
                        new_state <= z2_s;
                    else
                        new_state <= e0_s;
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when z2_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '0' then
                        new_state <= z3_s;
                    else
                        new_state <= e0_s;
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;
                
            when z3_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '0' then
                        new_state <= z4_s;
                    else
                        new_state <= e0_s;
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when z4_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '0' then
                        new_state <= err_s;
                        error_s <= '1';
                    else
                        new_state <= bs_s;
                        stuff_bit_s <= '1';
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when err_s =>
                if enable_i = '1' and disable_destuffing_i = '0' and eof_detect_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when bs_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '0' then
                        if last_bit_i = '0' then
                            new_state <= z1_s;
                        else 
                            new_state <= z0_s;
                        end if;
                    else
                        if last_bit_i = '1' then
                            new_state <= e1_s;
                        else
                            new_state <= e0_s;
                        end if;
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when e0_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '1' then
                        new_state <= e1_s;
                    else
                        new_state <= z0_s;
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when e1_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '1' then
                        new_state <= e2_s;
                    else
                        new_state <= z0_s;
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when e2_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '1' then
                        new_state <= e3_s;
                    else
                        new_state <= z0_s;
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when e3_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '1' then
                        new_state <= e4_s;
                    else
                        new_state <= z0_s;
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when e4_s =>
                if enable_i = '1' and sample_i = '1' then
                    if data_i = '1' then
                        new_state <= err_s;
                        error_s <= '1';
                    else
                        new_state <= bs_s;
                        stuff_bit_s <= '1';
                    end if;
                end if;
                if enable_i = '0' and disable_destuffing_i = '1' then 
                    new_state       <= idle_s;
                end if;

            when others =>
                new_state <= idle_s;
        end case;
    end process bit_destuff_p;

    p : process(clk)
    begin
        if rising_edge(clk) then 
            current_state <= new_state;
            if rst_n = '0' then
                current_state <= idle_s;
            end if;
        end if;
    end process p;

end architecture;