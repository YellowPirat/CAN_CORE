library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity de1_core is
    port(
        clk                     : in    std_logic;
        rst_n                   : in    std_logic;

        rxd_sync_i              : in    std_logic;
        sample_i                : in    std_logic;
        stuff_bit_i             : in    std_logic;
        bus_active_detect_i     : in    std_logic;

        id_o                    : out   std_logic_vector(28 downto 0);
        rtr_o                   : out   std_logic;
        eff_o                   : out   std_logic;
        err_o                   : out   std_logic;
        dlc_o                   : out   std_logic_vector(3 downto 0);
        data_o                  : out   std_logic_vector(63 downto 0);
        crc_o                   : out   std_logic_vector(14 downto 0);

        valid_o                 : out   std_logic;
		  
        frame_finished_o        : out   std_logic
    );
end entity;

architecture rtl of de1_core is

    signal frame_finished_s     : std_logic;
    signal reload_s             : std_logic;

    -- ID
    signal id_dec_s             : std_logic;
    signal id_cnt_done_s        : std_logic;
    signal id_sample_s          : std_logic;
    signal id_data_s            : std_logic_vector(10 downto 0);
    -- EID
    signal eid_dec_s            : std_logic;
    signal eid_cnt_done_s       : std_logic;
    signal eid_sample_s         : std_logic;
    signal eid_data_s           : std_logic_vector(17 downto 0);
    -- DLC
    signal dlc_dec_s            : std_logic;
    signal dlc_cnt_done_s       : std_logic;
    signal dlc_sample_s         : std_logic;
    signal dlc_data_s           : std_logic_vector(3 downto 0);
    -- DATA
    signal data_dec_s           : std_logic_vector(7 downto 0);
    signal data_cnt_done_s      : std_logic_vector(7 downto 0);
    signal data_sample_s        : std_logic_vector(7 downto 0);
    signal data_s               : std_logic_vector(63 downto 0);
    -- CRC
    signal crc_dec_s            : std_logic;
    signal crc_cnt_done_s       : std_logic;
    signal crc_sample_s         : std_logic;
    -- ERR DEL
    signal err_del_dec_s        : std_logic;
    signal err_del_cnt_done_s   : std_logic;
    --OLF
    signal olf_dec_s            : std_logic;
    signal olf_cnt_done_s       : std_logic;
    signal olf_reload_s         : std_logic;
    -- OLD
    signal old_dec_s            : std_logic;
    signal old_cnt_done_s       : std_logic;
    signal old_reload_s         : std_logic;

    -- Stuff
    signal rtr_sample_s         : std_logic;
    signal eff_sample_s         : std_logic;
    signal err_Sample_s         : std_logic;

    
begin
    frame_finished_o        <= frame_finished_s;

    data_o                  <= data_s;
    id_o(10 downto 0)       <= id_data_s;
    id_o(28 downto 11)      <= eid_data_s;


    valid_cntr_i0 : entity work.valid_cntr
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            frame_finished_i    => frame_finished_s,
            bus_active_i        => bus_active_detect_i,

            valid_o             => valid_o
        );

    data_gen : for i in 0 to 7 generate
        data_reg_i : entity work.field_reg
            generic map(
                startCnt_g      => 8
            )
            port map(
                clk                 => clk,
                rst_n               => rst_n,
                
                reload_i            => reload_s,
                dec_i               => data_dec_s(i),
                store_i             => data_sample_s(i),
                data_i              => rxd_sync_i,

                done_o              => data_cnt_done_s(i),
                data_o              => data_s(7 + 8*i downto i*8)
            );
    end generate data_gen;

    id_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 11
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => reload_s,
            dec_i               => id_dec_s,
            store_i             => id_sample_s,
            data_i              => rxd_sync_i,

            done_o              => id_cnt_done_s,
            data_o              => id_data_s
        );

    eid_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 18
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => reload_s,
            dec_i               => eid_dec_s,
            store_i             => eid_sample_s,
            data_i              => rxd_sync_i,

            done_o              => eid_cnt_done_s,
            data_o              => eid_data_s
        );

    dlc_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 4
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => reload_s,
            dec_i               => dlc_dec_s,
            store_i             => dlc_sample_s,
            data_i              => rxd_sync_i,

            done_o              => dlc_cnt_done_s,
            data_o              => dlc_data_s
        );

    crc_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 15
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => reload_s,
            dec_i               => crc_dec_s,
            store_i             => crc_sample_s,
            data_i              => rxd_sync_i,

            done_o              => crc_cnt_done_s
        );

    err_del_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 7
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => reload_s,
            dec_i               => err_del_dec_s,
            store_i             => '0',
            data_i              => rxd_sync_i,

            done_o              => err_del_cnt_done_s
        );

    olf_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 11
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => olf_reload_s,
            dec_i               => olf_dec_s,
            store_i             => '0',
            data_i              => rxd_sync_i,

            done_o              => olf_cnt_done_s
        );

    old_reg_i0 : entity work.field_reg
        generic map(
            startCnt_g          => 7
        )
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            
            reload_i            => old_reload_s,
            dec_i               => old_dec_s,
            store_i             => '0',
            data_i              => rxd_sync_i,

            done_o              => old_cnt_done_s
        );


    rtr_reg_i0 : entity work.bit_reg
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            data_i              => rxd_sync_i,
            sample_i            => rtr_sample_s,
            reload_i            => reload_s,

            data_o              => rtr_o
        );


    frame_detect_i0 : entity work.frame_detect
        port map(
            clk                 => clk,
            rst_n               => rst_n,

            rxd_i               => rxd_sync_i,
            sample_i            => sample_i,
            stuff_bit_i         => stuff_bit_i,
            bus_active_i        => bus_active_detect_i,
            frame_done_o        => frame_finished_s,
            reload_o            => reload_s,

            -- ID
            id_dec_o            => id_dec_s,
            id_cnt_done_i       => id_cnt_done_s,
            id_sample_o         => id_sample_s,

            -- EID
            eid_dec_o           => eid_dec_s,
            eid_cnt_done_i      => eid_cnt_done_s,
            eid_sample_o        => eid_sample_s,

            -- DLC
            dlc_dec_o           => dlc_dec_s,
            dlc_cnt_done_i      => dlc_cnt_done_s,
            dlc_sample_o        => dlc_sample_s,
            dlc_data_i          => dlc_data_s,

            -- DATA
            data_dec_o          => data_dec_s,
            data_cnt_done_i     => data_cnt_done_s,
            data_sample_o       => data_sample_s,

            -- CRC
            crc_dec_o           => crc_dec_s,
            crc_cnt_done_i      => crc_cnt_done_s,
            crc_sample_o        => crc_sample_s,

            -- ERR DEL
            err_del_dec_o       => err_del_dec_s,
            err_del_cnt_done_i  => err_del_cnt_done_s,

            -- OLF
            olf_dec_o           => olf_dec_s,
            olf_cnt_done_i      => olf_cnt_done_s,
            olf_reload_o        => olf_reload_s,

            -- OLD
            old_dec_o           => old_dec_s,
            old_cnt_done_i      => old_cnt_done_s,
            old_reload_o        => old_reload_s
        );

end rtl ;