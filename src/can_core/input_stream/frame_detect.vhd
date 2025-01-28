library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_detect is
    port (
        clk                     : in    std_logic                           := '0';
        rst_n                   : in    std_logic                           := '1';
        rxd_i                   : in    std_logic                           := '1';
        sample_i                : in    std_logic                           := '0';
        stuff_bit_i             : in    std_logic                           := '0';
        bus_active_i            : in    std_logic                           := '0';
        frame_done_o            : out   std_logic                           := '0';
        reload_o                : out   std_logic                           := '0';
        
        -- ID
        id_dec_o                : out   std_logic                           := '0';
        id_cnt_done_i           : in    std_logic                           := '0';
        id_sample_o             : out   std_logic                           := '0';

        -- EID
        eid_dec_o               : out   std_logic                           := '0';
        eid_cnt_done_i          : in    std_logic                           := '0';
        eid_sample_o            : out   std_logic                           := '0';

        -- DLC
        dlc_dec_o               : out   std_logic                           := '0';
        dlc_cnt_done_i          : in    std_logic                           := '0';
        dlc_sample_o            : out   std_logic                           := '0';
        dlc_data_i              : in    std_logic_vector(3 downto 0)        := (others => '0');

        -- DATA
        data_dec_o              : out   std_logic_vector(7 downto 0)        := (others => '0');
        data_cnt_done_i         : in    std_logic_vector(7 downto 0)        := (others => '0');
        data_sample_o           : out   std_logic_vector(7 downto 0)        := (others => '0');

        -- CRC
        crc_dec_o               : out   std_logic                           := '0';
        crc_cnt_done_i          : in    std_logic                           := '0';
        crc_sample_o            : out   std_logic                           := '0';

        -- EOF
        eof_dec_o               : out   std_logic                           := '0';
        eof_cnt_done_i          : in    std_logic                           := '0';

        -- OLF
        olf_dec_o               : out   std_logic                           := '0';
        olf_cnt_done_i          : in    std_logic                           := '0';
        olf_reload_o            : out   std_logic                           := '0';

        -- OLD
        old_dec_o               : out   std_logic                           := '0';
        old_cnt_done_i          : in    std_logic                           := '0';
        old_reload_o            : out   std_logic                           := '0';

        -- Stuff
        rtr_sample_o            : out   std_logic                           := '0';
        eff_sample_o            : out   std_logic                           := '0';
        err_sample_o            : out   std_logic                           := '0';

        -- HANDLING
        reset_i                 : in    std_logic;
        decode_error_o          : out   std_logic;
        enable_destuffing_o     : out   std_logic;
        data_valid_o            : out   std_logic;
        sof_state_o             : out   std_logic;

        -- CRC
        enable_crc_o            : out   std_logic;
        reset_crc_o             : out   std_logic;
        valid_crc_o             : out   std_logic
    );

end entity;

architecture rtl of frame_detect is

    type state_t is(
        idle_s,
        valid_sof_s,
        invalid_sof_s,
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
        ack_del_s,
        eof_s,
        olf_s,
        old_s,
        inter_s
    );

    signal current_state, new_state : state_t;

    signal valid_sample_s       : std_logic                                 := '0';
    signal frame_finished_s     : std_logic                                 := '0';
    signal reload_s             : std_logic                                 := '0';

    -- OUTPUT SIGNALS
    -- ID
    signal id_dec_s             : std_logic                                 := '0';
    signal id_sample_s          : std_logic                                 := '0';
    -- STUFF
    signal rtr_sample_s         : std_logic                                 := '0';
    signal eff_sample_s         : std_logic                                 := '0';
    signal err_sample_s         : std_logic                                 := '0';
    -- EID
    signal eid_dec_s            : std_logic                                 := '0';
    signal eid_sample_s         : std_logic                                 := '0';
    -- DLC
    signal dlc_dec_s            : std_logic                                 := '0';
    signal dlc_sample_s         : std_logic                                 := '0';
    -- DATA
    signal data_dec_s           : std_logic_vector(7 downto 0)              := (others => '0');
    signal data_sample_s        : std_logic_vector(7 downto 0)              := (others => '0');
    -- CRC
    signal crc_dec_s            : std_logic                                 := '0';
    signal crc_sample_s         : std_logic                                 := '0';
    -- ERROR-FRAME
    signal error_frame_error_s  : std_logic                                 := '0';
    -- ERROR_DEL
    signal eof_dec_s            : std_logic                                 := '0';
    -- OLF
    signal olf_dec_s            : std_logic                                 := '0';
    signal olf_reload_s         : std_logic                                 := '0';
    -- OLD
    signal old_dec_s            : std_logic                                 := '0';
    signal old_reload_s         : std_logic                                 := '0';
    -- HANDLING
    signal decode_error_s       : std_logic;
    signal enable_destuffing_s  : std_logic;
    signal data_valid_s         : std_logic;
    signal sof_state_s          : std_logic;
    --CRC
    signal enable_crc_s         : std_logic;
    signal reset_crc_s          : std_logic;
    signal valid_crc_s          : std_logic;
    

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
    -- ERROR DEL    
    eof_dec_o               <= eof_dec_s;
    -- OLF
    olf_dec_o               <= olf_dec_s;
    olf_reload_o            <= olf_reload_s;
    -- OLD
    old_dec_o               <= old_dec_s;
    old_reload_o            <= old_reload_s;
    -- Stuff
    rtr_sample_o            <= rtr_sample_s;
    eff_sample_o            <= eff_sample_s;
    err_sample_o            <= err_sample_s;
    -- HANDLING
    decode_error_o          <= decode_error_s;
    enable_destuffing_o     <= enable_destuffing_s;
    data_valid_o            <= data_valid_s;
    sof_state_o             <= sof_state_s;
    --CRC
    enable_crc_o            <= enable_crc_s;
    reset_crc_o             <= reset_crc_s;
    valid_crc_o             <= valid_crc_s;

    frame_done_o            <= frame_finished_s;
    reload_o                <= reload_s;

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
        crc_cnt_done_i,
        eof_cnt_done_i,
        olf_cnt_done_i,
        old_cnt_done_i,
        reset_i
    )
    begin
        new_state               <= current_state;
        -- ID
        id_dec_s                <= '0';
        id_sample_s             <= '0';

        -- EID
        eid_dec_s               <= '0';
        eid_sample_s            <= '0';
        -- DLC
        dlc_dec_s               <= '0';
        dlc_sample_s            <= '0';
        -- DATA
        data_dec_s              <= (others => '0');
        data_sample_s           <= (others => '0');
        -- CRC
        crc_dec_s               <= '0';
        crc_sample_s            <= '0';
        -- ERROR FRAME
        error_frame_error_s     <= '0';
        -- ERROR DEL
        eof_dec_s         <= '0';
        -- Frame done
        frame_finished_s        <= '0';
        -- OLF
        olf_dec_s               <= '0';
        olf_reload_s            <= '0';
        --OLD
        old_dec_s               <= '0';
        old_reload_s            <= '0';
        -- FLAGS
        eff_sample_s            <= '0';
        rtr_sample_s            <= '0';
        err_sample_s            <= '0';
        -- CNTR
        reload_s                <= '0';
        -- HANDLING
        decode_error_s          <= '0';
        enable_destuffing_s     <= '0';
        data_valid_s            <= '0';
        sof_state_s             <= '0';
        -- CRC
        enable_crc_s            <= '0';
        reset_crc_s             <= '0';
        valid_crc_s             <= '0';

        case current_state is
            when idle_s =>
                new_state <= invalid_sof_s;

            when invalid_sof_s => 
                if valid_sample_s = '1' and rxd_i = '0' and reset_i = '0' then 
                    new_state                       <= id_s;
                    reload_s                        <= '1';
                    enable_destuffing_s             <= '1';
                    sof_state_s                     <= '0';
                    enable_crc_s                    <= '1';
                else 
                    sof_state_s                     <= '1';
                    reset_crc_s                     <= '1';
                end if;

            when valid_sof_s => 
                if valid_sample_s = '1' and rxd_i = '0' and reset_i = '0' then 
                    new_state                       <= id_s;
                    reload_s                        <= '1';
                    enable_destuffing_s             <= '1';
                    sof_state_s                     <= '0';
                    enable_crc_s                    <= '1';
                else
                    sof_state_s                     <= '1';
                    data_valid_s                    <= '1';
                    reset_crc_s                     <= '1';
                end if;

            when id_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and id_cnt_done_i = '0' then
                    id_dec_s                        <= '1';
                    id_sample_s                     <= '1';
                elsif valid_sample_s = '1' and id_cnt_done_i = '1' then
                    new_state                       <= rtr_s;
                    id_sample_s                     <= '1';
                end if;

                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when rtr_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' then
                    new_state                       <= ide_s;
                    rtr_sample_s                    <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when ide_s => 
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and rxd_i = '0' then
                    new_state                       <= r0_s;
                elsif valid_sample_s = '1' and rxd_i = '1' then
                    new_state                       <= eid_s;
                    eff_sample_s                    <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when eid_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and eid_cnt_done_i = '0' then
                    eid_dec_s                       <= '1';
                    eid_sample_s                    <= '1';
                elsif valid_sample_s = '1' and eid_cnt_done_i = '1' then
                    new_state                       <= ertr_s;
                    eid_sample_s                    <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when ertr_s => 
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' then
                    new_state                       <= r1_s;
                    rtr_sample_s                    <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when r1_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' then
                    new_state                       <= r0_s;
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;
            
            when r0_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' then
                    new_state                       <= dlc_s;
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when dlc_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and dlc_cnt_done_i = '0' then
                    dlc_dec_s                       <= '1';
                    dlc_sample_s                    <= '1';
                elsif valid_sample_s = '1' and dlc_cnt_done_i = '1' then
                    new_state                       <= wait_dlc_s;
                    dlc_sample_s                    <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;
                
            when wait_dlc_s =>
                enable_destuffing_s                 <= '1';

                if dlc_data_i = "0000" then 
                    new_state                       <= crc_s;
                elsif dlc_data_i = "0001" then
                    new_state                       <= data1_s;
                elsif dlc_data_i = "0010" then
                    new_state                       <= data2_s;
                elsif dlc_data_i = "0011" then
                    new_state                       <= data3_s;
                elsif dlc_data_i = "0100" then
                    new_state                       <= data4_s; 
                elsif dlc_data_i = "0101" then
                    new_state                       <= data5_s; 
                elsif dlc_data_i = "0110" then
                    new_state                       <= data6_s;  
                elsif dlc_data_i = "0111" then
                    new_state                       <= data7_s;
                elsif dlc_data_i = "1000" then
                    new_state                       <= data8_s;
                else
                    new_state                       <= idle_s;
                end if;

                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when data8_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and data_cnt_done_i(7) = '0' then
                    data_dec_s(7)                   <= '1';
                    data_sample_s(7)                <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(7) = '1' then
                    new_state                       <= data7_s;
                    data_sample_s(7)                <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when data7_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and data_cnt_done_i(6) = '0' then
                    data_dec_s(6)                   <= '1';
                    data_sample_s(6)                <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(6) = '1' then
                    new_state                       <= data6_s;
                    data_sample_s(6)                <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when data6_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and data_cnt_done_i(5) = '0' then
                    data_dec_s(5)                   <= '1';
                    data_sample_s(5)                <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(5) = '1' then
                    new_state                       <= data5_s;
                    data_sample_s(5)                <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;


            when data5_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and data_cnt_done_i(4) = '0' then
                    data_dec_s(4)                   <= '1';
                    data_sample_s(4)                <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(4) = '1' then
                    new_state                       <= data4_s;
                    data_sample_s(4)                <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when data4_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and data_cnt_done_i(3) = '0' then
                    data_dec_s(3)                   <= '1';
                    data_sample_s(3)                <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(3) = '1' then
                    new_state                       <= data3_s;
                    data_sample_s(3)                <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when data3_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and data_cnt_done_i(2) = '0' then
                    data_dec_s(2)                   <= '1';
                    data_sample_s(2)                <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(2) = '1' then
                    new_state                       <= data2_s;
                    data_sample_s(2)                <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when data2_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and data_cnt_done_i(1) = '0' then
                    data_dec_s(1)                   <= '1';
                    data_sample_s(1)                <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(1) = '1' then
                    new_state                       <= data1_s;
                    data_sample_s(1)                <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when data1_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and data_cnt_done_i(0) = '0' then
                    data_dec_s(0)                   <= '1';
                    data_sample_s(0)                <= '1';          
                elsif valid_sample_s = '1' and data_cnt_done_i(0) = '1' then
                    new_state                       <= crc_s;
                    data_sample_s(0)                <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                else 
                    enable_crc_s                    <= '1';
                end if;

            when crc_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and crc_cnt_done_i = '0' then
                    crc_dec_s                       <= '1';
                    crc_sample_s                    <= '1';
                elsif valid_sample_s = '1' and crc_cnt_done_i = '1' then
                    new_state                       <= crc_del_s;
                    crc_sample_s                    <= '1';
                    
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                end if;

            when crc_del_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and rxd_i = '1' then
                    new_state                       <= ack_slot_s;
                    valid_crc_s                     <= '1';
                elsif valid_sample_s = '1' and rxd_i = '0' then
                    new_state                       <= invalid_sof_s;
                    decode_error_s                  <= '1';
                    valid_crc_s                     <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                end if;


            when ack_slot_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' then
                    new_state                       <= ack_del_s;
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                end if;

            when ack_del_s =>
                enable_destuffing_s                 <= '1';

                if valid_sample_s = '1' and rxd_i = '1' then
                    new_state                       <= eof_s;
                elsif valid_sample_s = '1' and rxd_i = '0' then
                    new_state                       <= invalid_sof_s;
                    decode_error_s                  <= '1';
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                end if;

            when eof_s =>
                enable_destuffing_s                 <= '0';
                
                if valid_sample_s = '1' and eof_cnt_done_i = '0' and rxd_i = '1' then
                    eof_dec_s                       <= '1';
                elsif valid_sample_s = '1' and eof_cnt_done_i = '1' and rxd_i = '1' then
                    new_state                       <= inter_s;
                elsif valid_sample_s = '1' and eof_cnt_done_i = '1' and rxd_i = '0' then
                    new_state                       <=  olf_s;
                elsif valid_sample_s = '1' and eof_cnt_done_i = '0' and rxd_i = '0' then 
                    new_state                       <=  olf_s;
                end if;

            when inter_s =>
                new_state                           <= valid_sof_s;
                frame_finished_s                    <= '1';

            when olf_s =>
                if valid_sample_s = '1' and olf_cnt_done_i = '0' then
                    olf_dec_s                       <= '1';
                elsif valid_sample_s = '1' and olf_cnt_done_i = '1' then
                    new_state                       <= old_s;
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
                end if;

            when old_s =>
                if valid_sample_s = '1' and old_cnt_done_i = '0' and rxd_i = '1' then
                    old_dec_s                       <= '1';
                elsif valid_sample_s = '1' and old_cnt_done_i = '0' and rxd_i = '0' then
                    new_state                       <= olf_s;
                    olf_reload_s                    <= '1';
                    old_reload_s                    <= '1';
                elsif valid_sample_s = '1' and old_cnt_done_i = '1' then
                    new_state                       <= inter_s;
                end if;
                if reset_i = '1' then
                    new_state                       <= invalid_sof_s;
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