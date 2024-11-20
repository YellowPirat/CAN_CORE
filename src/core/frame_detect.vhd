library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_detect is
    port (
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_i                   : in    std_logic;
        sample_i                : in    std_logic;
        stuff_bit_i             : in    std_logic;
        bus_active_i            : in    std_logic;
        
        -- ID
        id_dec_o                : out   std_logic;
        id_cnt_done_i           : in    std_logic;
        id_sample_o             : out   std_logic;
        id_done_o               : out   std_logic
    );

end entity;

architecture rtl of frame_detect is

    type state_t is(
        idle_s,
        sof_s,
        id_s,
        rtr_s
    );

    signal current_state, new_state : state_t;

    signal valid_sample_s       : std_logic;

    -- OUTPUT SIGNALS
    signal id_dec_s             : std_logic;
    signal id_sample_s          : std_logic;
    signal id_done_s            : std_logic;

begin
    -- OUTPUT SIGNAL MAPPING
    id_dec_o                <= id_dec_s;
    id_sample_o             <= id_sample_s;
    id_done_o               <= id_done_s;


    -- GENERALIZATION OF VALID SAMPLE
    valid_sample_s <= '1' when sample_i = '1' and stuff_bit_i = '0' and bus_active_i = '1' else '0';

    -- Detection Automat
    frame_detect_p : process(
        current_state,
        rxd_i,
        valid_sample_s,
        id_cnt_done_i
    )
    begin
        new_state       <= current_state;
        -- ID
        id_dec_s        <= '0';
        id_sample_s     <= '0';
        id_done_o       <= '0';

        case current_state is
            when idle_s =>
                if valid_sample_s = '1' and rxd_i = '0' then
                    new_state   <=  sof_s;
                end if;

            when sof_s => 
                if valid_sample_s = '1' then 
                    new_state       <= id_s;
                    id_dec_s        <= '1';
                    id_sample_s     <= '1';
                end if;

            when id_s =>
                if valid_sample_s = '1' and id_cnt_done_i = '0' then
                    id_dec_s        <= '1';
                    id_sample_s     <= '1';
                elsif valid_sample_s = '1' and id_cnt_done_i = '1' then
                    new_state       <= rtr_s;
                    id_sample_s     <= '1';
                    id_done_s       <= '1';
                end if;

            
            when others =>
                new_state <= idle_s;
        end case;
    end process frame_detect_p;

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