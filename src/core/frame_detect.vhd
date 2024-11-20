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

        -- EID
        eid_dec_o               : out   std_logic;
        eid_cnt_done_i          : in    std_logic;
        eid_sample_o            : out   std_logic;

        -- DLC
        dlc_dec_o               : out   std_logic;
        dlc_cnt_done_i          : in    std_logic;
        dlc_sample_o            : out   std_logic

    );

end entity;

architecture rtl of frame_detect is

    type state_t is(
        idle_s,
        sof_s,
        id_s,
        rtr_s,
        ide_s,
        r0_s,
        eid_s,
        ertr_s,
        r1_s,
        dlc_s,
        crc_s,
        data8_s,
        data7_s,
        data6_s,
        data5_s,
        data4_s,
        data3_s,
        data2_s,
        data1_s
    );

    signal current_state, new_state : state_t;

    signal valid_sample_s       : std_logic;

    -- OUTPUT SIGNALS
    -- ID
    signal id_dec_s             : std_logic;
    signal id_sample_s          : std_logic;
    -- RTR
    signal rtr_store_s          : std_logic;
    -- EID
    signal eid_dec_s            : std_logic;
    signal eid_sample_s         : std_logic;
    -- DLC
    signal dlc_dec_s            : std_logic;
    signal dlc_sample_s         : std_logic;

begin
    -- OUTPUT SIGNAL MAPPING
    -- ID
    id_dec_o                <= id_dec_s;
    id_sample_o             <= id_sample_s;
    -- EID
    eid_dec_o               <= eid_dec_s;
    eid_sample_o            <= eid_sample_s;
    -- DLC
    dlc_dec_o               <= dlc_dec_s;
    dlc_sample_o            <= dlc_sample_s;


    -- GENERALIZATION OF VALID SAMPLE
    valid_sample_s <= '1' when sample_i = '1' and stuff_bit_i = '0' and bus_active_i = '1' else '0';

    -- Detection Automat
    frame_detect_p : process(
        current_state,
        rxd_i,
        valid_sample_s,
        id_cnt_done_i,
        eid_cnt_done_i,
        dlc_cnt_done_i
    )
    begin
        new_state       <= current_state;
        -- ID
        id_dec_s        <= '0';
        id_sample_s     <= '0';
        -- RTR
        rtr_store_s     <= '0';
        -- EID
        eid_dec_s       <= '0';
        eid_sample_s    <= '0';
        -- DLC
        dlc_dec_s       <= '0';
        dlc_sample_s    <= '0';

        case current_state is
            when idle_s =>
                new_state <= sof_s;

            when sof_s => 
                if valid_sample_s = '1' then 
                    new_state       <= id_s;
                end if;

            when id_s =>
                if valid_sample_s = '1' and id_cnt_done_i = '0' then
                    id_dec_s        <= '1';
                    id_sample_s     <= '1';
                elsif valid_sample_s = '1' and id_cnt_done_i = '1' then
                    new_state       <= rtr_s;
                    id_sample_s     <= '1';
                end if;

            when rtr_s =>
                if valid_sample_s = '1' then
                    new_state       <= ide_s;
                    rtr_store_s     <= '1';
                end if;

            when ide_s => 
                if valid_sample_s = '1' and rxd_i = '0' then
                    new_state       <= r0_s;
                elsif valid_sample_s = '1' and rxd_i = '1' then
                    new_state       <= eid_s;
                end if;

            when eid_s =>
                if valid_sample_s = '1' and eid_cnt_done_i = '0' then
                    eid_dec_s       <= '1';
                    eid_sample_s    <= '1';
                elsif valid_sample_s = '1' and eid_cnt_done_i = '1' then
                    new_state       <= ertr_s;
                    eid_sample_s    <= '1';
                end if;

            when ertr_s => 
                if valid_sample_s = '1' then
                    new_state <= r1_s;
                    rtr_store_s     <= '1';
                end if;

            when r1_s =>
                if valid_sample_s = '1' then
                    new_state       <= r0_s;
                end if;
            
            when r0_s =>
                if valid_sample_s = '1' then
                    new_state       <= dlc_s;
                end if;

            when dlc_s =>
                if valid_sample_s = '1' and dlc_cnt_done_i = '0' then
                    dlc_dec_s       <= '1';
                    dlc_sample_s    <= '1';
                elsif valid_sample_s = '1' and dlc_cnt_done_i = '1' then
                    new_state       <= crc_s;
                    dlc_sample_s    <= '1';
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