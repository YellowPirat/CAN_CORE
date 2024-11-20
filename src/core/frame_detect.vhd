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
        dlc_sample_o            : out   std_logic;
        dlc_data_i              : in    std_logic_vector(3 downto 0);

        -- DATA
        data_dec_o              : out   std_logic_vector(7 downto 0);
        data_cnt_done_i         : in    std_logic_vector(7 downto 0);
        data_sample_o           : out   std_logic_vector(7 downto 0);

        -- CRC
        crc_dec_o               : out   std_logic;
        crc_cnt_done_i          : in    std_logic;
        crc_sample_o            : out   std_logic
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
        wait_dlc_s,
        crc_s,
        data8_s,
        data7_s,
        data6_s,
        data5_s,
        data4_s,
        data3_s,
        data2_s,
        data1_s,
        crc_del_s,
        ack_slot_s,
        ack_del
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
    -- DATA
    signal data_dec_s           : std_logic_vector(7 downto 0);
    signal data_sample_s        : std_logic_vector(7 downto 0);
    -- CRC
    signal crc_dec_s            : std_logic;
    signal crc_sample_s         : std_logic;

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
    -- DATA
    data_dec_o              <= data_dec_s;
    data_sample_o           <= data_sample_s;
    -- CRC
    crc_dec_o               <= crc_dec_s;
    crc_sample_o            <= crc_sample_s;

    -- GENERALIZATION OF VALID SAMPLE
    valid_sample_s <= '1' when sample_i = '1' and stuff_bit_i = '0' and bus_active_i = '1' else '0';

    -- Detection Automat
    frame_detect_p : process(
        current_state,
        rxd_i,
        valid_sample_s,
        id_cnt_done_i,
        eid_cnt_done_i,
        dlc_cnt_done_i,
        dlc_data_i,
        data_cnt_done_i,
        crc_cnt_done_i
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
        -- DATA
        data_dec_s      <= (others => '0');
        data_sample_s   <= (others => '0');
        -- CRC
        crc_dec_s       <= '0';
        crc_sample_s    <= '0';

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
                    new_state       <= wait_dlc_s;
                    dlc_sample_s    <= '1';
                end if; 
                
            when wait_dlc_s =>
                if dlc_data_i = "0000" then 
                    new_state <= crc_s;
                elsif dlc_data_i = "0001" then
                    new_state <= data1_s;
                elsif dlc_data_i = "0010" then
                    new_state <= data2_s;
                elsif dlc_data_i = "0011" then
                    new_state <= data3_s;
                elsif dlc_data_i = "0100" then
                    new_state <= data4_s; 
                elsif dlc_data_i = "0101" then
                    new_state <= data5_s; 
                elsif dlc_data_i = "0110" then
                    new_state <= data6_s;  
                elsif dlc_data_i = "0111" then
                    new_state <= data7_s;
                elsif dlc_data_i = "1000" then
                    new_state <= data8_s;
                else
                    new_state <= idle_s;
                end if;

            when data8_s =>
                if valid_sample_s = '1' and data_cnt_done_i(7) = '0' then
                    data_dec_s(7)       <= '1';
                    data_sample_s(7)    <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(7) = '1' then
                    new_state           <= data7_s;
                    data_sample_s(7)    <= '1';
                end if;

            when data7_s =>
                if valid_sample_s = '1' and data_cnt_done_i(6) = '0' then
                    data_dec_s(6)       <= '1';
                    data_sample_s(6)    <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(6) = '1' then
                    new_state           <= data6_s;
                    data_sample_s(6)    <= '1';
                end if;

            when data6_s =>
                if valid_sample_s = '1' and data_cnt_done_i(5) = '0' then
                    data_dec_s(5)       <= '1';
                    data_sample_s(5)    <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(5) = '1' then
                    new_state           <= data5_s;
                    data_sample_s(5)    <= '1';
                end if;

            when data5_s =>
                if valid_sample_s = '1' and data_cnt_done_i(4) = '0' then
                    data_dec_s(4)       <= '1';
                    data_sample_s(4)    <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(4) = '1' then
                    new_state           <= data4_s;
                    data_sample_s(4)    <= '1';
                end if;

            when data4_s =>
                if valid_sample_s = '1' and data_cnt_done_i(3) = '0' then
                    data_dec_s(3)       <= '1';
                    data_sample_s(3)    <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(3) = '1' then
                    new_state           <= data3_s;
                    data_sample_s(3)    <= '1';
                end if;

            when data3_s =>
                if valid_sample_s = '1' and data_cnt_done_i(2) = '0' then
                    data_dec_s(2)       <= '1';
                    data_sample_s(2)    <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(2) = '1' then
                    new_state           <= data2_s;
                    data_sample_s(2)    <= '1';
                end if;

            when data2_s =>
                if valid_sample_s = '1' and data_cnt_done_i(1) = '0' then
                    data_dec_s(1)       <= '1';
                    data_sample_s(1)    <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(1) = '1' then
                    new_state           <= data1_s;
                    data_sample_s(1)    <= '1';
                end if;

            when data1_s =>
                if valid_sample_s = '1' and data_cnt_done_i(0) = '0' then
                    data_dec_s(0)       <= '1';
                    data_sample_s(0)    <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(0) = '1' then
                    new_state           <= crc_s;
                    data_sample_s(0)    <= '1';
                end if;

            when crc_s =>
                if valid_sample_s = '1' and crc_cnt_done_i = '0' then
                    crc_dec_s           <= '1';
                    crc_sample_s        <= '1';
                elsif valid_sample_s = '1' and crc_cnt_done_i = '1' then
                    new_state           <= crc_del_s;
                    crc_sample_s        <= '1';
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